import QtQuick 2.4
import Material 0.1
import "../js/utils.js" as Utils

Object {
    id: tab

    readonly property url url: view ? view.url : ""

    property Item view

    property color toolbarColor: "white"
    property color iconColor: Theme.lightDark(toolbarColor, Theme.light.iconColor,
            Theme.dark.iconColor)
    property color activeIconColor: Theme.lightDark(toolbarColor, Theme.accentColor,
            Theme.dark.iconColor)
    property color textColor: Theme.lightDark(toolbarColor, Theme.light.textColor,
            Theme.dark.textColor)
    property color highlightColor: Theme.accentColor

    property bool secureConnection: String(url).indexOf("https://") == 0

    function load(url) {
        view.load(Utils.getValidUrl(url))
    }

    onUrlChanged: {
        console.log("Tab URL changed: " + url)
    }
}
