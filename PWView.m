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
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0f;
    self.timeOffset = pausedTime;

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutSublayers];
}

- (void)layoutSublayers
{
    
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\ndealloc PWView");
    [_averageColor release];
    [super dealloc];
}

@end
