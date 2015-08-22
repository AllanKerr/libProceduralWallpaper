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
#import "PLWallpaperButton.h"
#import "PWWallpaper.h"
#import "SBSUIConstants.h"

#import "PWWallpaperPreviewView.h"
#import "PWToggleButton.h"

static NSString *const PWApplicationSupport = @"libProceduralWallpaper";

@interface PWWallpaperPreviewController ()
@property (nonatomic) BOOL asyncWallpaperLoading;
@property (nonatomic) BOOL toggleEnabled;
@property (nonatomic) int toggleIndex;
@property (nonatomic, copy) NSString *toggleName;
@property (nonatomic, copy) NSArray *toggleValues;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) WallpaperMagicGridViewController *gridViewController;
@end
 
@implementation PWWallpaperPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // PLCropOverlay is not initialized until after -viewLoad
    if (self.toggleEnabled == YES) {
        [self initializeToggle];
    }
    if (self.asyncWallpaperLoading == YES) {
        [self initializeLoadingIndicator];
    }
}

- (PWView *)previewView
{
    return [[[self wallpaperPreviewViewController] _wallpaperView] contentView].activeView;
}

- (NSDictionary *)wallpaperForIdentifier:(NSString *)identifier options:(NSDictionary *)options
{
    NSAssert1(identifier != nil, @"Invalid value for %@", kSBUIMagicWallpaperIdentifierKey);
    [options setValue:identifier forKey:kSBUIMagicWallpaperIdentifierKey];
    return @{kSBUIMagicWallpaperIdentifierKey : identifier, kSBUIMagicWallpaperPresetOptionsKey : options};
}

+ (id)controllerWithIdentifier:(NSString *)identifier options:(NSDictionary *)options asyncWallpaperLoading:(BOOL)asyncWallpaperLoading
{
    return [[[self alloc] initWithIdentifier:identifier options:options asyncWallpaperLoading:asyncWallpaperLoading] autorelease];
}

- (id)initWithIdentifier:(NSString *)identifier options:(NSDictionary *)options asyncWallpaperLoading:(BOOL)asyncWallpaperLoading
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/Wallpaper.bundle"];
    if (!bundle.loaded) {
        [bundle load];
    }
    // It is dangerous to modify self before calling the super class initializer
    // All modifications must ONLY modify PWWallpaperPreviewController properties
    // This is done because SpringBoardFoundation does not support the async loading of wallpapers
    // In order to avoid the race condition of finishing wallpaper loading before the body of init is called the notifications must be subscribed to before
    
    // Mutable options are needed for adding the thumbnail once its been created and updating the options in the case of asynchronous wallpaper loading
    self.options = [[options mutableCopy] autorelease];
    self.asyncWallpaperLoading = asyncWallpaperLoading;

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(didUpdateOptionsNotification:) name:PWDidUpdateOptionsNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(loadingDidFinishNotification:) name:PWLoadingDidFinishNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(loadingDidFailNotification:) name:PWLoadingDidFailNotification object:nil];

    NSDictionary *wallpaper = [self wallpaperForIdentifier:identifier options:self.options];
    if (self = [super initWithMagicWallpaper:wallpaper options:nil]) {
        
        WallpaperMagicGridViewControllerSpec *spec;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            spec = [[[NSClassFromString(@"WallpaperMagicAlbumViewControllerPadSpec") alloc] init] autorelease];
        } else {
            spec = [[[NSClassFromString(@"WallpaperMagicAlbumViewControllerPhoneSpec") alloc] init] autorelease];
        }
        // WallpaperMagicGridViewController is the view controller responsible for displaying the wallpapers in a grid pattern
        // It is also responsible for handling delegate methods called when the wallpaper is set and sending the message to SpringBoard
        // SBSetProceduralWallpaper is called which is part of SpringBoard's MIG subsystem
        self.gridViewController = [[[NSClassFromString(@"WallpaperMagicGridViewController") alloc] initWithSpec:spec] autorelease];
        [self.gridViewController _setVariantBeingPreviewed:wallpaper];
        [self setDelegate:self.gridViewController];
        
        // WallpaperPreviewNavigationController is responsible for orientation of wallpaper previews
        // Retained as self.navigationController during -initWithRootViewController:
        [[[NSClassFromString(@"WallpaperPreviewNavigationController") alloc] initWithRootViewController:self] autorelease];
    }
    return self;
}

- (void)didUpdateOptionsNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *key = [userInfo valueForKey:@"key"];
    id value = [userInfo valueForKey:@"value"];
    
    if (value == [NSNull null]) {
        [self.options removeObjectForKey:key];
    } else {
        [self.options setValue:value forKey:key];
    }
}

- (void)loadingDidFinishNotification:(NSNotification *)notification
{
    self.asyncWallpaperLoading = NO;

    PLCropOverlayWallpaperBottomBar *bottomBar = [self.cropOverlay wallpaperBottomBar];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [bottomBar.doSetHomeScreenButton setEnabled:YES];
        [bottomBar.doSetLockScreenButton setEnabled:YES];
        [bottomBar.doSetBothScreenButton setEnabled:YES];
        [bottomBar.motionToggle setEnabled:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [bottomBar.doSetButton setEnabled:YES];
    }
    [self.activityIndicator stopAnimating];
}

- (void)loadingDidFailNotification:(NSNotification *)notification
{
    self.asyncWallpaperLoading = NO;

    NSDictionary *userInfo = notification.userInfo;
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *errorMessage = [userInfo valueForKey:@"errorMessage"];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
    
    [self.activityIndicator stopAnimating];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self cropOverlayWasCancelled:self.cropOverlay];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.activityIndicator.center = CGPointMake(size.width / 2, size.height / 2);
}

