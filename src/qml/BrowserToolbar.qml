import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: toolbar

    color: activeTab.customColor ? activeTab.customColor : root.tabColorActive
    visible: !root.app.integratedAddressbars

    height: Units.dp(56)

    anchors {
        left: parent.left
        right: parent.right
    }

    property var ubuntuOmniboxOverlay

    function update() {
        var url = activeTab.webview.url;

        if (isBookmarked(url))
            bookmarkButton.iconName = "action/bookmark";
        else
            bookmarkButton.iconName = "action/bookmark_border";
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: spacing
        anchors.rightMargin: spacing

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
            visible: root.activeTab.webview.canGoForward || !mobile
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
            width: Units.dp(24)
            height: Units.dp(24)
            dashThickness: Units.dp(2)
        }

        Omnibox {
            id: omnibox

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Units.dp(16)
        }

        IconButton {
            color: root.currentIconColor
            iconName: "action/tab"
            onClicked: pageStack.push(tabsListPage);
            visible: mobile
        }

        IconButton {
            color: root.currentIconColor
            iconName: "content/add"
            onClicked: addTab()
            visible: !tabBar.visible && !mobile
        }

        IconButton {
            id: bookmarkButton
            color: root.currentIconColor
            iconName: "action/bookmark_border"
            onClicked: toggleActiveTabBookmark()
            visible: !mobile
        }

        IconButton {
            id: downloadsButton
            color: root.app.webengine === "qtwebengine" && downloadsModel.hasActiveDownloads ? Theme.accentColor : root.currentIconColor
            iconName: "file/file_download"
            onClicked: downloadsDrawer.open(downloadsButton)
            visible: root.app.webengine === "qtwebengine" && !mobile && downloadsModel.hasDownloads
        }

        IconButton {
            id: overflowButton
            color: root.currentIconColor
            iconName : "navigation/more_vert"
            onClicked: overflowMenu.open(overflowButton)
        }
    }

    Component.onCompleted: {
        if (root.app.platform === "converged/ubuntu") {
            var overlayComponent = Qt.createComponent("UbuntuOmniboxOverlay.qml");
            ubuntuOmniboxOverlay = overlayComponent.createObject(toolbar, {})
        }
    }

}


