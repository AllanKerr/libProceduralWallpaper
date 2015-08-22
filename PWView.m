//
//  PWView.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//





//apt record


#import "PWView.h"

NSString * const PWDidUpdateOptionsNotification = @"PWDidUpdateOptionsNotification";
NSString * const PWLoadingDidFailNotification = @"PWLoadingDidFailNotification";
NSString * const PWLoadingDidFinishNotification = @"PWLoadingDidFinishNotification";

@interface PWView ()
@property (readwrite, atomic, retain) NSDictionary *options;
@end

@implementation PWView

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; referenceCount:%i isPaused:%i>", [self class], self, self.referenceCount, self.layer.speed == 0.0f];
}

- (BOOL)supportsAverageColor
{
    return YES;
}

- (id)init
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    return [super initWithFrame:bounds];
}

- (void)toggleButtonClicked:(int)toggleIndex
{
    
}

- (void)updateOptionsWithValue:(id)value forKey:(NSString *)key
{
    if (value == nil) {
        value = [NSNull null];
    }
    [self performOnMainThread:^{
        NSDictionary *userInfo = @{@"value" : value, @"key" : key};
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter postNotificationName:PWDidUpdateOptionsNotification object:self userInfo:userInfo];
    }];
}

- (void)loadingFailedWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage
{
    [self performOnMainThread:^{
        NSAssert1(title != nil, @"title can not be nil:%@", title);
        NSAssert1(errorMessage != nil, @"errorMessage can not be nil:%@", errorMessage);
        
        NSDictionary *userInfo = @{@"title" : title, @"errorMessage" : errorMessage};
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter postNotificationName:PWLoadingDidFailNotification object:self userInfo:userInfo];
    }];
}

- (void)loadingFinished
{
    [self performOnMainThread:^{
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter postNotificationName:PWLoadingDidFinishNotification object:self];
    }];
    [self.delegate updateBlurForView:self];
}

- (void)performOnMainThread:(void(^)())block
{
    if ([NSThread isMainThread] == YES) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (NSData *)thumbnail
{
    // Downsampled to half the size because the thumbnails are not displayed fullscreen
    CGSize size = CGSizeMake(0.5f * CGRectGetWidth(self.frame), 0.5f * CGRectGetHeight(self.frame));
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);

    [self drawViewHierarchyInRect:(CGRect){CGPointZero, size} afterScreenUpdates:NO];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    return UIImagePNGRepresentation(thumbnail);    
}

- (void)viewWillTransitionToSize:(CGSize)size
{

}

- (void)resume
{
    if (self.layer.speed == 0.0f) {
        NSLog(@"\n\n\n\n RESUME");
        CFTimeInterval pausedTime = [self.layer timeOffset];
        self.layer.speed = 1.0f;
        self.layer.timeOffset = 0.0f;
        self.layer.beginTime = 0.0f;
        CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.layer.beginTime = timeSincePause;
    }
}

- (void)pause
{
    if (self.layer.speed == 1.0f) {
        NSLog(@"\n\n\n\n PAUSE");
        CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.layer.speed = 0.0f;
        self.layer.timeOffset = pausedTime;
    }
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\ndealloc PWView");
    [_averageColor release];
    [super dealloc];
}

@end
