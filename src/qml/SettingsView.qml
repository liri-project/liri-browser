import QtQuick 2.0
import Material 0.1

BaseBrowserView {

    title: "Settings"
    icon: "action/settings"
    Component.onCompleted: console.log(icon)
    url: "liri://settings"

    Settings {
        anchors.fill: parent
    }
}
