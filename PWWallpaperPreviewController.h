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
extern NSString *const kSBUIMagicWallpaperThumbnailNameKey;

@interface PWWallpaperPreviewController : PLMagicWallpaperImageViewController
+ (id)controllerWithWallpaperOptions:(NSDictionary *)options;
- (void)beginAsyncWallpaperLoading;
- (void)asyncWallpaperLoadingFailedWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage;
// -endAsyncWallpaperLoadingWithOptions: loadNewWallpaper: success:
// options ::   Dictionary containing the options for the new wallpaper
//              Allows for wallpapers to use asynchronous data, ex: current weather
// newWallpaper ::  YES creates and displays a new wallpaper using -initializeWallpaperWithOptions:
//                  NO sends options to the existing view
- (void)endAsyncWallpaperLoadingWithOptions:(NSDictionary *)options newWallpaper:(BOOL)newWallpaper;
@end
