//
//  PWWallpaperPreviewController.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-29.
//
//

#import "PWWallpaperPreviewController.h"
#import "WallpaperMagicGridViewControllerSpec.h"
#import "WallpaperMagicGridViewController.h"
#import "PWWallpaper.h"

NSString *const kSBUIMagicWallpaperIdentifierKey = @"kSBUIMagicWallpaperIdentifierKey";
NSString *const kSBUIMagicWallpaperPresetOptionsKey = @"kSBUIMagicWallpaperPresetOptionsKey";
NSString *const kSBUIMagicWallpaperThumbnailNameKey = @"kSBUIMagicWallpaperThumbnailNameKey";

@interface PWWallpaperPreviewController ()
@property (nonatomic) BOOL setButtonEnabled;
@property (nonatomic) BOOL asyncWallpaperLoading;
@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) WallpaperMagicGridViewController *gridViewController;
@end

@implementation PWWallpaperPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // CropOverlay is nil until viewDidLoad is called
    // Allows for -beginAsyncWallpaperLoading to be called before presenting PWWallpaperPreviewController
    if (self.asyncWallpaperLoading) {
        [self initializeLoadingIndicator];
    }
    self.cropOverlay.wallpaperBottomBar.doSetButton.enabled = self.setButtonEnabled;
}

- (PWWallpaper *)contentView
{
    // Returns the PWWallpaper subclass
    return [[[self wallpaperPreviewViewController] _wallpaperView] contentView];
}

- (NSDictionary *)wallpaperForOptions:(NSDictionary *)options
{
    NSString *identifier = [options valueForKey:kSBUIMagicWallpaperIdentifierKey];
    if (identifier == nil) {
        // assertion for nil identifier
    }
    // Mutable options are needed for adding the thumbnail once its been created and updating the options in the case of asynchronous wallpaper loading
    return @{kSBUIMagicWallpaperIdentifierKey : identifier, kSBUIMagicWallpaperPresetOptionsKey : [[options mutableCopy] autorelease]};
}

+ (id)controllerWithWallpaperOptions:(NSDictionary *)options
{
    return [[[self alloc] initWithWallpaperOptions:options] autorelease];
}

- (id)initWithWallpaperOptions:(NSDictionary *)options
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/Wallpaper.bundle"];
    if (!bundle.loaded) {
        [bundle load];
    }
    NSDictionary *wallpaper = [self wallpaperForOptions:options];
    if (self = [super initWithMagicWallpaper:wallpaper options:nil]) {
        WallpaperMagicGridViewControllerSpec *spec;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            spec = [[[NSClassFromString(@"WallpaperMagicAlbumViewControllerPadSpec") alloc] init] autorelease];
        } else {
            spec = [[[NSClassFromString(@"WallpaperMagicAlbumViewControllerPhoneSpec") alloc] init] autorelease];
        }
        // WallpaperMagicGridViewController is the view controller responsible for displaying the wallpapers in a grid pattern
        // It is also responsible for the handling delegate methods called when the wallpaper is set and sending the message to SpringBoard
        // SBSetProceduralWallpaper is called which is part of SpringBoard's MIG subsystem
        self.gridViewController = [[[NSClassFromString(@"WallpaperMagicGridViewController") alloc] initWithSpec:spec] autorelease];
        [self.gridViewController _setVariantBeingPreviewed:wallpaper];
        [self setDelegate:self.gridViewController];
        
        // WallpaperPreviewNavigationController is responsible for orientation of wallpaper previews
        // Retained as self.navigationController during -initWithRootViewController:
        [[[NSClassFromString(@"WallpaperPreviewNavigationController") alloc] initWithRootViewController:self] autorelease];
        
        self.asyncWallpaperLoading = NO;
        self.setButtonEnabled = YES;
    }
    return self;
}

- (void)initializeLoadingIndicator
{
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    self.activityIndicator.center = [self.cropOverlay convertPoint:self.cropOverlay.center fromView:self.cropOverlay.superview];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.cropOverlay addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopLoadingIndicator
{
    NSLog(@"\n\n\n\n setButton:%i", self.setButtonEnabled);
    self.cropOverlay.wallpaperBottomBar.doSetButton.enabled = self.setButtonEnabled;
    [self.activityIndicator stopAnimating];
}

- (void)beginAsyncWallpaperLoading
{
    self.setButtonEnabled = NO;
    self.asyncWallpaperLoading = YES;
    if (self.cropOverlay) {
        self.cropOverlay.wallpaperBottomBar.doSetButton.enabled = self.setButtonEnabled;
        [self initializeLoadingIndicator];
    }
}

- (void)asyncWallpaperLoadingFailedWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage
{
    self.asyncWallpaperLoading = NO;
    if (self.cropOverlay != nil) {
        [self stopLoadingIndicator];
    }
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self cropOverlayWasCancelled:self.cropOverlay];
    }
}

- (void)endAsyncWallpaperLoadingWithOptions:(NSDictionary *)options newWallpaper:(BOOL)newWallpaper
{
    self.setButtonEnabled = YES;
    self.asyncWallpaperLoading = NO;
    if (self.cropOverlay != nil) {
        [self stopLoadingIndicator];
    }
    NSDictionary *wallpaper = [self wallpaperForOptions:options];
    [self.gridViewController _setVariantBeingPreviewed:wallpaper];
    [self.contentView updateWallpaperOptions:options newWallpaper:newWallpaper];
}  

- (void)cropOverlayWasCancelled:(PLCropOverlay *)overlay
{
    [super cropOverlayWasCancelled:overlay];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)_cropWallpaperFinished:(PLCropOverlay *)overlay
{
    [super _cropWallpaperFinished:overlay];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setImageAsHomeScreenAndLockScreenClicked:(id)sender
{
    [self setThumbnail:@"ProceduralShared_thumb"];
    [super setImageAsHomeScreenAndLockScreenClicked:sender];
}

- (void)setImageAsLockScreenClicked:(id)sender
{
    [self setThumbnail:@"ProceduralLock_thumb"];
    [super setImageAsLockScreenClicked:sender];
}

- (void)setImageAsHomeScreenClicked:(id)sender
{
    [self setThumbnail:@"ProceduralHome_thumb"];
    [super setImageAsHomeScreenClicked:sender];
}

- (void)setThumbnail:(NSString *)name
{
    /*NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.theronen.weatherwallpapers"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", name];
    NSArray *files = [bundle pathsForResourcesOfType:@".png" inDirectory:nil];
    for (NSString *path in [files filteredArrayUsingPredicate:predicate]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    NSString *filename = [NSString stringWithFormat:@"%@-%.f.png", name, 10.0f * [[NSDate date] timeIntervalSince1970]];
    NSURL *url = [NSURL URLWithString:filename relativeToURL:bundle.bundleURL];
    NSData *thumbnail = [self.contentView generateThumbnail];
    [thumbnail writeToURL:url atomically:NO];
    
    NSMutableDictionary *options = [self.wallpaperPreviewViewController.proceduralWallpaper valueForKey:@"kSBUIMagicWallpaperPresetOptionsKey"];
    [options setValue:filename forKey:@"kSBUIMagicWallpaperThumbnailNameKey"];*/
}

- (void)dealloc
{
    [_gridViewController release];
    [super dealloc];
}

@end
