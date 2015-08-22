//
//  PWWallpaper.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWWallpaper.h"
#import "PWView.h"
#import "IOSurfaceAPI.h"
#import "CARenderServerAPI.h"
#import <Accelerate/Accelerate.h>
#import "SBSUIConstants.h"

static NSString *const kSBProceduralWallpaperHomeOptionsKey = @"kSBProceduralWallpaperHomeOptionsKey";
static NSString *const kSBProceduralWallpaperLockOptionsKey = @"kSBProceduralWallpaperLockOptionsKey";

@interface UIWindow (Context)
- (uint32_t)_contextId;
@end

@interface PWWallpaper ()
@property (readwrite, nonatomic, assign) PWView *activeView;
@property (nonatomic, retain) NSMutableDictionary *wallpapers;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@end

@implementation PWWallpaper
@synthesize delegate = _delegate;

+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

+ (float)blurRadius
{
    return 5.0f;
}

+ (float)blurScale
{
    return 0.25f;
}

+ (float)saturationDeltaFactor
{
    return 1.8f;
}

+ (BOOL)colorChangesSignificantly
{
    return NO;
}
 
- (void)setAnimating:(BOOL)animating
{
    if (animating) {
        [self.activeView resume];
    } else {
        [self.activeView pause];
    }
}

- (void)layoutSubviews
{
    NSArray *views = [self.wallpapers allValues];
    for (PWView *view in views) {
        [view viewWillTransitionToSize:self.frame.size];
    }
    [super layoutSubviews];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSLog(@"\n\n\n\n\n_initialize PWWallpaper:%@", [self class]);
        self.wallpapers = [NSMutableDictionary dictionaryWithCapacity:2];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        int observerOptions = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.userDefaults addObserver:self forKeyPath:kSBProceduralWallpaperHomeOptionsKey options:observerOptions context:NULL];
        [self.userDefaults addObserver:self forKeyPath:kSBProceduralWallpaperLockOptionsKey options:observerOptions context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    PWView *oldView = nil;
    NSDictionary *oldOptions = [change valueForKey:@"old"];
    if (![oldOptions isEqual:[NSNull null]] && [oldOptions valueForKey:kSBUIMagicWallpaperIdentifierKey]) {
        oldView = [self.wallpapers objectForKey:oldOptions];
        oldView.referenceCount--;
    }
    NSDictionary *newOptions = [change valueForKey:@"new"];
    if (![newOptions isEqual:[NSNull null]] && [newOptions valueForKey:kSBUIMagicWallpaperIdentifierKey]) {
        PWView *newView = [self wallpaperForOptions:newOptions];
        newView.referenceCount++;
    }
    if (oldView != nil && oldView.referenceCount <= 0) {
        if (self.activeView == oldView) {
            self.activeView = nil;
        }
        [oldView removeFromSuperview];
        [self.wallpapers removeObjectForKey:oldOptions];
        [self clearUnusedAssets];
    }
}

- (void)setWallpaperOptions:(NSDictionary *)options
{
    PWView *view = [self wallpaperForOptions:options];
    if (view && view != self.activeView) {
        [self.activeView setHidden:YES];
        [self.activeView pause];
        self.activeView = view;
    }
    [view setHidden:NO];
    [self addSubview:view];
    
    // Updates blur and averageColor when activeView changes
    dispatch_async(dispatch_get_main_queue(), ^{
        void *blurSurface = [self computeBlurs];
        [self.delegate wallpaper:self didGenerateBlur:blurSurface forRect:self.bounds];
        // Forces averageLifetimeColor to be updated
        [self.delegate _sample];
    });
}

- (PWView *)wallpaperForOptions:(NSDictionary *)options
{
    PWView *view = nil;
    if (options != nil) {
        view = [self.wallpapers objectForKey:options];
        if (view == nil) {
            view = [self initializeWallpaperWithOptions:options];
            view.delegate = self;
            [self.wallpapers setObject:view forKey:options];
        }
    }
    NSLog(@"\n\n\n\nwallpapers:%@", self.wallpapers);
    return view;
}

- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

// called whenever a wallpaper created from this factory is deallocated
// allows for storing assets in the wallpaper factory and sharing them between wallpapers
- (void)clearUnusedAssets
{
    
}

- (void *)surfaceForRect:(CGRect)rect
{
    NSNumber *isGlobal = [NSNumber numberWithBool:YES];
    NSNumber *pixelFormat = [NSNumber numberWithUnsignedInt:'BGRA'];
    NSNumber *width =  [NSNumber numberWithInt:CGRectGetWidth(rect)];
    NSNumber *height =  [NSNumber numberWithInt:CGRectGetHeight(rect)];
    NSNumber *bytesPerElement =  [NSNumber numberWithInt:4];
    
    CFDictionaryRef properties = (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:isGlobal, kIOSurfaceIsGlobal,bytesPerElement, kIOSurfaceBytesPerElement, width, kIOSurfaceWidth, height, kIOSurfaceHeight, pixelFormat, kIOSurfacePixelFormat, nil];
    return IOSurfaceCreate(properties);
}

