import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: tabBar

    height: root.tabHeight
    //color: root.tabBackgroundColor
    color: root.app.customFrame ? "transparent" : "#EFEFEF"
    anchors {
        left: parent.left
        right: parent.right
        rightMargin: root.app.customFrame ? Units.dp(100) : 0
    }


    property alias listView: listView

    ListView {
        id: listView

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: toolbarIntegrated.left
        }

        orientation: ListView.Horizontal
        spacing: Units.dp(1)
        interactive: mouseArea.draggingId == -1

        model: tabsModel

        delegate: TabBarItemDelegate {}

        MouseArea {
            id: mouseArea
            anchors.fill: parent
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

    View {
        id: toolbarIntegrated
        elevation: Units.dp(2)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        visible: !root.app.customFrame
        width: root.app.integratedAddressbars ? btnAddTabIntegrated.width + btnDownloadsIntegrated.width +
                                                btnMenuIntegrated.width + 3 * Units.dp(24)
                                              : Units.dp(48)

        IconButton {
            id: btnAddTabIntegrated
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: btnDownloadsIntegrated.left
            anchors.margins:if (root.app.integratedAddressbars) { Units.dp(24) } else { 12 }
            color: root.iconColor
            iconName: "content/add"

            onClicked: addTab();
        }

        IconButton {
            id: btnDownloadsIntegrated
            visible: root.app.integratedAddressbars && downloadsDrawer.hasDownloads
            width: visible ? Units.dp(24) : 0
            color: root.app.webEngine === "qtwebengine" && downloadsModel.hasActiveDownloads ? Theme.accentColor : root.currentIconColor
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
