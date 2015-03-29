//
//  PWWallpaperPreviewController.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-29.
//
//

#import "PLMagicWallpaperImageViewController.h"

extern NSString *const kSBUIMagicWallpaperIdentifierKey;
extern NSString *const kSBUIMagicWallpaperPresetOptionsKey;

@interface PWWallpaperPreviewController : PLMagicWallpaperImageViewController
+ (id)controllerWithWallpaperOptions:(NSDictionary *)options;
- (void)beginAsyncWallpaperLoading;
- (void)endAsyncWallpaperLoadingWithOptions:(NSDictionary *)options success:(BOOL)success;
@end
