import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Item {
    id: toolbar

    property var ubuntuOmniboxOverlay
    property alias omnibox: omnibox
    property int leftIconsCount: goBackButton.activeInt + goForwardButton.activeInt + refreshButton.activeInt

    visible: !isFullscreen && !integratedAddressbars

    height: isMobile ? Units.dp(64) : Units.dp(56)

    anchors {
        left: parent.left
        right: parent.right
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: spacing
            rightMargin: spacing
        }

        z:20
        spacing: Units.dp(24)

        Layout.alignment: Qt.AlignVCenter

        IconButton {
            id: goBackButton

            property int activeInt: visible ? 1 : 0

            enabled: activeTab.view.canGoBack
            color: activeTab.iconColor
            action: Action {
                iconName: "navigation/arrow_back"
                name: qsTr("Go Back")
            }

            Behavior on color { ColorAnimation { duration : 500 }}

            onClicked: activeTab.view.goBack()
        }

        IconButton {
            id: goForwardButton

            property int activeInt: visible ? 1 : 0

            enabled: activeTab.view.canGoForward
            color: activeTab.iconColor
            // Always show on the desktop, only show when you can go forward on mobile
            visible: activeTab.view.canGoForward || !isMobile
            action: Action {
                iconName: "navigation/arrow_forward"
                name: qsTr("Go Forward")
            }

            Behavior on color { ColorAnimation { duration : 500 }}

            onClicked: activeTab.view.goForward()
        }

        IconButton {
            id: refreshButton

            property int activeInt: visible ? 1 : 0

            hoverAnimation: true
            color: activeTab.iconColor
            visible: activeTab.view.reloadable
            action: Action {
                iconName: !activeTab.view.loading ? "navigation/refresh" : "navigation/close"
                name: !activeTab.view.loading ? qsTr("Refresh") : qsTr("Stop")
            }

            Behavior on color { ColorAnimation { duration : 500 }}

            onClicked: !activeTab.view.loading ? activeTab.view.reload() : activeTab.view.stop()
        }

        Omnibox {
            id: omnibox

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - Units.dp(16)
        }

        IconButton {
            color: activeTab.iconColor
            visible: mobile
            action: Action {
                iconName: "action/tab"
                name: qsTr("Tabs")
            }

            onClicked: {
                pageStack.push(tabsListPage)
                // FIXME
                // root.tabsListIsOpened = true
            }
        }

        IconButton {
            color: activeTab.iconColor
            // Only show on the desktop and if there is one tab. When there is more than one tab,
            // thee add tab button will be in the toolbar
            visible: !mobile && (tabsModel.count == 1)
            action: Action {
                iconName: "content/add"
                name: qsTr("Add a tab")
            }

            Behavior on color { ColorAnimation { duration : 500 }}
            onClicked: tabsModel.addTab()
        }

        IconButton {
            id: bookmarkButton
            color: activeTab.iconColor
            visible: !mobile
            action: Action {
                iconName: "action/bookmark_border"
                name: qsTr("Bookmark this page")
            }

            Behavior on color { ColorAnimation { duration : 500 }}

            onClicked: toggleActiveTabBookmark()
        }

        IconButton {
            id: downloadsButton
            color: downloadsModel.hasActiveDownloads
                    ? activeTab.activeIconColor : activeTab.iconColor
            visible: !mobile && downloadsModel.hasDownloads
            action: Action {
                iconName: "file/file_download"
                name: qsTr("Downloads")
            }

            onClicked: downloadsDrawer.open(downloadsButton)

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

            color: activeTab.iconColor
            action: Action {
                iconName: "navigation/more_vert"
                name: qsTr("Menu")
            }

            onClicked: overflowMenu.open(overflowButton)
        }
    }

    Component.onCompleted: {
        if (app.platform === "converged/ubuntu") {
            ubuntuOmniboxOverlay = Utils.newObject(Qt.resolvedUrl("UbuntuOmniboxOverlay.qml"), {},
                    toolbar)
        }
    }
}
