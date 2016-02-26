if(UNIX)
    # Install the desktop and appdata files
    install(FILES ${PROJECT_NAME}.desktop
            DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
    install(FILES ${PROJECT_NAME}.appdata.xml
            DESTINATION ${CMAKE_INSTALL_METAINFODIR})

    # Install the icon
    install(FILES icons/liri-browser.png
            DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/512x512/apps)
endif()
