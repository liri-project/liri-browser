import QtQuick 2.0
import QtQuick.Layouts 1.0
import Material 0.1
import Material.ListItems 0.1 as ListItem


Item {
    id: item
    property string title
    property string favicon_url
    property string url
    property int maximum_width: Units.dp(148)

    height: parent.height
    width: row.childrenRect.width

    property int maximum_text_width: maximum_width - favicon.width - Units.dp(16)

    Row {
        id: row
        spacing: Units.dp(5)
        anchors.fill: parent

        Image {
            id: favicon
            source: favicon_url
            width: Units.dp(18)
            height: Units.dp(18)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: lbl_title
            text: title
            color: root.current_icon_color
            elide: Text.ElideRight
            smooth: true
            clip: true
            font.family: root.font_family

            width: maximum_text_width
            anchors.verticalCenter: parent.verticalCenter

            Component.onCompleted:  {
                if (paintedWidth > maximum_text_width) {
                    width= maximum_text_width
                }
                else{
                        width=paintedWidth
                }
            }
        }

    }

    MouseArea {
        id: mouse_area
        anchors.fill:  parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
             if(mouse.button & Qt.RightButton) {
                context_menu.open(parent, context_menu.width-parent.width)
             }
             else
                 root.add_tab(item.url)
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
                onClicked: edit_dialog.open(item);
            }

            ListItem.Standard {
                text: qsTr("Delete")
                iconName: "action/delete"
                onClicked: {
                    root.remove_bookmark(item.url);
                    context_menu.close();
                }
            }

        }
    }

    Popover {
        id: edit_dialog

        width: Units.dp(400)
        height: col.childrenRect.height + Units.dp(24)

        dismissOnTap: true

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
                    text: qsTr("Edit bookmark")
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
                text: item.title
                width: parent.width
            }

            TextField {
                id: txt_edit_url
                placeholderText: qsTr("URL")
                floatingLabel: true
                text: item.url
                width: parent.width

            }

            TextField {
                id: txt_edit_favicon_url
                placeholderText: qsTr("Icon URL")
                floatingLabel: true
                text: item.favicon_url
                width: parent.width
            }

        }

        Button {
            id: btn_edit_cancel
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.right: btn_edit_apply.left

            text: qsTr("Cancel")

            onClicked: {
                txt_edit_title.text = item.title;
                txt_edit_url.text = item.url;
                txt_edit_favicon_url.text = item.favicon_url;
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
                root.get_tab_manager().change_bookmark(item.url, txt_edit_title.text, txt_edit_url.text, txt_edit_favicon_url.text);
                edit_dialog.close();
            }
        }


    }


}
