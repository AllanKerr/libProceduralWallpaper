//
//  PLMagicWallpaperImageViewController.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-11-16.
//
//

#import "PLWallpaperImageViewController.h"

@interface PLMagicWallpaperImageViewController : PLWallpaperImageViewController
- (id)initWithMagicWallpaper:(NSDictionary *)wallpaper options:(NSDictionary *)options;
- (void)loadView;
@end