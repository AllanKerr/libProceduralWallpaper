//
//  IOSurfaceAPI.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-23.
//
//

#ifndef libProceduralWallpaper_IOSurfaceAPI_h
#define libProceduralWallpaper_IOSurfaceAPI_h

typedef uint32_t IOSurfaceID;
 
extern void *IOSurfaceLookup(IOSurfaceID csid);
extern IOSurfaceID IOSurfaceGetID (void *buffer);
extern void *IOSurfaceCreate(CFDictionaryRef properties);
extern void *IOSurfaceLock(void *buffer, uint32_t options, uint32_t *seed);
extern void *IOSurfaceUnlock(void *buffer, uint32_t options, uint32_t *seed);
extern void *IOSurfaceGetBaseAddress(void *buffer);
extern size_t IOSurfaceGetBytesPerRow(void *buffer);
extern size_t IOSurfaceGetAllocSize(void *buffer);
extern size_t IOSurfaceGetWidth(void *buffer);
extern size_t IOSurfaceGetHeight(void *buffer);
extern int32_t IOSurfaceGetUseCount(void *buffer);
extern Boolean IOSurfaceIsInUse(void *buffer);

extern const CFStringRef kIOSurfaceAllocSize;
extern const CFStringRef kIOSurfaceBytesPerRow;
extern const CFStringRef kIOSurfaceWidth;
extern const CFStringRef kIOSurfaceHeight;
extern const CFStringRef kIOSurfacePixelFormat;
extern const CFStringRef kIOSurfaceBytesPerElement;
extern const CFStringRef kIOSurfaceIsGlobal;

#endif
