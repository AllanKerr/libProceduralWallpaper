//
//  PWToggleButton.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-07-03.
//
//

#import "SBSUIWallpaperMotionButton.h"

@interface PWToggleButton : SBSUIWallpaperMotionButton
@property (readonly, nonatomic, assign) int toggleIndex;
+ (id)buttonWithMotionButton:(SBSUIWallpaperMotionButton *)motionButton name:(NSString *)name values:(NSArray *)values;
@end
