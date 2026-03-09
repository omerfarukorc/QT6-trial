qt_add_plugin(QGCLocation
    STATIC
    CLASS_NAME QGeoServiceProviderFactoryQGC
    OUTPUT_TARGETS QGCLocation_targets
    Providers/BingMapProvider.cpp
    Providers/BingMapProvider.h
    Providers/GenericMapProvider.cpp
    Providers/GenericMapProvider.h
    Providers/GoogleMapProvider.cpp
    Providers/GoogleMapProvider.h
    Providers/MapProvider.cpp
    Providers/MapProvider.h
    QMLControl/QGCMapEngineManager.cc
    QMLControl/QGCMapEngineManager.h
    QMLControl/QmlObjectListModel.cpp
    QMLControl/QmlObjectListModel.h
    QGCCachedTileSet.cpp
    QGCCachedTileSet.h
    QGCCacheTile.h
    QGCMapEngine.cpp
    QGCMapEngine.h
    QGCMapTasks.h
    QGCMapUrlEngine.cpp
    QGCMapUrlEngine.h
    QGCTile.h
    QGCTileCacheWorker.cpp
    QGCTileCacheWorker.h
    QGCTileSet.h
    QGeoFileTileCacheQGC.cpp
    QGeoFileTileCacheQGC.h
    QGeoMapReplyQGC.cpp
    QGeoMapReplyQGC.h
    QGeoServiceProviderPluginQGC.cpp
    QGeoServiceProviderPluginQGC.h
    QGeoTiledMappingManagerEngineQGC.cpp
    QGeoTiledMappingManagerEngineQGC.h
    QGeoTiledMapQGC.cpp
    QGeoTiledMapQGC.h
    QGeoTileFetcherQGC.cpp
    QGeoTileFetcherQGC.h
)

target_link_libraries(QGCLocation
    PRIVATE
        Qt6::Positioning
        Qt6::Sql
    PUBLIC
        Qt6::Core
        Qt6::Location
        Qt6::LocationPrivate
        Qt6::Network
)

# Include paths — QGC'ye özgü yollar kaldırıldı, sadece bizim shim dizinimiz var
target_include_directories(QGCLocation
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}            # QtLocationPlugin/ kendisi
        ${CMAKE_CURRENT_SOURCE_DIR}/..         # src/ (shim header'lar burada)
        ${CMAKE_CURRENT_SOURCE_DIR}/Providers
        ${CMAKE_CURRENT_SOURCE_DIR}/QMLControl
)
