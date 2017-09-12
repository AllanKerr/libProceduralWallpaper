# libProceduralWallpaper

This library is designed to allow developers to easily create and load animated wallpapers. It provides a public interface for the private frameworks reponsible for loading animated wallpapers. iOS 8.0 and up are supported.

## Linking:

This can be linked to in a Theos make file by adding:
```
ProjectName_LIBRARIES = ProceduralWallpaper
```

After linking to libProcedural wallpaper, it is important to include the required headers. These include:
```
PWView.h
PWWallpaper.h
PWWallpaperPreviewController.h
```

Any required private framework headers can be found in the **/include** directory.

# Usage:

## Wallpaper Bundle:

The most important part of any project using libProceduralWallpaper is the wallpaper bundle. This should be added as an aggregate project to the base Theos project. Ensure that the aggregate project is being built as bundle. For reference you can use the **iphone/preference_bundle** template if needed.

The makefile must include the proper install path and library:
```
ProjectName_INSTALL_PATH = /Library/ProceduralWallpaper
ProjectName_LIBRARIES = ProceduralWallpaper
```

It is also important to include an **info.plist** file in the bundle's **/Resources** directory. This must include the following information:
```Objective-C
{
	CFBundleExecutable = MyWallpaperName;
	CFBundleIdentifier = "com.my.wallpaperName";
	"SBProceduralWallpaperClassNames" = (
		MyWallpaperName,
	);
}
```

If you want thumbnail support for animated wallpapers a symbolic link must be made from **/Library/ProceduralWallpaper/MyWallpaperName.bundle/libProceduralWallpaper** to **/Library/Application Support/libProceduralWallpaper**.

The wallpaper bundle must include two important classes, a PWWallpaper subclass and a PWView subclass.
```Objective-C
#import "libProceduralWallpaper.h"
#import "MyPWViewSubclass.h"

// The class name must match the string included in the SBProceduralWallpaperClassNames array
@interface MyWallpaperName : PWWallpaper

@end

@implementation MyWallpaperName

- (PWView *)initializeWallpaperWithOptions:(NSDictionary *)options
{
    // You can pass options to your PWView subclass or create and return a different animated wallpaper depending on the information passed in the options dictionary
    return [[MyPWViewSubclass alloc] initWithOptions:options];
}

@end
```
The PWView subclass is the view that displays the animated wallpaper.
```Objective-C
#import "libProceduralWallpaper.h"

@interface MyPWViewSubclass : PWView
- (id)initWithOptions:(NSDictionary *)options;
@end

@implementation MyPWViewSubclass
- (id)initWithOptions:(NSDictionary *)options
{
    if (self = [super init]) {
          // Add the graphics and animations for the desired effects
    }
    return self;
}

- (void)viewWillTransitionToSize:(CGSize)size
{
    // Called upon orientation change. Resizing for orientation must be handled manually using this method.
    // Using an auto resizing mask will cause the interface to freeze upon orientation change.
    
    // Example scaling code you may want to use to get started.
    CGRect bounds = self.superview.bounds;
    CGFloat scaleX = CGRectGetWidth(bounds) / CGRectGetWidth(self.layer.bounds);
    CGFloat scaleY = CGRectGetHeight(bounds) / CGRectGetHeight(self.layer.bounds);
    CGFloat scale = fmaxf(scaleX, scaleY);
    layer.transform = CATransform3DMakeScale(scale, scale, 1.0f);
}
@end
```

## Preference Bundle:

The last part of libProceduralWallpaper is previewing and setting wallpapers. The first step is to add a preference bundle as an aggregate project. Previewing and settings wallpapers is handled using PWWallpaperPreviewController:
```Objective-C
#import "libProceduralWallpaper.h"

...

// The options dictionary can only include data types supported in plist files.
// Options are passed to -initializeWallpaperWithOptions: in your PWWallpaper subclass
NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"valueIWantToPass", @"keyIWantToPass", nil];
PWWallpaperPreviewController *previewController = [PWWallpaperPreviewController controllerWithIdentifier:@"MyWallpaperName" options:options asyncWallpaperLoading:NO];
[self presentViewController:previewController.navigationController animated:YES completion:nil];

...

```

## Extended functionality:

The above examples can be used to create a basic animated wallpaper. For information on creating more advanced animated wallpapers documentation is included in:
```Objective-C
PWView.h
PWWallpaper.h
PWWallpaperPreviewController.h
```

Extended functionality includes:
* Asynchronous wallpaper loading
* Configurable toggles while previewing wallpapers
* Shared assets between wallpapers
