//
//  PWWallpaperPreviewController.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-29.
//
//

#import "PLMagicWallpaperImageViewController.h"

@interface PWWallpaperPreviewController : PLMagicWallpaperImageViewController <UIAlertViewDelegate>
+ (id)controllerWithIdentifier:(NSString *)identifier options:(NSDictionary *)options asyncWallpaperLoading:(BOOL)asyncWallpaperLoading;
- (void)addToggleWithName:(NSString *)name values:(NSArray *)values;
@end
