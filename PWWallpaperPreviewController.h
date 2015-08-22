//
//  PWWallpaperPreviewController.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-29.
//
//

#import "PLMagicWallpaperImageViewController.h"

@class PWWallpaperPreviewController;
@protocol PWWallpaperPreviewDelegate <NSObject>
@optional
- (void)wallpaperPreviewController:(PWWallpaperPreviewController *)wallpaperPreviewController willSetWallpaperForVariant:(int)variant;
- (void)wallpaperPreviewControllerWillFinish:(PWWallpaperPreviewController *)wallpaperPreviewController;
- (void)wallpaperPreviewControllerWillCancel:(PWWallpaperPreviewController *)wallpaperPreviewController;
@end

@interface PWWallpaperPreviewController : PLMagicWallpaperImageViewController <UIAlertViewDelegate>
@property (nonatomic, assign) id <PWWallpaperPreviewDelegate>previewDelegate;
- (NSDictionary *)previewOptions;
+ (id)controllerWithIdentifier:(NSString *)identifier options:(NSDictionary *)options asyncWallpaperLoading:(BOOL)asyncWallpaperLoading;
- (void)addToggleWithName:(NSString *)name values:(NSArray *)values;
@end
