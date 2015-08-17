//
//  PWWallpaper.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "SBFProceduralWallpaper.h"
#import "PWView.h"

extern NSString *const kSBUIMagicWallpaperIdentifierKey;
extern NSString *const kSBUIMagicWallpaperPresetOptionsKey;
extern NSString *const kSBUIMagicWallpaperThumbnailNameKey;
extern NSString *const kSBProceduralWallpaperHomeOptionsKey;
extern NSString *const kSBProceduralWallpaperLockOptionsKey;

@interface PWWallpaper : SBFProceduralWallpaper <PWViewDelegate>
@property (readonly, nonatomic, assign) PWView *activeView;
@property (nonatomic, assign) id <SBFProceduralWallpaperDelegate> delegate;
- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options;
@end
 