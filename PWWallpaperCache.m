//
//  PWWallpaperCache.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWWallpaperCache.h"

@implementation NSDictionary (Options)

- (NSDictionary *)dictionaryByRemovingThumbailKey
{
    NSMutableDictionary *mutableCopy = [[self mutableCopy] autorelease];
    [mutableCopy removeObjectForKey:@"kSBUIMagicWallpaperThumbnailNameKey"];
    return mutableCopy; 
}  

@end

@interface PWWallpaperCache ()
@property (nonatomic, retain) NSMutableDictionary *wallpapers;
@property (nonatomic, retain) id <PWWallpaperFactory> wallpaperFactory;
@end

@implementation PWWallpaperCache

- (id)initWithIdentifier:(NSString *)identifier wallpaperFactory:(id <PWWallpaperFactory>)wallpaperFactory
{
    if (self = [super init]) {
        NSLog(@"\n\n\n\n\n\ninit PWWallpaperCache");
        self.wallpaperFactory = wallpaperFactory;
        self.wallpapers = [NSMutableDictionary dictionaryWithCapacity:2];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[userDefaults stringForKey:@"kSBProceduralWallpaperHomeDefaultKey"] isEqualToString:identifier]) {
            NSDictionary *options = [userDefaults dictionaryForKey:@"kSBProceduralWallpaperHomeOptionsKey"];
            [self initializeWallpaperWithOptions:options].referenceCount++;
        }
        if ([[userDefaults stringForKey:@"kSBProceduralWallpaperLockDefaultKey"] isEqualToString:identifier]) {
            NSDictionary *options = [userDefaults dictionaryForKey:@"kSBProceduralWallpaperLockOptionsKey"];
            [self initializeWallpaperWithOptions:options].referenceCount++;
        }
        int observerOptions = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [userDefaults addObserver:self forKeyPath:@"kSBProceduralWallpaperHomeOptionsKey" options:observerOptions context:NULL];
        [userDefaults addObserver:self forKeyPath:@"kSBProceduralWallpaperLockOptionsKey" options:observerOptions context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    PWView *oldView = nil;
    NSDictionary *oldOptions = [change valueForKey:@"old"];
    if (![oldOptions isEqual:[NSNull null]] && [oldOptions valueForKey:@"kWBWeatherWallpaperTypeKey"]) {
        oldOptions = [oldOptions dictionaryByRemovingThumbailKey];
        oldView = [self.wallpapers objectForKey:oldOptions];
        oldView.referenceCount--;
    }
    NSDictionary *newOptions = [change valueForKey:@"new"];
    if (![newOptions isEqual:[NSNull null]] && [newOptions valueForKey:@"kWBWeatherWallpaperTypeKey"]) {
        newOptions = [newOptions dictionaryByRemovingThumbailKey];
        PWView *newView = [self initializeWallpaperWithOptions:newOptions];
        newView.referenceCount++;
    }
    if (oldView.referenceCount <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PWWillRemoveWallpaper" object:oldView];
        [oldView removeFromSuperview];
        [self.wallpapers removeObjectForKey:oldOptions];
        if ([self.wallpaperFactory respondsToSelector:@selector(clearUnusedAssets)]) {
            [self.wallpaperFactory clearUnusedAssets];
        }
    }
    NSLog(@"\n\n\n\nwallpapers:%@", self.wallpapers);
}

- (PWView *)wallpaperForOptions:(NSDictionary *)options
{
    if (!options) {
        return nil;
    }
    return [self initializeWallpaperWithOptions:options];
}

- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options
{
    options = [options dictionaryByRemovingThumbailKey];
    PWView *view = [self.wallpapers objectForKey:options];
    if (!view && options) {
        view = [self.wallpaperFactory initializeWallpaperWithOptions:options];
        [self.wallpapers setObject:view forKey:options];
    }
    return view;
}

- (void)dealloc
{
    NSLog(@"\n\n\n\n\n\ndealloc PWWallpaperCache");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObserver:self forKeyPath:@"kSBProceduralWallpaperHomeOptionsKey"];
    [userDefaults removeObserver:self forKeyPath:@"kSBProceduralWallpaperLockOptionsKey"];
    [_wallpaperFactory release];
    [_wallpapers release];
    [super dealloc];
}

@end
