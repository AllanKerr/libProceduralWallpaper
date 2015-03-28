export ARCHS=armv7 armv7s arm64

GO_EASY_ON_ME=1

include theos/makefiles/common.mk

LIBRARY_NAME = libProceduralWallpaper
libProceduralWallpaper_FILES = PWView.m PWWallpaper.m PWWallpaperCache.m
libProceduralWallpaper_FRAMEWORKS = UIKit CoreGraphics QuartzCore Accelerate
libProceduralWallpaper_PRIVATE_FRAMEWORKS = IOSurface SpringBoardFoundation

ADDITIONAL_CFLAGS = -I "$(THEOS_PROJECT_DIR)/include" 

include $(THEOS_MAKE_PATH)/library.mk
