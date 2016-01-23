import QtQuick 2.0

BaseBrowserView {
    title: "Quick searches"
    icon: "action/settings"
    url: "liri://settings/quick-searches"

    QuickSearches {
        anchors.fill: parent
    }
}

