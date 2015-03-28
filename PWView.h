//
//  PWView.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//

#import "SBFProceduralWallpaperDelegate.h"

@interface CALayer (Pause)
- (void)resume;
- (void)pause;
@end

@interface PWView : UIView
@property (nonatomic) BOOL isPaused;
@property (nonatomic) int referenceCount;
@property (nonatomic, assign) id <SBFProceduralWallpaperDelegate> delegate;
- (void)resume;  
- (void)pause;
@end
