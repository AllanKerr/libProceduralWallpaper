//
//  PWWallpaperBlur.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-30.
//
//

#import "PWWallpaperBlur.h"
#import "IOSurfaceAPI.h"
#import "CARenderServerAPI.h"
#import <Accelerate/Accelerate.h>

@interface UIWindow (Context)
- (uint32_t)_contextId;
@end

@interface PWWallpaperBlur ()
@property (nonatomic, assign) PWWallpaper *target;
@end

@implementation PWWallpaperBlur

- (id)initWithTarget:(PWWallpaper *)target
{
    if (self = [super init]) {
        NSLog(@"\n\n\n\ninit PWWallpaperBlur");
        self.target = target;
    }
    return self;
}

- (void)updateBlurs:(CADisplayLink *)displayLink
{
    void *surface = [self computeBlurs];
    [self.target.delegate wallpaper:self.target didGenerateBlur:surface forRect:self.target.frame];
    CFRelease(surface);
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

- (void *)computeBlurs
{
    CGSize size = self.target.frame.size;
    CGRect frame = CGRectMake(0.0f, 0.0f, size.width * [[self.target class] blurScale], size.height * [[self.target class] blurScale]);
    CATransform3D transform = CATransform3DMakeScale(CGRectGetWidth(frame)/size.width, CGRectGetHeight(frame)/size.height, 1.0f);
    
    void *surface = [self surfaceForRect:frame];
    IOSurfaceLock(surface, 0, NULL);
    CARenderServerRenderLayerWithTransform(MACH_PORT_NULL, [self.target.window _contextId], (uint64_t)self.target.layer, surface, 0, 0, &transform);
    
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
    CGFloat inputRadius = [[self.target class] blurRadius] * [UIScreen mainScreen].scale;
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
    
    CGFloat s = [[self.target class] saturationDeltaFactor];
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

- (void)dealloc
{
    NSLog(@"\n\n\n\ndealloc PWWallpaperBlur");
    [super dealloc];
}

@end
