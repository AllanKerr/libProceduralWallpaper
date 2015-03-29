//
//  WallpaperMagicGridViewController.h
//  WeatherBoard
//
//  Created by Allan Kerr on 2014-12-23.
//
//

#import "WallpaperMagicGridViewControllerSpec.h"
#import "PUPhotosGridViewController.h"

@interface WallpaperMagicGridViewController : PUPhotosGridViewController <NSFileManagerDelegate>
- (id)initWithSpec:(WallpaperMagicGridViewControllerSpec *)spec;
- (void)_setVariantBeingPreviewed:(NSDictionary *)variant;
@end
