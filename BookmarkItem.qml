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
                console.log(paintedWidth, maximum_text_width)
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

            /*ListItem.Standard {
                text: "Edit"
                iconName: "image/edit"
            }*/

            ListItem.Standard {
                text: "Delete"
                iconName: "action/delete"
                onClicked: {
                    root.remove_bookmark(item.url);
                    context_menu.close();
                }
            }

        }
    }

}
