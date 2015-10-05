import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: tabBar

    height: root.tabHeight
    //color: root.tabBackgroundColor
    color: root.app.customFrame ? "transparent" : root.app.darkTheme ? root.app.darkThemeColor : "#EFEFEF"
    anchors {
        left: parent.left
        rightMargin: root.app.customFrame ? Units.dp(100) : 0
        right: parent.right
    }


    property alias listView: listView

    ListView {
        id: listView

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            //right: toolbarIntegrated.left
        }
        width: contentItem.width < (tabBar.width - toolbarIntegrated.width) ? contentItem.width : parent.width - toolbarIntegrated.width

        orientation: ListView.Horizontal
        spacing: Units.dp(1)
        interactive: mouseArea.draggingId == -1

        model: tabsModel

        delegate: TabBarItemDelegate {}

        MouseArea {
            id: mouseArea
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            hoverEnabled: true
            property int index: listView.indexAt(mouseX + listView.contentX, mouseY)
            property int draggingId: -1
            property int activeIndex
            propagateComposedEvents: true

            onClicked: mouse.accepted = false;

            onPressed: {
                if (root.activeTabInEditMode) {
                    mouse.accepted = false;
                }
            }

            onPressAndHold: {
                console.log("!")
                if (root.activeTabInEditMode) {
                    mouse.accepted = false;
                } else {
                    var item = listView.itemAt(mouseX + listView.contentX, mouseY);
                    if(item !== null) {
                        draggingId = listView.model.get(activeIndex=index).uid;
                    }
                }

            }
            onReleased: {
                if (activeTab.uid !== draggingId) {
                    getTabModelDataByUID(draggingId).state = "inactive";
                } else {
                    getTabModelDataByUID(draggingId).state = "active";
                }
                draggingId = -1
                mouse.accepted = false;
            }
            onPositionChanged: {
                if (draggingId != -1 && index != -1 && index != activeIndex) {
                    listView.model.move(activeIndex, activeIndex = index, 1);
                }
                mouse.accepted = false;

            }
            onDoubleClicked: {
                mouse.accepted = false;
            }

            onWheel: {
                listView.flick(wheel.angleDelta.y*10, 0);
            }
         }
    }

    IconButton {
        id: btnAddTabFloating
        visible: listView.width + toolbarIntegrated.width + width + Units.dp(24) < tabBar.width
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: listView.right
        anchors.margins:if (root.app.integratedAddressbars) { Units.dp(24) } else { 12 }
        color: root.iconColorOnCurrentTabDarken
        iconName: "content/add"

        onClicked: addTab();
    }

    Rectangle {
        id: toolbarIntegrated
        color: tabBar.color
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        //visible: !root.app.customFrame
        width: root.app.integratedAddressbars ? btnAddTab.width + btnDownloadsIntegrated.width +
                                                btnMenuIntegrated.width + 3 * Units.dp(24)
                                              : Units.dp(48)

        IconButton {
            id: btnAddTab
            z:30
            visible: !btnAddTabFloating.visible
            width: visible ? Units.dp(24) : 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: btnDownloadsIntegrated.left
            anchors.margins: root.app.integratedAddressbars ? Units.dp(24) : root.app.customFrame ? 3 : 12
            anchors.rightMargin: root.app.integratedAddressbars ? Units.dp(24) : root.app.customFrame ? 2 : 12
            color: root.app.darkTheme ? shadeColor(root.app.darkThemeColor, 0.5) : Theme.lightDark(root.currentTabColorDarken, Theme.light.iconColor, Theme.dark.iconColor)
            iconName: "content/add"

            onClicked: addTab();
        }

        IconButton {
            id: btnDownloadsIntegrated
            iconName: "file/file_download"
            visible: root.app.webEngine === "qtwebengine" && !mobile && downloadsModel.hasDownloads
            width: visible ? Units.dp(24) : 0
            color: root.app.webEngine === "qtwebengine" && downloadsModel.hasActiveDownloads
                   ? Theme.lightDark(toolbar.color, Theme.accentColor, Theme.dark.iconColor)
                   : root.currentIconColor
            anchors.right: btnMenuIntegrated.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: visible ? Units.dp(24) : 0
            onClicked: downloadsDrawer.open()
        }

        IconButton {
            id: btnMenuIntegrated
            visible: root.app.integratedAddressbars
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.app.integratedAddressbars ? Units.dp(24) : 0
            width: root.app.integratedAddressbars ? Units.dp(24) : 0
            color: root.iconColor
            iconName: "navigation/more_vert"
            onClicked: overflowMenu.open(btnMenuIntegrated)
        }
    }
}
