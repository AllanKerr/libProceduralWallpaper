//
//  PWWallpaper.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWWallpaper.h"
#import "PWWallpaperBlur.h"
#import "PWWallpaperCache.h"

static PWWallpaperCache *_wallpaperCache = nil;

@interface PWWallpaper ()
@property (nonatomic, assign) PWView *activeView;
@property (nonatomic, assign) PWWallpaperCache *wallpaperCache;
@property (nonatomic, retain) PWWallpaperBlur *wallpaperBlur;
@property (nonatomic, assign) NSTimer *orientationTimer;
@property (nonatomic, retain) CADisplayLink *displayLink;
@end

@implementation PWWallpaper
@synthesize delegate = _delegate;
@dynamic wallpaperCache;

+ (BOOL)colorChangesSignificantly
{
    return NO;
}

+ (int)blurFrameInterval
{
    return 5;
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

+ (BOOL)dynamicBlur
{
    return YES;
}

+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

+ (NSString *)factoryIdentifier
{
    return [NSString stringWithFormat:@"%@Factory", self];
}

// PWWallpaperCache is shared between all instances of PWWallpaper
// This is done because iOS 8 handles procedural wallpapers with a single PWWallpaper for both lock and home screen that handles two views
// NOTE:    This is assumed be to be an optimization in iOS 8 due to the default procedural wallpapers sharing the same design
//          All that differs is background color which can be changed dynamically without the overhead of multiple views
// In iOS 7 two PWWallpapers are created each with their own UIView
// In order to handle these two design patterns PWWallpaperCache is shared between all PWWallpapers
// The referenceCount must manually be tracked due to any one wallpaper lacking explicit ownership

- (PWWallpaperCache *)wallpaperCache
{
    return _wallpaperCache;
}

- (void)setWallpaperCache:(PWWallpaperCache *)wallpaperCache
{
    _wallpaperCache = wallpaperCache;
}

- (void)setAnimating:(BOOL)animating
{
    if (animating) {
        [self.activeView resume];
    } else {
        [self.activeView pause];
    }
    if ([self.class dynamicBlur]) {
        self.displayLink.paused = !animating;
    }
}

- (id)init
{
    if (self = [super init]) {
        [self _initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    NSLog(@"\n\n\n\n\n_initialize PWWallpaper:%@", [self class]);
    if (self.wallpaperCache == nil) {
        self.wallpaperCache = [[[PWWallpaperCache alloc] init] autorelease];
    }
    [self.wallpaperCache retain];
    
    self.wallpaperCache.referenceCount++;
    self.autoresizesSubviews = YES;
    
    // PWWallpaperBlur is an intermediate class to avoid the retain cycle imposed by CADisplayLink targeting self
    self.wallpaperBlur = [[[PWWallpaperBlur alloc] initWithTarget:self] autorelease];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self.wallpaperBlur selector:@selector(updateBlurs)];
    self.displayLink.frameInterval = [self.class blurFrameInterval];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = ![self.class dynamicBlur];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRemoveWallpaper:) name:@"PWWillRemoveWallpaper" object:nil];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (![self.class dynamicBlur]) {
        self.displayLink.paused = NO;
        if (self.orientationTimer) {
            [self.orientationTimer invalidate];
        } else {
            NSLog(@"\n\n\n\n\n START");
        }
        CGFloat duration = 2.0f * [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
        self.orientationTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(orientationUpdated) userInfo:nil repeats:NO];
    }
}

- (void)resizeSubviewsWithOldSize:(CGSize)size
{
    [super resizeSubviewsWithOldSize:size];
    NSLog(@"\n\n\n\n RESIZE");
}

- (void)orientationUpdated
{
    self.displayLink.paused = YES;
    [self.wallpaperBlur updateBlurs];
    NSLog(@"\n\n\n\n\n STOP");

    [self.orientationTimer invalidate];
    self.orientationTimer = nil;
}

// A notification is used to clear the active view to prevent access to a deallocated object
// Delegation can't be used because there are an indeterminate number of PWWallpapers per PWWallpaperCache

- (void)willRemoveWallpaper:(NSNotification *)notification
{
    if (self.activeView == notification.object) {
        self.activeView = nil;
    }
}

- (NSData *)generateThumbnail
{
    CGSize size = self.bounds.size;
    size.width *= 0.5f;
    size.height *= 0.5f;
    
    UIGraphicsBeginImageContext(size);
    [self drawViewHierarchyInRect:(CGRect){CGPointZero, size} afterScreenUpdates:NO];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(thumbnail);
}

- (void *)copyBlurForRect:(CGRect *)rect
{
    return [self.wallpaperBlur computeBlurs];
}

- (void)setWallpaperOptions:(NSDictionary *)options
{    
    PWView *view = [self.wallpaperCache wallpaperForOptions:options];
    if (view && view != self.activeView) {
        [self.activeView setHidden:YES];
        [self.activeView pause];
        self.activeView = view;
    }
    [view setHidden:NO];
    [self addSubview:view];
}

- (void)updateWallpaperOptions:(NSDictionary *)options newWallpaper:(BOOL)newWallpaper
{
    if (newWallpaper) {
        
    } else {
        [self.activeView updateWithOptions:options];
    }
}

- (UIColor *)averageLifetimeColor
{
    return [UIColor blackColor];//[self.activeView averageColor];
}

- (void)dealloc
{
    _wallpaperCache.referenceCount--;
    BOOL dereferenced = _wallpaperCache.referenceCount <= 0;
    [_wallpaperCache release];
    if (dereferenced) {
        _wallpaperCache = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_displayLink != nil) {
        [_displayLink invalidate];
        [_displayLink release];
    }
    [_wallpaperBlur release];
    [super dealloc];
    NSLog(@"\n\n\n\n\ndealloc PWWallpaper");
}

@end
