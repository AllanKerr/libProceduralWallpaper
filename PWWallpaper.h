//
//  PWWallpaper.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "SBFProceduralWallpaper.h"
#import "PWView.h"

@interface PWWallpaper : SBFProceduralWallpaper
@property (readonly, nonatomic, assign) PWView *activeView;
@property (nonatomic, assign) id <SBFProceduralWallpaperDelegate> delegate;

/* Called whenever a new procedural wallpaper is created. Must be overriden in the PWWallpaper subclass. This method is reponsible for returning a valid PWView subclass.
 */
- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options;
@end
 