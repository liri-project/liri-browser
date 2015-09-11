import QtQuick 2.0
import QtQuick.Layouts 1.0
import Material 0.1
import Material.ListItems 0.1 as ListItem


Item {
    id: item
    property string title
    property string faviconUrl
    property string url
    property int maximumWidth: Units.dp(148)

    property color color: "white"

    height: parent.height
    width: row.childrenRect.width

    property int maximumTextWidth: maximumWidth - favicon.width - Units.dp(16)

    Row {
        id: row
        spacing: Units.dp(5)
        anchors.fill: parent

        Image {
            id: favicon
            source: faviconUrl
            width: Units.dp(18)
            height: Units.dp(18)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: lblTitle
            text: title
            color: root.currentIconColor
            elide: Text.ElideRight
            smooth: true
            clip: true
            font.family: root.fontFamily

            width: maximumTextWidth
            anchors.verticalCenter: parent.verticalCenter

            Component.onCompleted:  {
                if (paintedWidth > maximumTextWidth) {
                    width= maximumTextWidth
                }
                else{
                        width=paintedWidth
                }
            }
        }

    }

    MouseArea {
        id: mouseArea
        anchors.fill:  parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
             if(mouse.button & Qt.RightButton) {
                contextMenu.open(parent, contextMenu.width-parent.width)
             }
             else
                 root.addTab(item.url);
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
                onClicked: editDialog.open(item);
            }

            ListItem.Standard {
                text: qsTr("Delete")
                iconName: "action/delete"
                onClicked: {
                    root.removeBookmark(item.url);
                    contextMenu.close();
                }
            }

        }
    }

    Popover {
        id: editDialog

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
                    font.family: root.fontFamily
                    text: qsTr("Edit bookmark")
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
                text: item.title
                width: parent.width
            }

            TextField {
                id: txtEditUrl
                placeholderText: qsTr("URL")
                floatingLabel: true
                text: item.url
                width: parent.width

            }

            TextField {
                id: txtEditFaviconUrl
                placeholderText: qsTr("Icon URL")
                floatingLabel: true
                text: item.faviconUrl
                width: parent.width
            }

        }

        Button {
            id: btnEditCancel
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(24)
            anchors.right: btnEditApply.left

            text: qsTr("Cancel")

            onClicked: {
                txtEditTitle.text = item.title;
                txtEditUrl.text = item.url;
                txtEditFaviconUrl.text = item.faviconUrl;
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
                root.changeBookmark(item.url, txtEditTitle.text, txtEditUrl.text, txtEditFaviconUrl.text);
                editDialog.close();
            }
        }


    }


}
