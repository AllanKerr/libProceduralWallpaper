//
//  SBFProceduralWallpaperDelegate.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2014-10-24.
//
//

@protocol SBFProceduralWallpaperDelegate <NSObject>
@required
- (void)wallpaper:(id)arg1 didGenerateBlur:(void *)arg2 forRect:(CGRect)arg3;
- (void)wallpaper:(id)arg1 didComputeAverageColor:(id)arg2 forRect:(CGRect)arg3;
@end 
