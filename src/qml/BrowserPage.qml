import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls
import Material.Extras 0.1

Page {
    id: page

    property alias tabContainer: viewContainer

    actionBar.hidden: true

    Behavior on backgroundColor {
        ColorAnimation {
            duration: 200
        }
    }

    // FIXME
    // property alias ink: ink
    // property alias inkTimer: inkTimer

    property list<Action> overflowActions: [
        Action {
            name: qsTr("New window")
            iconName: "action/open_in_new"
            onTriggered: app.createWindow()
            // FIXME
            visible: root.app.enableNewWindowAction
        },
        Action {
            name: qsTr("New tab")
            iconName: "content/add"
            onTriggered: addTab();
            visible: isMobile
        },
        Action {
            name: qsTr("History")
            iconName: "action/history"
            onTriggered: historyDrawer.open()
        },
        Action {
            name: qsTr("Bookmarks")
            iconName: "action/bookmark"
            onTriggered: bookmarksDrawer.open()
        },
        Action {
            name: qsTr("Fullscreen")
            iconName: "navigation/fullscreen"
            onTriggered: {
                // FIXME
                if (!root.fullscreen)
                    root.startFullscreenMode()
                else
                    root.endFullscreenMode()
            }
        },
        Action {
            name: qsTr("Search")
            visible: activeTab.view.isWebView
            iconName: "action/search"
            // FIXME
            onTriggered: root.showSearchOverlay()
        },
        Action {
            name: qsTr("Bookmark this page")
            visible: integratedAddressbars || isMobile
            iconName:  "action/bookmark_border"
            // FIXME
            onTriggered: root.toggleActiveTabBookmark()
        },
        Action {
            name: qsTr("Add to dash")
            visible: !isMobile && activeTab.view.isWebView
            iconName: "action/dashboard"
            // FIXME
            onTriggered: root.addToDash(activeTab.view.url, activeTab.view.title, activeTab.customColor)
        },
        Action {
            name: qsTr("View source")
            visible: activeTab.view.isWebView
            iconName: "action/code"
            onTriggered: activeTabViewSourceCode()
        },
        Action {
            name: qsTr("Settings")
            iconName: "action/settings"
            onTriggered: {
                if (isMobile)
                    pageStack.push(settingsPage);
                else
                    addTab("liri://settings");
            }
        }
    ]

    View {
        id: titlebar

        backgroundColor: activeTab.toolbarColor

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: titlebarContents.height
        z: 9999
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
            }

            BrowserToolbar {
                id: toolbar
            }

            BookmarksBar {
                id: bookmarksBar
            }
        }
    }

    FullscreenBar { id: fullscreenBar }

    View {
        id: websiteSearchOverlay
        visible: false
        y: isMobile ? titlebar.height : parent.height - height

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
                width: isMobile ? parent.width - iconPrevious.width - iconNext.width - Units.dp(96): Units.dp(256)
                anchors.verticalCenter: parent.verticalCenter
                showBorder: true
                placeholderText: qsTr("Search")
                errorColor: "red"
                onTextChanged: activeTabFindText(text)
                Keys.onEnterPressed: activeTabFindText(text)
                Keys.onReturnPressed: activeTabFindText(text)
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
            color: activeTab.iconColor

            // FIXME
            onClicked: root.hideSearchOverlay()
        }
    }

    SearchSuggestions { id: searchSuggestions }

    Dialog {
        id: mediaDialog
        title: "A media link has been reached"
        positiveButtonText: "Play in the browser"
        negativeButtonText: "Download"
        property string url
        onAccepted: openPlayer(url)
        onRejected: setActiveTabURL(url,true)
    }

    Item {
        anchors {
            top: isFullscreen ? parent.top : titlebar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Units.dp(2)
        }

        Item {
            id: viewContainer
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

    ShadowOverlay {
        id: shadow
        onClicked: {
            visible ? visible = false : visible = true
        }
    }

    BookmarksDrawer { id: bookmarksDrawer }

    HistoryDrawer { id: historyDrawer }

    View {
        id: tabPreview
        width: styles.tabWidth
        height: width * window.height/window.width
        anchors{
            left: parent.left
            bottom: parent.bottom
        }

        elevation: 2
        z:900
        visible: false
        property alias source: img.source


        Image {
            id: img

            // FIXME
            source: root.tabPreviewSource
            anchors.fill: parent
        }
    }

    Ink {
        id: ink
        anchors.fill: parent
        width: window.width
        enabled: false
        propagateComposedEvents: true
        color: activeTab.customColor
        z:-1

        Timer {
            id: inkTimer
            interval: 1500
            repeat: false
            onTriggered: {
                ink.lastCircle.removeCircle()
            }
        }
    }
}
