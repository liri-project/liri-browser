set(SOURCES
    main.cpp config.cpp clipboardadapter.cpp
    cursor/cursor.cpp
    plugins/pluginsengine.cpp plugins/plugin.cpp plugins/api.cpp plugins/urlopener.cpp
    liri-browser.qrc
)

file(GLOB_RECURSE TS_SOURCES *.cpp *.h *.qml *.js ${CMAKE_SOURCE_DIR}/plugins/*.ts)
file(GLOB TS_FILES "${CMAKE_SOURCE_DIR}/translations/*.ts")

if(UPDATE_TRANSLATIONS)
    qt5_create_translation(QM_FILES ${TS_SOURCES} ${TS_FILES})
else()
    qt5_add_translation(QM_FILES ${TS_FILES})
endif(UPDATE_TRANSLATIONS)

if(APPLE)
    set(MACOSX_BUNDLE_ICON_FILE liri-browser.icns)
    set_source_files_properties(${CMAKE_SOURCE_DIR}/icons/liri-browser.icns
                                PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    set(SOURCES ${SOURCES} ${CMAKE_SOURCE_DIR}/icons/liri-browser.icns)
ENDIF(APPLE)

add_executable(liri-browser ${SOURCES} ${QM_FILES})
target_link_libraries(liri-browser
                      Qt5::Core
                      Qt5::Qml
                      Qt5::Quick
                      Qt5::Widgets
                      Qt5::Xml
                      Qt5::Svg
                      Qt5::Multimedia
                      Qt5::Network
                      Qt5::WebEngine
                      Qt5::WebEngineWidgets)

install(TARGETS liri-browser
        DESTINATION ${CMAKE_INSTALL_BINDIR})