- (void)updateBlurForView:(PWView *)view
{
    if (self.activeView == view) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //void *blurSurface = [self computeBlurs];
            //NSLog(@"\n\n\n\n\n\n UPDAET BLUR:%@", view);
            //[self.delegate wallpaper:self didGenerateBlur:blurSurface forRect:self.bounds];
        });
    }
}

- (UIColor *)computeAverageColor
{
    CGSize size = self.bounds.size;
    CGRect frame = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    CATransform3D transform = CATransform3DMakeScale(CGRectGetWidth(frame)/size.width, CGRectGetHeight(frame)/size.height, 1.0f);
    
    void *surface = [self surfaceForRect:frame];
    IOSurfaceLock(surface, 0, NULL);
    CARenderServerRenderLayerWithTransform(MACH_PORT_NULL, [self.window _contextId], (uint64_t)self.layer, surface, 0, 0, &transform);
    IOSurfaceUnlock(surface, 0, NULL);
    
    Byte *data = (Byte *)IOSurfaceGetBaseAddress(surface);
    CGFloat blue = data[0] / 255.0f;
    CGFloat green = data[1] / 255.0f;
    CGFloat red = data[2] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}


- (void *)computeBlurs
{
    CGSize size = self.bounds.size;
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width * [self.class blurScale], size.height * [self.class blurScale]);
    CATransform3D transform = CATransform3DMakeScale(CGRectGetWidth(frame)/size.width, CGRectGetHeight(frame)/size.height, 1.0f);
    
    void *surface = [self surfaceForRect:frame];
    IOSurfaceLock(surface, 0, NULL);
    CARenderServerRenderLayerWithTransform(MACH_PORT_NULL, [self.window _contextId], (uint64_t)self.layer, surface, 0, 0, &transform);

    vImage_Buffer effectInBuffer;
    vImage_Buffer scratchBuffer1;
    
    vImage_Buffer *inputBuffer;
    vImage_Buffer *outputBuffer;
    
    vImage_CGImageFormat format = {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = NULL,
        // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
        // requests a BGRA buffer.
        .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    vImageBuffer_Init(&effectInBuffer, IOSurfaceGetHeight(surface), IOSurfaceGetWidth(surface), format.bitsPerPixel, kvImageNoAllocate);
    effectInBuffer.data = IOSurfaceGetBaseAddress(surface);
    
    vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
    inputBuffer = &effectInBuffer;
    outputBuffer = &scratchBuffer1;
    
    // A description of how to compute the box kernel width from the Gaussian
    // radius (aka standard deviation) appears in the SVG spec:
    // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
    //
    // For larger values of 's' (s >= 2.0), an approximation can be used: Three
    // successive box-blurs build a piece-wise quadratic convolution kernel, which
    // approximates the Gaussian kernel to within roughly 3%.
    //
    // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
    //
    // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
    //
    CGFloat inputRadius = [self.class blurRadius] * [UIScreen mainScreen].scale;
    if (inputRadius - 2. < __FLT_EPSILON__)
        inputRadius = 2.;
    uint32_t radius = floor((inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
    
    radius |= 1; // force radius to be odd so that the three box-blur methodology works.
    
    NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radius, radius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
    void *tempBuffer = malloc(tempBufferSize);
    
    vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    
    free(tempBuffer);
    
    vImage_Buffer *temp = inputBuffer;
    inputBuffer = outputBuffer;
    outputBuffer = temp;
    
    CGFloat s = [self.class saturationDeltaFactor];
    // These values appear in the W3C Filter Effects spec:
    // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
    //
    CGFloat floatingPointSaturationMatrix[] = {
        0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
        0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
        0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
        0,                    0,                    0,                    1,
    };
    const int32_t divisor = 256;
    NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
    int16_t saturationMatrix[matrixSize];
    for (NSUInteger i = 0; i < matrixSize; ++i) {
        saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
    }
    vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
    
    uint32_t *f = (uint32_t *)outputBuffer->data;
    uint32_t *r = (uint32_t *)IOSurfaceGetBaseAddress(surface);
    memcpy(r, f, IOSurfaceGetAllocSize(surface));
    free(inputBuffer->data);
    
    IOSurfaceUnlock(surface, 0, NULL);
    return surface;
}

- (UIColor *)averageLifetimeColor
{
    UIColor *averageColor;
    if ([self.activeView supportsAverageColor]) {
        averageColor = [self computeAverageColor];
    } else {
        averageColor = nil;
    }
    return averageColor;
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\ndealloc PWWallpaper");
    [_userDefaults removeObserver:self forKeyPath:kSBProceduralWallpaperHomeOptionsKey];
    [_userDefaults removeObserver:self forKeyPath:kSBProceduralWallpaperLockOptionsKey];
    [_userDefaults release];
    [_wallpapers release];
    [super dealloc];
}

@end
