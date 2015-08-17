//
//  PWWallpaperPreviewView.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-07-03.
//
//

#import "PWWallpaperPreviewView.h"
#import "PWToggleButton.h"
#import "PWWallpaper.h"
#include <objc/runtime.h>

@implementation PWWallpaperPreviewView

- (PWWallpaper *)contentView
{
    // Returns the PWWallpaper subclass
    return [[self wallpaperView] contentView];
}

- (SBSUIWallpaperMotionButton *)motionButton
{
    return [self valueForKey:@"_motionButton"];
}

+ (id)viewWithPreviewView:(SBSUIWallpaperPreviewView *)previewView
{
    if ([previewView isKindOfClass:[PWWallpaperPreviewView class]] == NO) {
        object_setClass(previewView, [PWWallpaperPreviewView class]);
    }
    return (PWWallpaperPreviewView *)previewView;
}

- (void)_toggleMotion
{
    int toggleIndex = ((PWToggleButton *)[self motionButton]).toggleIndex;
    [[self contentView].activeView toggleButtonClicked:toggleIndex];
}

@end
