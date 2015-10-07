import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

View {
    id: toolbar
    elevation:0
    backgroundColor: root.app.darkTheme ? root.app.darkThemeColor : activeTab.customColor ? activeTab.customColor : root.tabColorActive
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
            enabled: root.activeTab.webview.canGoBack
            onClicked: root.activeTab.webview.goBack()
            color: root.currentIconColor
            action: Action {
                iconName: "navigation/arrow_back"
                name: qsTr("Go Back")
            }
        }

        IconButton {
            enabled: root.activeTab.webview.canGoForward
            onClicked: root.activeTab.webview.goForward()
            color: root.currentIconColor
            visible: root.activeTab.webview.canGoForward || !mobile
            action: Action {
                iconName: "navigation/arrow_forward"
                name: qsTr("Go Forward")
            }
        }

        IconButton {
            hoverAnimation: true
            color: root.currentIconColor
            onClicked: !activeTab.webview.loading ? activeTab.webview.reload() : activeTab.webview.stop()
            action: Action {
                iconName: !activeTab.webview.loading ? "navigation/refresh" : "navigation/close"
                name:!activeTab.webview.loading ? qsTr("Refresh") : qsTr("Stop")
            }
        }

        Omnibox {
            id: omnibox

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Units.dp(16)
        }

        IconButton {
            color: root.currentIconColor
            onClicked: {pageStack.push(tabsListPage);root.tabsListIsOpened = true}
            visible: mobile
            action: Action {
                iconName: "action/tab"
                name: qsTr("Tabs")
            }
        }

        IconButton {
            color: root.currentIconColor
            onClicked: addTab()
            visible: !mobile && (tabsModel.count == 1)
            action: Action {
                iconName: "content/add"
                name: qsTr("Add a tab")
            }
        }

        IconButton {
            id: bookmarkButton
            color: root.currentIconColor
            onClicked: toggleActiveTabBookmark()
            visible: !mobile
            action: Action {
                iconName: "action/bookmark_border"
                name: qsTr("Bookmark this page")
            }
        }

        IconButton {
            id: downloadsButton
            color: root.app.webEngine === "qtwebengine" && downloadsModel.hasActiveDownloads
                   ? Theme.lightDark(toolbar.color, Theme.accentColor, Theme.dark.iconColor)
                   : root.currentIconColor
            onClicked: downloadsDrawer.open(downloadsButton)
            visible: root.app.webEngine === "qtwebengine" && !mobile && downloadsModel.hasDownloads
            action: Action {
                iconName: "file/file_download"
                name: qsTr("Downloads")
            }

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
            onClicked: overflowMenu.open(overflowButton)
            action: Action {
                iconName: "navigation/more_vert"
                name: qsTr("Menu")
            }
        }
    }
    Component.onCompleted: {
        if (root.app.platform === "converged/ubuntu") {
            var overlayComponent = Qt.createComponent("UbuntuOmniboxOverlay.qml");
            ubuntuOmniboxOverlay = overlayComponent.createObject(toolbar, {})
        }
    }

}
