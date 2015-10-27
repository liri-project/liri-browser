import QtQuick 2.0

BaseBrowserView {
    title: "Sites Colors"
    url: "liri://settings/sites-colors"

    SitesColors {
        anchors.fill: parent
    }
}

