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

@interface PWView : UIView
@property (nonatomic) int referenceCount;
- (NSData *)thumbnail;
- (void)resume;
- (void)pause;

/* Average color of the wallpaper is computed for folder background colors. The default is YES. For wallpapers with large variance in color the average color visually unappealing. In this case, -supportsAverageColor should be subclassed to return NO.
 */
- (BOOL)supportsAverageColor;

/*  NOTE: AUTO RESIZE MASKS ARE NOT SUPPORTED
    Subclass to resize CALayer upon orientation change. Resizing MUST be done manually. Using -setAutoResizesSubviews in the subclass or any subviews will cause the interface to lock upon orientation change.
 */
- (void)viewWillTransitionToSize:(CGSize)size;

/*  When using -addToggleWithName:values: in PWWallpaperPreviewController -toggleButtonClicked: will be called. Override to modify the wallpaper based on the toggled value.
 */
- (void)toggleButtonClicked:(int)toggleIndex;

/*  When overriding toggleButtonClicked: this method can be used to update the options used to load the wallpaper. [self updateOptionsWithValue:@"{0.5, 0.5, 0.5, 1.0}" forKey:@"color"]; will add this value to the options NSDictionary passed to -initializeWallpaperWithOptions:
 */
- (void)updateOptionsWithValue:(id)value forKey:(NSString *)key;

/*  When previewing a wallpaper from PWWallpaperPreviewController this will present a UIAlertView with the title and message. An example usage would be fetching weather data from the network failing.
 */
- (void)loadingFailedWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage;

/* [self loadingFinished] MUST be called if the PWView subclass loads successfully. When loadingFinished is called the loading indicator is removed and the user is allowed to set the wallpaper.
 */
- (void)loadingFinished;
@end
