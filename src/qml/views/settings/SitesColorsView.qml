import QtQuick 2.0

BaseBrowserView {
    title: "Sites Colors"
    icon: "action/settings"
    url: "liri://settings/sites-colors"

    SitesColors {
        anchors.fill: parent
    }
}

