import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

View {
    id: toolbar
    elevation:0
    property color chosenColor: root.activeTab.view.customColor ? root.activeTab.view.customColor : root.app.lightThemeColor
    backgroundColor: root.app.elevatedToolbar ? chosenColor : "transparent"
    visible: !root.app.integratedAddressbars

    height: root.mobile ? Units.dp(64) : Units.dp(56)

    anchors {
        left: parent.left
        right: parent.right
    }

    property var ubuntuOmniboxOverlay
    property alias omnibox: omnibox
    property int leftIconsCount: goBackButton.activeInt + goForwardButton.activeInt + refreshButton.activeInt

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: spacing
        anchors.rightMargin: spacing
        z:20
        spacing: Units.dp(24)

        Layout.alignment: Qt.AlignVCenter

        IconButton {
            id: goBackButton
            enabled: root.activeTab.view.canGoBack
            property int activeInt: visible ? 1 : 0
            onClicked: root.activeTab.view.goBack()
            color: root.currentIconColor
            Behavior on color { ColorAnimation { duration : 500 }}
            action: Action {
                iconName: "navigation/arrow_back"
                name: root.mobile ? "" : qsTr("Go Back")
            }
        }

        IconButton {
            id: goForwardButton
            enabled: root.activeTab.view.canGoForward
            onClicked: root.activeTab.view.goForward()
            color: root.currentIconColor
            property int activeInt: visible ? 1 : 0
            Behavior on color { ColorAnimation { duration : 500 }}
            visible: root.activeTab.view.canGoForward || !mobile
            action: Action {
                iconName: "navigation/arrow_forward"
                name: root.mobile ? "" : qsTr("Go Forward")
            }
        }

        IconButton {
            hoverAnimation: true
            id: refreshButton
            color: root.currentIconColor
            property int activeInt: visible ? 1 : 0
            visible: root.activeTab.view.reloadable
            Behavior on color { ColorAnimation { duration : 500 }}
            onClicked: !activeTab.view.loading ? activeTab.view.reload() : activeTab.view.stop()
            action: Action {
                iconName: !activeTab.view.loading ? "navigation/refresh" : "navigation/close"
                name:root.mobile ? "" : !activeTab.view.loading ? qsTr("Refresh") : qsTr("Stop")
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
                name: root.mobile ? "" : qsTr("Tabs")
            }
        }

        IconButton {
            color: root.currentIconColor
            Behavior on color { ColorAnimation { duration : 500 }}
            onClicked: addTab()
            visible: !mobile && (tabsModel.count == 1)
            action: Action {
                iconName: "content/add"
                name: root.mobile ? "" : qsTr("Add a tab")
            }
        }

        IconButton {
            id: bookmarkButton
            color: root.currentIconColor
            Behavior on color { ColorAnimation { duration : 500 }}
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
                name: root.mobile ? "" : qsTr("Downloads")
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
                name: root.mobile ? "" : qsTr("Menu")
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
