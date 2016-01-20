set(SOURCES
    main.cpp config.cpp clipboardadapter.cpp
    cursor/cursor.cpp
    plugins/pluginsengine.cpp plugins/plugin.cpp plugins/api.cpp plugins/urlopener.cpp
    liri-browser.qrc
)

add_executable(liri-browser ${SOURCES})
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
