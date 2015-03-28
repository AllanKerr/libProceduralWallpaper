//
//  CARenderServerAPI.h
//  libProceduralWallpaper
//
//  Created by Allan Kerr on 2015-03-28.
//
//

#ifndef libProceduralWallpaper_CARenderServerAPI_h
#define libProceduralWallpaper_CARenderServerAPI_h

extern void CARenderServerRenderLayerWithTransform(mach_port_t server_port, uint32_t client_id, uint64_t layer_id, void *surface, int32_t ox, int32_t oy, CATransform3D *matrix);
 
#endif
