//
//  PWView.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//

@interface PWView : UIView
@property (nonatomic) BOOL isPaused;
@property (nonatomic) int referenceCount;
- (void)updateWithOptions:(NSDictionary *)options;
- (void)resume;  
- (void)pause;
@end