- (void)addToggleWithName:(NSString *)name values:(NSArray *)values
{
    self.toggleIndex = 0;
    self.toggleEnabled = YES;
    self.toggleName = name;
    self.toggleValues = values;
    [self initializeToggle];
}

- (void)initializeToggle
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PLCropOverlayWallpaperBottomBar *bottomBar = [self.cropOverlay wallpaperBottomBar];
        PLWallpaperButton *motionToggle = [bottomBar motionToggle];
        if (motionToggle) {
            NSString *toggleValue = [self.toggleValues objectAtIndex:self.toggleIndex];
            NSString *title = [NSString stringWithFormat:@"%@%@", self.toggleName, toggleValue];
            [motionToggle setTitle:title forState:UIControlStateNormal];
            [bottomBar setMotionToggleHidden:NO];
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        ////// alter this to remove the objc_runtime
        SBSUIWallpaperPreviewView *defaultPreviewView = [[self wallpaperPreviewViewController] _previewView];
        PWWallpaperPreviewView *previewView = [PWWallpaperPreviewView viewWithPreviewView:defaultPreviewView];
        
        SBSUIWallpaperMotionButton *motionButton = [previewView motionButton];
        [PWToggleButton buttonWithMotionButton:motionButton name:self.toggleName values:self.toggleValues];
    }
}

- (void)motionToggledManually:(BOOL)toggled
{
    PLCropOverlayWallpaperBottomBar *bottomBar = [self.cropOverlay wallpaperBottomBar];
    PLWallpaperButton *motionToggle = [bottomBar motionToggle];
    if (motionToggle) {
        self.toggleIndex++;
        if (self.toggleIndex >= self.toggleValues.count) {
            self.toggleIndex = 0;
        }
        NSString *toggleValue = [self.toggleValues objectAtIndex:self.toggleIndex];
        NSString *title = [NSString stringWithFormat:@"%@%@", self.toggleName, toggleValue];
        [motionToggle setTitle:title forState:UIControlStateNormal];
    }
    [self.previewView toggleButtonClicked:self.toggleIndex];
}

- (void)beginAsyncWallpaperLoading
{
    self.asyncWallpaperLoading = YES;
    [self initializeLoadingIndicator];
}

- (void)initializeLoadingIndicator
{
    if (self.asyncWallpaperLoading == YES && self.cropOverlay != nil) {
        PLCropOverlayWallpaperBottomBar *bottomBar = [self.cropOverlay wallpaperBottomBar];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            UIColor *disabledTextColor = [UIColor lightGrayColor];
            [bottomBar.doSetHomeScreenButton setTitleColor:disabledTextColor forState:UIControlStateDisabled];
            [bottomBar.doSetLockScreenButton setTitleColor:disabledTextColor forState:UIControlStateDisabled];
            [bottomBar.doSetBothScreenButton setTitleColor:disabledTextColor forState:UIControlStateDisabled];
            [bottomBar.motionToggle setTitleColor:disabledTextColor forState:UIControlStateDisabled];
            [bottomBar.doSetHomeScreenButton setEnabled:NO];
            [bottomBar.doSetLockScreenButton setEnabled:NO];
            [bottomBar.doSetBothScreenButton setEnabled:NO];
            [bottomBar.motionToggle setEnabled:NO];

        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [bottomBar.doSetButton setEnabled:NO];
        }
        self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        self.activityIndicator.center = CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds) / 2);
        self.activityIndicator.hidesWhenStopped = YES;
        [self.activityIndicator startAnimating];
        
        [self.cropOverlay addSubview:self.activityIndicator];
    }
}

- (void)cropOverlayWasCancelled:(PLCropOverlay *)overlay
{
    if ([self.previewDelegate respondsToSelector:@selector(wallpaperPreviewControllerWillCancel:)]) {
        [self.previewDelegate wallpaperPreviewControllerWillCancel:self];
    }
    [super cropOverlayWasCancelled:overlay];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)_cropWallpaperFinished:(PLCropOverlay *)overlay
{
    if ([self.previewDelegate respondsToSelector:@selector(wallpaperPreviewController: willFinishWithOptions:)]) {
        [self.previewDelegate wallpaperPreviewController:self willFinishWithOptions:self.options];
    }
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
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSSystemDomainMask, YES) objectAtIndex:0];
    NSString *applicationSupportPath = [basePath stringByAppendingPathComponent:PWApplicationSupport];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", name];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:nil];
    for (NSString *path in [files filteredArrayUsingPredicate:predicate]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    // Multiplied by 10 to prevent identical file names if the same wallpaper is set twice in one second
    NSString *filename = [NSString stringWithFormat:@"%@-%.f.png", name, 10.0f * [NSDate date].timeIntervalSince1970];
    NSString *path = [applicationSupportPath stringByAppendingPathComponent:filename];
    NSData *thumbnail = [self.previewView thumbnail];
    [thumbnail writeToFile:path atomically:YES];

    // All procedural wallpapers have a symoblic link pointing to the application support directory
    // This allows thumbnails to be saved to the libProceduralWallpaper support directory rather than the specific wallpaper bundles
    NSString *linkedPath = [PWApplicationSupport stringByAppendingPathComponent:filename];
    NSMutableDictionary *options = [[self.wallpaperPreviewViewController valueForKey:@"_proceduralWallpaper"] valueForKey:kSBUIMagicWallpaperPresetOptionsKey];
    [options setValue:linkedPath forKey:kSBUIMagicWallpaperThumbnailNameKey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_toggleName release];
    [_toggleValues release];
    [_gridViewController release];
    [_options release];
    [super dealloc];
}

@end
