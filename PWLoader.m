//
//  PWLoader.m
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-08-16.
//
//

#import <CaptainHook/CaptainHook.h>
#import <substrate.h>

static NSString *const SBProceduralWallpaperClassNames = @"SBProceduralWallpaperClassNames";
static NSString *const PWWallpaperDirectory = @"/Library/ProceduralWallpaper";

static Class (*orig_SBFMagicWallpaperClassForIdentifier)(NSString *identifier);

static Class hook_SBFMagicWallpaperClassForIdentifier(NSString *identifier)
{
    Class class = orig_SBFMagicWallpaperClassForIdentifier(identifier);
    if (class == nil) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PWWallpaperDirectory error:nil];
        for (NSString *file in contents) {
            if ([file.pathExtension isEqualToString:@"bundle"]) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", PWWallpaperDirectory, file];
                NSBundle *bundle = [NSBundle bundleWithPath:path];
                NSArray *classNames = [bundle objectForInfoDictionaryKey:SBProceduralWallpaperClassNames];
                if ([classNames containsObject:identifier]) {
                    class = [bundle classNamed:identifier];
                    break;
                }
            }
        }
    }
    return class;
}

@interface PWLoader : NSObject

@end

@implementation PWLoader

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDidLoad:) name:NSBundleDidLoadNotification object:nil];
    }
    return self;
}

- (void)bundleDidLoad:(NSNotification *)notification
{
    NSBundle *bundle = notification.object;
    if ([bundle.bundleIdentifier isEqualToString:@"com.apple.wallpaper.settings"]) {
        void *SBFMagicWallpaperClassForIdentifier = MSFindSymbol(NULL, "__SBFMagicWallpaperClassForIdentifier");
        MSHookFunction(SBFMagicWallpaperClassForIdentifier, (void *)hook_SBFMagicWallpaperClassForIdentifier, (void **)&orig_SBFMagicWallpaperClassForIdentifier);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

CHConstructor
{
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        void *SBFMagicWallpaperClassForIdentifier = MSFindSymbol(NULL, "__SBFMagicWallpaperClassForIdentifier");
        MSHookFunction(SBFMagicWallpaperClassForIdentifier, (void *)hook_SBFMagicWallpaperClassForIdentifier, (void **)&orig_SBFMagicWallpaperClassForIdentifier);
    } else {
        [[PWLoader alloc] init];
    }
}
