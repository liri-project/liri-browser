import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1

Item {
    id: pageRoot
    anchors.fill: parent

    readonly property var sortedBookmarks: sortByKey(root.app.bookmarks, "title")
    readonly property var frequentSites: root.app.frequentSites

    ColumnLayout {
        anchors.centerIn: parent
        visible: sortedBookmarks.length === 0 && frequentSites.length === 0
        width: parent.width - Units.dp(32)

        Icon {
            name: "social/public"
            size: Units.dp(48)
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Welcome to Liri!")
            style: "title"
            color: Theme.light.subTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Your bookmarks and frequently visited sites will appear here")

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            style: "subheading"
            color: Theme.light.subTextColor

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
        }
    }

    Flickable {
        anchors.fill: parent

        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width

            ListItem.Subheader {
                text: "Bookmarks"
                visible: sortedBookmarks.length > 0
            }

            Flow {
                width: parent.width
                spacing: Units.dp(8)

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Units.dp(16)
                }

                Repeater {
                    model: sortedBookmarks
                    delegate: siteDelegate
                }
            }

            ListItem.Subheader {
                text: "Frequently Visited"
                visible: frequentSites.length > 0
            }

            Flow {
                width: parent.width
                spacing: Units.dp(8)

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Units.dp(16)
                }

                Repeater {
                    model: frequentSites
                    delegate: siteDelegate
                }
            }
        }
    }

    // Used for calculating the height of the tile labels
    Label {
        id: baseLabel
        visible: false
        height: maximumLineCount/lineCount * implicitHeight
        text: "1\n2\n"
        maximumLineCount: 2
    }

    Dropdown {
        id: contextMenu

        width: Units.dp(250)
        height: columnView.height + Units.dp(16)

        anchor: Item.TopLeft

        property var bookmark

        ColumnLayout {
            id: columnView
            width: parent.width
            anchors.centerIn: parent

            ListItem.Standard {
                text: qsTr("Edit")
                iconName: "image/edit"
                onClicked: {
                    editDialog.bookmark = contextMenu.bookmark
                    editDialog.open()
                }
            }

            ListItem.Standard {
                text: qsTr("Delete")
                iconName: "action/delete"
                onClicked: {
                    removeBookmark(contextMenu.bookmark.url)
                    snackbar.open(qsTr('Removed bookmark %1').arg(contextMenu.bookmark.title));
                    contextMenu.close()
                }
            }
        }
    }

    Popover {
        id: editDialog

        width: Units.dp(400)
        height: Units.dp(345)

        property var bookmark: {"title": "", "url": "", "iconUrl": "", "bgColor": "white"}

        onBookmarkChanged: {
            colorChooser.color = bookmark.bgColor || "white";
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
                text: editDialog.bookmark.title
                width: parent.width
            }

            TextField {
                id: txtEditUrl
                placeholderText: qsTr("URL")
                floatingLabel: true
                text: editDialog.bookmark.url
                width: parent.width

            }

            TextField {
                id: txtEditIconUrl
                placeholderText: qsTr("Icon URL")
                floatingLabel: true
                text: editDialog.bookmark.iconUrl
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
                editDialog.bookmark.title = txtEditTitle.text;
                editDialog.bookmark.url = txtEditUrl.text;
                editDialog.bookmark.iconUrl = txtEditIconUrl.text;
                editDialog.bookmark.bgColor = colorChooser.color;
                editDialog.bookmark.fgColor = root.getTextColorForBackground(colorChooser.color.toString());
                editDialog.close();
            }
        }
    }

    Component {
        id: siteDelegate

        View {
            width: itemColumn.width
            height: itemColumn.height

            tintColor: ink.containsMouse ? Qt.rgba(0,0,0,0.05) : Qt.rgba(0,0,0,0)
            radius: Units.dp(2)

            Ink {
                id: ink
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        setActiveTabURL(modelData.url)
                    } else {
                        contextMenu.bookmark = modelData
                        contextMenu.open(ink, mouse.x, mouse.y)
                    }
                }
            }

            Column {
                id: itemColumn
                anchors.centerIn: parent
                height: Units.dp(120)
                width: height

                Item {
                    id: imageRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: height
                    height: parent.height - label.height

                    Icon {
                        anchors.centerIn: parent
                        size: parent.height * 0.75
                        name: "social/public"

                        visible: image.status !== Image.Ready
                    }

                    Image {
                        id: image
                        anchors.centerIn: parent
                        height: parent.height * 0.75
                        width: height
                        fillMode: Image.PreserveAspectFit
                        visible: image.status === Image.Ready

                        source: modelData.faviconUrl
                    }
                }

                Label {
                    id: label
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Units.dp(16)
                    height: baseLabel.height + Units.dp(8)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: modelData.title
                    maximumLineCount: 2
                }
            }
        }
    }
}

