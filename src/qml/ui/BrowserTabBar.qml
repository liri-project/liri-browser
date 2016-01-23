import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Item {
    id: tabBar

    property alias listView: listView

    height: styles.tabHeight

    visible: (tabsModel.count > 1 && !isMobile && !isFullscreen) || integratedAddressbars

    anchors {
        left: parent.left
        rightMargin: usingCustomFrame ? Units.dp(100) : 0
        right: parent.right
    }

    ListView {
        id: listView

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        width: contentWidth < (tabBar.width - toolbarIntegrated.width) ? contentWidth : parent.width - toolbarIntegrated.width

        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        spacing: Units.dp(1)
        interactive: mouseArea.draggingId == -1

        model: tabsModel

        delegate: TabBarItem {}

        clip: true

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
        visible: listView.width + toolbarIntegrated.width + width + Units.dp(24) < tabBar.width && mouseArea.draggingId === -1 && !listView.moving
        anchors {
            verticalCenter: parent.verticalCenter
            left: listView.right
            margins: integratedAddressbars ? Units.dp(24) : 12
        }
        color: activeTab.iconColor
        iconName: "content/add"

        onClicked: addTab();
    }

    Row {
        id: toolbarIntegrated
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: usingCustomFrame ? 3 : 12
        }

        spacing: Units.dp(24)

        IconButton {
            id: btnAddTab
            z:30
            visible: !btnAddTabFloating.visible
            color: activeTab.iconColor
            iconName: "content/add"

            onClicked: addTab();
        }

        IconButton {
            id: btnDownloadsIntegrated
            iconName: "file/file_download"
            visible: !isMobile && downloadsModel.hasDownloads && integratedAddressbars
            color: downloadsModel.hasActiveDownloads
                    ? activeTab.activeIconColor : activeTab.iconColor
            onClicked: downloadsDrawer.open()
        }

        IconButton {
            id: btnMenuIntegrated
            visible: integratedAddressbars
            color: activeTab.iconColor
            iconName: "navigation/more_vert"
            onClicked: overflowMenu.open(btnMenuIntegrated)
        }
    }
}
