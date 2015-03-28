//
//  SBFProceduralWallpaper.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-10-02.
//
//

#import "SBFProceduralWallpaperDelegate.h"

@interface SBFProceduralWallpaper : UIView
@property (nonatomic, assign) id <SBFProceduralWallpaperDelegate> *delegate;
+ (NSString *)identifier;
- (UIView *)view; 
- (void)setAnimating:(BOOL)animating;
@end
