import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

View {
    id: toolbar
    elevation:0
    backgroundColor: activeTab.customColor ? activeTab.customColor : root.tabColorActive
    visible: !root.app.integratedAddressbars

    height: root.mobile ? Units.dp(64) : Units.dp(56)

    property bool darkBackground: Theme.isDarkColor(color)
    property color textColor: Theme.lightDark(color, Theme.light.textColor, Theme.dark.textColor)
    property color iconColor: Theme.lightDark(color, Theme.light.iconColor, Theme.dark.iconColor)

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
            iconName: !activeTab.webview.loading ? "navigation/refresh" : "navigation/close"
            color: root.currentIconColor
            onClicked: !activeTab.webview.loading ? activeTab.webview.reload() : activeTab.webview.stop()
        }

        Omnibox {
            id: omnibox

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Units.dp(16)
        }

        IconButton {
            color: root.currentIconColor
            iconName: "action/tab"
            onClicked: {pageStack.push(tabsListPage);}
            visible: mobile
        }

        IconButton {
            color: root.currentIconColor
            iconName: "content/add"
            onClicked: addTab()
            visible: !mobile && (root.app.customFrame || tabsModel.count == 1)
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
            color: root.app.webEngine === "qtwebengine" && downloadsModel.hasActiveDownloads
                   ? Theme.lightDark(toolbar.color, Theme.accentColor, Theme.dark.iconColor)
                   : root.currentIconColor
            iconName: "file/file_download"
            onClicked: downloadsDrawer.open(downloadsButton)
            visible: root.app.webEngine === "qtwebengine" && !mobile && downloadsModel.hasDownloads

            ProgressCircle {
                anchors.centerIn: parent
                width: parent.width + Units.dp(16)
                height: width
                z: -1

                color: downloadsButton.color

                indeterminate: false
                value: downloadsModel.overallProgress
                visible: downloadsModel.hasActiveDownloads
            }
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
