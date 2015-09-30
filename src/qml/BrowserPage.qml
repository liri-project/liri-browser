import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Page {
    id: page
    actionBar {
        hidden: true
    }

    property alias webContainer: webContainer
    property alias listView: tabBar.listView
    property alias bookmarksBar: bookmarksBar
    property alias bookmarkContainer: bookmarksBar.bookmarkContainer
    property alias txtSearch: txtSearch
    property alias websiteSearchOverlay: websiteSearchOverlay

    function updateToolbar () {
        toolbar.update()
    }

    property list<Action> overflowActions: [
        Action {
            name: qsTr("New window")
            iconName: "action/open_in_new"
            onTriggered: app.createWindow()
            visible: root.app.enableNewWindowAction
        },
        Action {
            name: qsTr("New tab")
            iconName: "content/add"
            onTriggered: addTab();
            visible: root.mobile
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
            visible: !activeTab.webview.newTabPage && !activeTab.webview.settingsTabPage
            iconName: "action/search"
            onTriggered: root.showSearchOverlay()
        },
        Action {
            name: qsTr("Bookmark")
            visible: root.app.integratedAddressbars && !root.mobile && !activeTab.webview.sourceTapPage
            iconName: "action/bookmark_border"
            onTriggered: root.toggleActiveTabBookmark()
        },
        Action {
            name: qsTr("Add to dash")
            visible: !root.mobile && !activeTab.webview.newTabPage && !activeTab.webview.sourceTapPage
            iconName: "action/dashboard"
            onTriggered: root.addToDash(activeTab.webview.url, activeTab.webview.title, activeTab.customColor)
        },
        Action {
            name: qsTr("View source")
            visible: !activeTab.webview.newTabPage && !activeTab.webview.settingsTabPage && !activeTab.webview.sourceTapPage
            iconName: "action/code"
            onTriggered: activeTabViewSourceCode()
        },
        Action {
            name: qsTr("Settings")
            visible: !activeTab.webview.settingsTabPage
            iconName: "action/settings"
            onTriggered: {
                if (mobile)
                    pageStack.push(settingsPage);
                else
                    addTab("liri://settings");
            }
        }
    ]

    View {
        id: titlebar
        backgroundColor: "transparent"
        anchors.top: parent.top
        anchors.topMargin: (tabsModel.count > 1 || root.app.integratedAddressbars) && root.app.customFrame ? -Units.dp(40) : 0
        width: parent.width
        height: titlebarContents.height

        z: 5

        elevation: 0

        Column {
            id: titlebarContents

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            BrowserTabBar {
                id: tabBar
                visible: (tabsModel.count > 1 && !root.mobile && !root.fullscreen) || root.app.integratedAddressbars
            }

            BrowserToolbar {
                id: toolbar
                visible: !root.fullscreen && !root.app.integratedAddressbars
            }

            BookmarksBar {
                id: bookmarksBar
                visible: app.bookmarks.length > 0 && !root.fullscreen && !root.mobile
            }
        }
    }

    FullscreenBar { id: fullscreenBar }

    View {
        id: websiteSearchOverlay
        visible: false
        anchors.top: titlebar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Units.dp(48)
        elevation: 2
        z: 5

        onVisibleChanged: {
            if (!visible)
                activeTabFindText("");
        }

        Row {
            anchors.fill: parent
            anchors.margins: Units.dp(5)
            anchors.leftMargin: Units.dp(24)
            anchors.rightMargin: Units.dp(24)
            spacing: Units.dp(24)

            TextField {
                id: txtSearch
                height: parent.height - Units.dp(8)
                width: root.mobile ? parent.width - iconPrevious.width - iconNext.width - Units.dp(96): Units.dp(256)
                anchors.verticalCenter: parent.verticalCenter
                showBorder: true
                placeholderText: qsTr("Search")
                errorColor: "red"
                onAccepted: activeTabFindText(text)
            }

            IconButton {
                id: iconPrevious
                iconName: "hardware/keyboard_arrow_up"
                onClicked: activeTabFindText(txtSearch.text, true)
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                id: iconNext
                iconName: "hardware/keyboard_arrow_down"
                onClicked: activeTabFindText(txtSearch.text)
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        IconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Units.dp(24)
            iconName: "navigation/close"
            color: root.iconColor
            onClicked: root.hideSearchOverlay()
        }
    }


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
                    visible: modelData.visible
                    onClicked: {
                        overflowMenu.close()
                        modelData.triggered(listItem)
                    }
                }
            }
        }
    }
}
