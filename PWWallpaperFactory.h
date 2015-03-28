//
//  PWWallpaperFactory.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWView.h"

@protocol PWWallpaperFactory <NSObject>
@required
- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options;
@optional
// called whenever a wallpaper created from this factory is deallocated
// allows for storing assets in the wallpaper factory and sharing them between wallpapers
- (void)clearUnusedAssets;
@end
