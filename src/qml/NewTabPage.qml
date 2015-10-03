import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem

Rectangle {
    id: pageRoot
    anchors.fill: parent
    color: root.app.darkTheme ? root.app.darkThemeColor : "white"

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: textDescription.top
        font.family: root.fontFamily
        text: qsTr("Nothing here, yet")
        visible: root.app.dashboardModel.count === 0
        font.pixelSize: 24
        color: root.iconColor
    }

    Text {
        id: textDescription
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - Units.dp(48)
        anchors.centerIn: parent
        font.family: root.fontFamily
        text: qsTr('You can add items by clicking on the menu item "Add to dash" on any website or by right clicking on a bookmark.')
        clip: true
        wrapMode: Text.WordWrap
        visible: root.app.dashboardModel.count === 0
        font.pixelSize: 16
        color: root.iconColor
    }

    GridView {
        id: grid

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: 165; cellHeight: 130
        width: parent.width - Units.dp(128)
        height: parent.height -  Units.dp(128)
        model: root.app.dashboardModel
        delegate: delegate

        Component {
            id: delegate
            Item {
                id: item
                width: grid.cellWidth-5; height: grid.cellHeight-5;
                Rectangle {
                    id: box
                    parent: grid
                    x: item.x; y: item.y;

                    border.color: Qt.rgba(0,0,0,0.2)
                    radius: Units.dp(2)

                    color: bgColor

                    width: item.width; height: item.height;
                    property int uid: (index >= 0) ? grid.model.get(index).uid : -1

                    Behavior on x {
                        NumberAnimation { duration: 100 }
                    }
                    Behavior on y {
                        NumberAnimation { duration: 100 }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: if (implicitWidth > Units.dp(64)) { Units.dp(64) } else { implicitWidth }
                        height: if (implicitHeight > Units.dp(64)) { Units.dp(64) } else { implicitHeight }

                        source: iconUrl
                    }

                    Text {
                        color: fgColor
                        font.family: root.fontFamily
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        anchors.margins: Units.dp(16)
                        anchors.bottomMargin: Units.dp(4)
                        text: title
                        font.pixelSize: Units.dp(14)
                        elide: Text.ElideRight
                        width: parent.width - Units.dp(10)
                        clip: true

                    }

                    states: [
                        State {
                            name: "active"; when: gridMouseArea.activeId == box.uid
                            PropertyChanges {target: box; x: gridMouseArea.mouseX-80; y: gridMouseArea.mouseY-45; z: 10}
                        }
                    ]
                }
            }
        }

        MouseArea {
            id: gridMouseArea
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            hoverEnabled: true
            preventStealing : true
            property int index: grid.indexAt(mouseX, mouseY)
            property int activeId: -1
            property int activeIndex

            onPressAndHold: {
                activeId = grid.model.get(activeIndex=index).uid
            }
            onReleased: {
                activeId = -1
            }
            onPositionChanged: {
                if (activeId != -1 && index != -1 && index != activeIndex) {
                    grid.model.move(activeIndex, activeIndex = index, 1)
                }
            }
            onClicked: {
                if(mouse.button & Qt.LeftButton) {
                    if (index != -1) {
                        newTabPage = false;
                        var url = grid.model.get(activeIndex=index).url;
                        root.setActiveTabURL(url);
                    }
                }
                else {
                    if (index != -1) {
                        var m = grid.model.get(activeIndex=index);
                        contextMenu.open(grid, -grid.width+mouseX + contextMenu.width, mouseY)

                    }
                }
            }
        }

    }


    Dropdown {
        id: contextMenu

        width: Units.dp(250)
        height: columnView.height + Units.dp(16)

        ColumnLayout {
            id: columnView
            width: parent.width
            anchors.centerIn: parent

            ListItem.Standard {
                text: qsTr("Edit")
                iconName: "image/edit"
                onClicked: {
                    editDialog.modelItem = grid.model.get(gridMouseArea.index);
                    editDialog.open(pageRoot, 0, -pageRoot.height/2 - editDialog.height);
                }
            }

            ListItem.Standard {
                text: qsTr("Delete")
                iconName: "action/delete"
                onClicked: {
                    grid.model.remove(gridMouseArea.index)
                    contextMenu.close();
                }
            }

        }
    }

    Popover {
        id: editDialog

        width: Units.dp(400)
        height: Units.dp(345)

        property var modelItem: {"title": "", "url": "", "iconUrl": "", "bgColor": "white"}
        onModelItemChanged: {
            colorChooser.color = modelItem.bgColor || "white";

        }

        dismissOnTap: false

        Column {
            id: col
            anchors.fill: parent
            anchors.margins: Units.dp(24)
            spacing: Units.dp(24)

            Item {
                width: parent.width
                height: Units.dp(24)
                Text {
                    id: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.fontFamily
                    text: qsTr("Edit item")
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    iconName: "navigation/close"
                    onClicked: editDialog.close()
                }

            }

            TextField {
                id: txtEditTitle
                placeholderText: qsTr("Title")
                floatingLabel: true
                text: editDialog.modelItem.title
                width: parent.width
            }

            TextField {
                id: txtEditUrl
                placeholderText: qsTr("URL")
                floatingLabel: true
                text: editDialog.modelItem.url
                width: parent.width

            }

            TextField {
                id: txtEditIconUrl
                placeholderText: qsTr("Icon URL")
                floatingLabel: true
                text: editDialog.modelItem.iconUrl
                width: parent.width
            }

            ColorChooser {
                id: colorChooser
                color: editDialog.modelItem.bgColor
                title: qsTr("Background color")
            }


        }

        Button {
            id: btnEditCancel
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.right: btnEditApply.left

            text: qsTr("Cancel")

            onClicked: {
                editDialog.close();
            }
        }

        Button {
            id: btnEditApply

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.rightMargin: Units.dp(24)
            anchors.right: parent.right

            text: qsTr("Apply")

            onClicked: {
                editDialog.modelItem.title = txtEditTitle.text;
                editDialog.modelItem.url = txtEditUrl.text;
                editDialog.modelItem.iconUrl = txtEditIconUrl.text;
                editDialog.modelItem.bgColor = colorChooser.color;
                editDialog.modelItem.fgColor = root.getTextColorForBackground(colorChooser.color.toString());
                editDialog.close();
            }
        }

    }



}

