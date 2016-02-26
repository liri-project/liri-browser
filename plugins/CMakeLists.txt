set(PLUGINS
    omniplet-bookmarks
    omniplet-calculator
    omniplet-duckduckgo
    omniplet-history
    omniplet-weather
)

install(DIRECTORY ${PLUGINS}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/liri-browser/plugins)
