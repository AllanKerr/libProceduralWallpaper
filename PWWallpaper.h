//
//  PWWallpaper.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "SBFProceduralWallpaper.h"
#import "PWWallpaperFactory.h"
 
@interface PWWallpaper : SBFProceduralWallpaper
@property (nonatomic, assign) id <SBFProceduralWallpaperDelegate> delegate;
+ (BOOL)dynamicBlur;
+ (int)blurFrameInterval;
+ (float)blurRadius;
+ (float)blurScale;
+ (float)saturationDeltaFactor;
+ (NSString *)factoryIdentifier;
- (void)updateWallpaperOptions:(NSDictionary *)options newWallpaper:(BOOL)newWallpaper;
@end
 