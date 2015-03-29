//
//  PLWallpaperImageViewController.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-11-16.
//
//

#import "PLUIEditImageViewController.h"
#import "SBSUIWallpaperPreviewViewController.h"

@interface PLWallpaperImageViewController : PLUIEditImageViewController
- (SBSUIWallpaperPreviewViewController *)wallpaperPreviewViewController;
- (void)cropOverlayWasCancelled:(PLCropOverlay *)crop;
- (void)_cropWallpaperFinished:(PLCropOverlay *)crop;
- (void)setImageAsHomeScreenAndLockScreenClicked:(id)sender;
- (void)setImageAsLockScreenClicked:(id)sender;
- (void)setImageAsHomeScreenClicked:(id)sender;
@end
