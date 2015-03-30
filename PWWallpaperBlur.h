//
//  PWWallpaperBlur.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-30.
//
//

#import "PWWallpaper.h"

@interface PWWallpaperBlur : NSObject
- (id)initWithTarget:(PWWallpaper *)target;
- (void)updateBlurs:(CADisplayLink *)displayLink;
- (void *)computeBlurs;
@end
