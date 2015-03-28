//
//  PWView.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//

#import "PWView.h"

@implementation CALayer (Pause)

- (void)resume
{
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0f;
    self.timeOffset = 0.0f;  
    self.beginTime = 0.0f;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

- (void)pause
{
    self.timeOffset = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0f;
}

@end

/*@interface PWView ()
@property (nonatomic, retain) CADisplayLink *displayLink;
@end*/

@implementation PWView
{
    BOOL portrait;
    UIColor *_averageColor;
}

/*- (int)blurFrameInterval
{
    return 5;
}

- (float)blurRadius
{
    return 5.0f;
}

- (float)blurScale
{
    return 0.25f;
}

- (float)saturationDeltaFactor
{
    return 1.8f;
}*/

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        /*self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBlurs:)];
        self.displayLink.frameInterval = self.blurFrameInterval;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];*/
    }
    return self;
}

- (void)addSubview:(UIView *)subview
{
    subview.autoresizingMask = self.autoresizingMask;
    [super addSubview:subview];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; isPaused:%i>", [self class], self, self.isPaused];
}

- (UIColor *)averageColor
{
    return [UIColor blackColor];
}

- (void)resume
{
    self.isPaused = NO;
}

- (void)pause
{
    self.isPaused = YES;
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\ndealloc PWView");
    //[_displayLink invalidate];
    [_averageColor release];
    [super dealloc];
}

@end
