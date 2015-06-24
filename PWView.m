//
//  PWView.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//

#import "PWView.h"

@implementation CALayer (Pause)

// CALayers and UIViews can only be paused in this manner if they don't support auto-resizing
// Lone CALayers can be paused because auto-resizing is handled at the UIView level
// UIViews set to UIViewAutoresizingNone can also be paused
// Note: If a layer that supports auto-resizing is paused in this manner it will lock all interface elements in SpringBoard

- (void)resume
{
    if (self.speed == 0.0f) {
        CFTimeInterval pausedTime = [self timeOffset];
        self.speed = 1.0f;
        self.timeOffset = 0.0f;
        self.beginTime = 0.0f;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
}

- (void)pause
{
    UIView *view = self.delegate;
    if (view == nil || ([view isKindOfClass:[UIView class]] && view.autoresizingMask == UIViewAutoresizingNone)) {
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0.0f;
        self.timeOffset = pausedTime;
    }
}

@end

@implementation PWView
{
    UIColor *_averageColor;
}

- (id)init
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    return [self initWithFrame:bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

- (void)updateWithOptions:(NSDictionary *)options
{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; isPaused:%i>", [self class], self, self.isPaused];
}

- (UIColor *)averageColor
{
    return [UIColor blackColor];
}

// Pausing and resuming of UIViews that support auto-resizing must be done by overriding -resume and -pause
// It is important to call [super resume] and [super pause] when they are overridden

- (void)resume
{
    if (self.isPaused) {
        for (CALayer *layer in self.layer.sublayers) {
            [layer resume];
        }
        self.isPaused = NO;
    }
}

- (void)pause
{
    if (!self.isPaused) {
        for (CALayer *layer in self.layer.sublayers) {
            [layer pause];
        }
        self.isPaused = YES;
    }
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\ndealloc PWView");
    [_averageColor release];
    [super dealloc];
}

@end
