export ARCHS=armv7 armv7s arm64

GO_EASY_ON_ME=1

include theos/makefiles/common.mk

LIBRARY_NAME = libProceduralWallpaper
libProceduralWallpaper_FILES = PWView.m PWWallpaper.m PWWallpaperPreviewController.m PWWallpaperPreviewView.m PWToggleButton.m
libProceduralWallpaper_FRAMEWORKS = UIKit CoreGraphics QuartzCore Accelerate
libProceduralWallpaper_PRIVATE_FRAMEWORKS = IOSurface SpringBoardFoundation SpringBoardUIServices PhotoLibrary
libProceduralWallpaper_LIBRARIES = substrate

TWEAK_NAME = PWLoader
PWLoader_FILES = PWLoader.m

ADDITIONAL_CFLAGS = -I "$(THEOS_PROJECT_DIR)/include" 

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk

internal-library-compile:
	cp ./obj/libProceduralWallpaper.dylib $(THEOS_LIBRARY_PATH)

after-install::
	install.exec "killall -9 SpringBoard"