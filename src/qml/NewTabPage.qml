import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem

Rectangle {
    id: page_root
    anchors.fill: parent

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: text_description.top
        font.family: root.font_family
        text: qsTr("Nothing here, yet")
        visible: root.app.dashboard_model.count === 0
        font.pixelSize: 24
        color: root._icon_color
    }

    Text {
        id: text_description
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - Units.dp(48)
        anchors.centerIn: parent
        font.family: root.font_family
        text: qsTr('You can add items by clicking on the menu item "Add to dash" on any website or by right clicking on a bookmark.')
        clip: true
        wrapMode: Text.WordWrap
        visible: root.app.dashboard_model.count === 0
        font.pixelSize: 16
        color: root._icon_color
    }

    GridView {
        id: grid

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: 165; cellHeight: 130
        width: parent.width - Units.dp(128)
        height: parent.height -  Units.dp(128)
        model: root.app.dashboard_model
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

                    color: bg_color

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

                        source: icon_url
                    }

                    Text {
                        color: fg_color
                        font.family: root.font_family
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        anchors.margins: Units.dp(16)
                        text: title
                        font.pixelSize: Units.dp(14)
                        elide: Text.ElideRight
                        width: parent.width - Units.dp(10)
                        clip: true

                    }

                    states: [
                        State {
                            name: "active"; when: grid_mouse_area.activeId == box.uid
                            PropertyChanges {target: box; x: grid_mouse_area.mouseX-80; y: grid_mouse_area.mouseY-45; z: 10}
                        }
                    ]
                }
            }
        }

        MouseArea {
            id: grid_mouse_area
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
                        new_tab_page = false;
                        var url = grid.model.get(activeIndex=index).url;
                        root.setActiveTabURL(url);
                    }
                }
                else {
                    if (index != -1) {
                        var m = grid.model.get(activeIndex=index);
                        context_menu.open(grid, -grid.width+mouseX + context_menu.width, mouseY)

                    }
                }
            }
        }

    }


    Dropdown {
        id: context_menu

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
                    edit_dialog.model_item = grid.model.get(grid_mouse_area.index);
                    edit_dialog.open(page_root, 0, -page_root.height/2 - edit_dialog.height);
                }
            }

            ListItem.Standard {
                text: qsTr("Delete")
                iconName: "action/delete"
                onClicked: {
                    grid.model.remove(grid_mouse_area.index)
                    context_menu.close();
                }
            }

        }
    }

    Popover {
        id: edit_dialog

        width: Units.dp(400)
        height: Units.dp(345)

        property var model_item: {"title": "", "url": "", "icon_url": "", "bg_color": "white"}
        onModel_itemChanged: {
            color_chooser.color = model_item.bg_color || "white";

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
                    font.family: root.font_family
                    text: qsTr("Edit item")
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    iconName: "navigation/close"
                    onClicked: edit_dialog.close()
                }

            }

            TextField {
                id: txt_edit_title
                placeholderText: qsTr("Title")
                floatingLabel: true
                text: edit_dialog.model_item.title
                width: parent.width
            }

            TextField {
                id: txt_edit_url
                placeholderText: qsTr("URL")
                floatingLabel: true
                text: edit_dialog.model_item.url
                width: parent.width

            }

            TextField {
                id: txt_edit_icon_url
                placeholderText: qsTr("Icon URL")
                floatingLabel: true
                text: edit_dialog.model_item.icon_url
                width: parent.width
            }

            ColorChooser {
                id: color_chooser
                color: edit_dialog.model_item.bg_color
                title: qsTr("Background color")
            }


        }

        Button {
            id: btn_edit_cancel
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.right: btn_edit_apply.left

            text: qsTr("Cancel")

            onClicked: {
                edit_dialog.close();
            }
        }

        Button {
            id: btn_edit_apply

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.rightMargin: Units.dp(24)
            anchors.right: parent.right

            text: qsTr("Apply")

            onClicked: {
                edit_dialog.model_item.title = txt_edit_title.text;
                edit_dialog.model_item.url = txt_edit_url.text;
                edit_dialog.model_item.icon_url = txt_edit_icon_url.text;
                edit_dialog.model_item.bg_color = color_chooser.color;
                edit_dialog.model_item.fg_color = root.get_tab_manager().get_text_color_for_background(color_chooser.color.toString());
                edit_dialog.close();
            }
        }

    }



}

