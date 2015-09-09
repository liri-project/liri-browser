import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.3 as Controls

Item {
    id: page

    property alias webContainer: webContainer
    property alias iconConnectionType: toolbar.iconConnectionType
    property alias listView: tabBar.listView
    property alias bookmarksBar: bookmarksBar
    property alias bookmarkContainer: bookmarksBar.bookmarkContainer

    function updateToolbar () {
        toolbar.update()
    }

    property list<Action> overflowActions: [
        Action {
            name: qsTr("New window")
            iconName: "action/open_in_new"
            onTriggered: app.createWindow()
        },
        /*Action {
            name: qsTr("Save page")
            iconName: "content/save"
        },
        Action {
            name: qsTr("Print page")
            iconName: "action/print"
        },*/
        Action {
            name: qsTr("History")
            iconName: "action/history"
            onTriggered: historyDrawer.open()
        },
        Action {
            name: qsTr("Fullscreen")
            iconName: "navigation/fullscreen"
            onTriggered: {
                // TODO: Why this if statement? Should the action be hidden in fullscreen?
                // An action that doesn't do anything is confusing
                if (!root.fullscreen)
                    root.startFullscreenMode()
            }
        },
        Action {
            name: qsTr("Search")
            iconName: "action/search"
            onTriggered: root.showSearchOverlay()
        },
        Action {
            name: qsTr("Bookmark")
            visible: root.app.integratedAddressbars
            iconName: "action/bookmark_border"
            onTriggered: root.toggleActiveTabBookmark()
        },
        Action {
            name: qsTr("Add to dash")
            //visible: root.app.integratedAddressbars
            iconName: "action/dashboard"
            onTriggered: root.addToDash(activeTab.webview.url, activeTab.webview.title, activeTab.customColor)
        },
        Action {
            name: qsTr("View source")
            //visible: root.app.integratedAddressbars
            iconName: "action/code"
            onTriggered: activeTabViewSourceCode()
        },
        Action {
            name: qsTr("Settings")
            iconName: "action/settings"
            onTriggered: settingsDrawer.open()
        }
    ]

    View {
        id: titlebar

        width: parent.width
        height: titlebarContents.height

        elevation: 2

        Column {
            id: titlebarContents

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            BrowserTabBar {
                id: tabBar
                visible: tabsModel.count > 1
            }

            BrowserToolbar { id: toolbar }

            BookmarksBar { id: bookmarksBar }
        }
    }

    FullscreenBar { id: fullscreenBar }

    Item {
        anchors {
            top: fullscreen ? parent.top : titlebar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Units.dp(2)
        }

        Item {
            id: webContainer
            anchors.fill: parent
        }
    }

    Dropdown {
        id: overflowMenu
        objectName: "overflowMenu"

        width: Units.dp(250)
        height: columnView.height + Units.dp(16)

        ColumnLayout {
            id: columnView
            width: parent.width
            anchors.centerIn: parent

            Repeater {
                model: overflowActions
                delegate: ListItem.Standard {
                    id: listItem
                    text: modelData.name
                    iconSource: modelData.iconSource
                    onClicked: {
                        overflowMenu.close()
                        modelData.triggered(listItem)
                    }
                }
            }
        }
    }
}

