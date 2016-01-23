import QtQuick 2.4
import Material 0.1
import "../utils.js" as Utils

Object {
    id: tab
    property url url

    property Item view

    property color toolbarColor: "white"
    property color iconColor: Theme.lightDark(toolbarColor, Theme.light.iconColor,
            Theme.dark.iconColor)
    property color activeIconColor: Theme.lightDark(toolbarColor, Theme.accentColor,
            Theme.dark.iconColor)
    property color textColor: Theme.lightDark(toolbarColor, Theme.light.textColor,
            Theme.dark.textColor)

    property bool secureConnection: String(url).indexOf("https://") == 0

    function load(url) {
        console.log("Loading url: " + url)
        tab.url = Utils.getValidUrl(url)
        console.log("Found url: " + tab.url)
    }
}
