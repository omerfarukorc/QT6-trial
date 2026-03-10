cmake_minimum_required(VERSION 3.16)

project(dronetakip VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickLayouts Positioning Location Network Sql)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appdronetakip
    main.cpp
)

qt_add_qml_module(appdronetakip
    URI dronetakip
    QML_FILES
        Main.qml
        MapPage.qml
        TelemetryPage.qml
        MissionPage.qml
        SettingsPage.qml
    RESOURCES
        assets/drone.svg
        assets/base_station.svg
        assets/user.svg
)

set_target_properties(appdronetakip PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# QGC QtLocationPlugin — Google/Bing/Esri/Mapbox harita sağlayıcıları + SQLite tile cache
add_subdirectory(src/QtLocationPlugin)

target_link_libraries(appdronetakip
    PRIVATE Qt6::Quick Qt6::QuickLayouts Qt6::Positioning Qt6::Location Qt6::Network Qt6::Sql QGCLocation
)

include(GNUInstallDirs)
install(TARGETS appdronetakip
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
