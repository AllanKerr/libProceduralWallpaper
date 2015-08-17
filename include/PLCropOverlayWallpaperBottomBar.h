//
//  PLCropOverlayWallpaperBottomBar.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-12-29.
//
//

#import "PLWallpaperButton.h"

@interface PLCropOverlayWallpaperBottomBar : UIView
- (void)setMotionToggleHidden:(BOOL)hidden;
- (PLWallpaperButton *)doSetButton;
- (PLWallpaperButton *)doSetBothScreenButton;
- (PLWallpaperButton *)doSetLockScreenButton;
- (PLWallpaperButton *)doSetHomeScreenButton;
- (PLWallpaperButton *)motionToggle;
@end
