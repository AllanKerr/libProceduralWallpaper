//
//  PWWallpaperCache.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-20.
//
//

#import "PWWallpaperCache.h"
#import "PWWallpaperPreviewController.h"
#import "PWWallpaper.h"

@implementation NSDictionary (Options)

- (NSDictionary *)dictionaryByRemovingThumbailKey
{
    NSMutableDictionary *mutableCopy = [[self mutableCopy] autorelease];
    [mutableCopy removeObjectForKey:kSBUIMagicWallpaperThumbnailNameKey];
    return mutableCopy; 
}  

@end

@interface PWWallpaperCache ()
@property (nonatomic, retain) NSMutableDictionary *wallpapers;
@property (nonatomic, retain) NSMutableArray *wallpaperFactoryCache;
@property (nonatomic, retain) NSMutableDictionary *wallpaperFactories;
@end

@implementation PWWallpaperCache
 
- (id)init
{
    if (self = [super init]) {
        NSLog(@"\n\n\n\n\n\ninit PWWallpaperCache");
        
        self.wallpaperFactoryCache = [NSMutableArray array];
        self.wallpapers = [NSMutableDictionary dictionaryWithCapacity:2];
        self.wallpaperFactories = [NSMutableDictionary dictionaryWithCapacity:2];
        
        int observerOptions = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults addObserver:self forKeyPath:@"kSBProceduralWallpaperHomeOptionsKey" options:observerOptions context:NULL];
        [userDefaults addObserver:self forKeyPath:@"kSBProceduralWallpaperLockOptionsKey" options:observerOptions context:NULL];
    }
    return self;
}

- (id <PWWallpaperFactory>)addFactoryForIdentifier:(NSString *)identifier
{
    id <PWWallpaperFactory> factory = [self.wallpaperFactories valueForKey:identifier];
    if (factory == nil) {
        NSString *factoryIdentifier = [NSClassFromString(identifier) factoryIdentifier];
        NSAssert(factoryIdentifier != nil, @"PWWallpaper -factoryIdentifier must be non-nil");
        
        factory = [[[NSClassFromString(factoryIdentifier) alloc] init] autorelease];
        NSAssert(factoryIdentifier != nil, @"%@ not found in %@", factoryIdentifier, identifier);
        [self.wallpaperFactories setObject:factory forKey:identifier];
    }
    [self.wallpaperFactoryCache addObject:factory];
    return factory;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"\n\n\n\n\n CHANGE:%@", change);
    PWView *oldView = nil;
    NSDictionary *oldOptions = [change valueForKey:@"old"];
    if (![oldOptions isEqual:[NSNull null]] && [oldOptions valueForKey:kSBUIMagicWallpaperIdentifierKey]) {
        oldOptions = [oldOptions dictionaryByRemovingThumbailKey];
        oldView = [self.wallpapers objectForKey:oldOptions];
        oldView.referenceCount--;
    }
    NSDictionary *newOptions = [change valueForKey:@"new"];
    if (![newOptions isEqual:[NSNull null]] && [newOptions valueForKey:kSBUIMagicWallpaperIdentifierKey]) {
        newOptions = [newOptions dictionaryByRemovingThumbailKey];
        PWView *newView = [self initializeWallpaperWithOptions:newOptions];
        newView.referenceCount++;
    }
    if (oldView != nil && oldView.referenceCount <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PWWillRemoveWallpaper" object:oldView];
        [oldView removeFromSuperview];
        [self.wallpapers removeObjectForKey:oldOptions];
        
        NSString *identifier = [oldOptions valueForKey:kSBUIMagicWallpaperIdentifierKey];
        id <PWWallpaperFactory> wallpaperFactory = [self.wallpaperFactories valueForKey:identifier];
        
        // -removeObject: can not be used because it removes all instances
        // We only want to remove the first encountered instance
        for (int i = self.wallpaperFactoryCache.count - 1; i >= 0; i--) {
            if ([wallpaperFactory isEqual:[self.wallpaperFactoryCache objectAtIndex:i]]) {
                [self.wallpaperFactoryCache removeObjectAtIndex:i];
                break;
            }
        }
        if (![self.wallpaperFactoryCache containsObject:wallpaperFactory]) {
            [self.wallpaperFactories removeObjectForKey:identifier];
        } else if ([wallpaperFactory respondsToSelector:@selector(clearUnusedAssets)]) {
            [wallpaperFactory clearUnusedAssets];
        }
    }
    NSLog(@"\n\n\n\nwallpaperFactoryCache:%@", self.wallpaperFactoryCache);
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
        NSString *identifier = [options valueForKey:kSBUIMagicWallpaperIdentifierKey];
        id <PWWallpaperFactory> wallpaperFactory = [self addFactoryForIdentifier:identifier];
        view = [wallpaperFactory initializeWallpaperWithOptions:options];
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
    [_wallpaperFactoryCache release];
    [_wallpaperFactories release];
    [_wallpapers release];
    [super dealloc];
}

@end
