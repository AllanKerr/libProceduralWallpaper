//
//  PWWallpaperPreviewView.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-07-03.
//
//

#import "SBSUIWallpaperPreviewView.h"

@interface PWWallpaperPreviewView : SBSUIWallpaperPreviewView
+ (id)viewWithPreviewView:(SBSUIWallpaperPreviewView *)previewView;
- (SBSUIWallpaperMotionButton *)motionButton;
@end
