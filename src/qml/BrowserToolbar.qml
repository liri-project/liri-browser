import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.3 as Controls

Rectangle {
    id: toolbar

    color: activeTab.customColor ? activeTab.customColor : root.tabColorActive
    visible: !integratedAddressbars

    height: Units.dp(64)
    width: parent.width

    property alias iconConnectionType: omnibox.iconConnectionType

    function update() {
        var url = activeTab.webview.url;

        if (isBookmarked(url))
            bookmarkButton.iconName = "action/bookmark";
        else
            bookmarkButton.iconName = "action/bookmark_border";
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Units.dp(24)
        anchors.rightMargin: Units.dp(24)

        spacing: Units.dp(24)

        Layout.alignment: Qt.AlignVCenter

        IconButton {
            iconName: "navigation/arrow_back"
            enabled: root.activeTab.webview.canGoBack
            onClicked: root.activeTab.webview.goBack()
            color: root.currentIconColor
        }

        IconButton {
            iconName: "navigation/arrow_forward"
            enabled: root.activeTab.webview.canGoForward
            onClicked: root.activeTab.webview.goForward()
            color: root.currentIconColor
        }

        IconButton {
            hoverAnimation: true
            iconName: "navigation/refresh"
            color: root.currentIconColor
            visible: !activeTab.webview.loading
            onClicked: activeTab.webview.reload()
        }

        LoadingIndicator {
            visible: activeTab.webview.loading
        }

        Omnibox {
            id: omnibox

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Units.dp(16)
        }

        IconButton {
            id: bookmarkButton
            color: root.currentIconColor
            iconName: "action/bookmark_border"
            onClicked: toggleActiveTabBookmark()
        }

        IconButton {
            id: downloadsButton
            color: downloadsDrawer.activeDownloads ? Theme.accentColor : root.currentIconColor
            iconName: "file/file_download"
            onClicked: downloadsDrawer.open(downloadsButton)

            Rectangle {
                visible: downloadsDrawer.activeDownloads
                z: -1
                width: parent.width + Units.dp(5)
                height: parent.height + Units.dp(5)
                anchors.centerIn: parent
                color: "white"
                radius: width*0.5
            }
        }

        IconButton {
            id: overflowButton
            color: root.currentIconColor
            iconName : "navigation/more_vert"
            onClicked: overflowMenu.open(overflowButton)
        }
    }
}


