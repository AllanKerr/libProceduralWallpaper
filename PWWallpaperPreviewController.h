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
- (void)wallpaperPreviewController:(PWWallpaperPreviewController *)wallpaperPreviewController willFinishWithOptions:(NSDictionary *)options;
- (void)wallpaperPreviewControllerWillCancel:(PWWallpaperPreviewController *)wallpaperPreviewController;
@end

@interface PWWallpaperPreviewController : PLMagicWallpaperImageViewController <UIAlertViewDelegate>
@property (nonatomic, assign) id <PWWallpaperPreviewDelegate>previewDelegate;

/*  Used to preview procedural wallpapers, the identifier must be equal to the PWWallpaper subclass name. Options are passed to PWWallpaper -initializeWallpaperWithOptions:
 */
+ (id)controllerWithIdentifier:(NSString *)identifier options:(NSDictionary *)options asyncWallpaperLoading:(BOOL)asyncWallpaperLoading;
/*  Adds a toggle allow the user to configure the wallpaper while previewing. This is comparable to the perspective zoom button when previewing still wallpapers.
 */
- (void)addToggleWithName:(NSString *)name values:(NSArray *)values;
@end
