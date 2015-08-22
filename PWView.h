//
//  PWView.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-21.
//
//

extern NSString * const PWDidUpdateOptionsNotification;
extern NSString * const PWLoadingDidFailNotification;
extern NSString * const PWLoadingDidFinishNotification;

@class PWView;
@protocol PWViewDelegate <NSObject>
@required
- (void)updateBlurForView:(PWView *)view;
@end

@interface PWView : UIView
@property (nonatomic) int referenceCount;
@property (nonatomic, assign) id <PWViewDelegate>delegate;
@property (nonatomic, retain) UIColor *averageColor;
- (NSData *)thumbnail;
- (BOOL)supportsAverageColor;
- (void)viewWillTransitionToSize:(CGSize)size;
- (void)toggleButtonClicked:(int)toggleIndex;
- (void)updateOptionsWithValue:(id)value forKey:(NSString *)key;
- (void)loadingFailedWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage;
- (void)loadingFinished;
- (void)resume;
- (void)pause;
@end
