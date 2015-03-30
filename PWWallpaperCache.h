//
//  PWWallpaperCache.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWWallpaperFactory.h"

@interface PWWallpaperCache : NSObject
@property (nonatomic) int referenceCount;
- (id <PWWallpaperFactory>)addFactoryForIdentifier:(NSString *)identifier;
- (PWView *)wallpaperForOptions:(NSDictionary *)options;
@end
