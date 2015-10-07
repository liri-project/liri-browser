import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0


NavigationDrawer {
    id: drawer
    z: 25
    mode: "right"
    width: Units.dp(350)
    visible: anchors.rightMargin != -width - Units.dp(10)
    View {
        id: bookmarksTitle
        height: Units.dp(56)
        width: parent.width
        elevation: listView.contentY > 0 ? 1 : 0
        backgroundColor: "white"
        z: 1

        Label {
            id: label
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Units.dp(16)
                rightMargin: Units.dp(16)
                verticalCenter: parent.verticalCenter
            }
            text: qsTr("Bookmarks")
            style: "title"
        }

    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            top: bookmarksTitle.bottom
            bottom: parent.bottom
        }

        ListView {
            id: listView

            //bottomMargin: Units.dp(8)
            interactive: count > 0
            model: root.app.bookmarksModel
            delegate: bookmarksItemDelegate

            Column {
                visible: listView.count == 0
                anchors.centerIn: parent
                spacing: Units.dp(8)

                Icon {
                    name: "action/bookmark_border"
                    size: Units.dp(48)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    style: "subheading"
                    color: Theme.light.subTextColor
                    text: qsTr("No bookmarks found")
                    font.pixelSize: Units.dp(17)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Component {
        id: bookmarksItemDelegate

        Item {
            height: childrenRect.height

            anchors {
                left: parent.left
                right: parent.right
            }

            ListItem.Standard {
                text: title
                action: [
                    Image {
                        id: favImage
                        anchors.centerIn: parent
                        source: faviconUrl ? faviconUrl : ""
                        height: Units.dp(20)
                        width: Units.dp(20)
                    },
                    Icon {
                        anchors.centerIn: parent
                        name: "social/public"
                        size: Units.dp(22)
                        visible: favImage.status !== Image.Ready
                    }
                ]
                onClicked: root.addTab(url)
                IconButton {
                    iconName: "action/settings"
                    size: Units.dp(20)
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Units.dp(15)
                    }
                    onClicked: {
                        contextMenu.open(parent, 0)
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
                            onClicked: editDialog.open(bookmarksTitle);
                        }

                        ListItem.Standard {
                            text: qsTr("Add to dash")
                            iconName: "action/dashboard"
                            onClicked: root.addToDash(url, title, color);
                        }

                        ListItem.Standard {
                            text: qsTr("Delete")
                            iconName: "action/delete"
                            onClicked: {
                                root.removeBookmark(url);
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
                            text: title
                            width: parent.width
                        }

                        TextField {
                            id: txtEditUrl
                            placeholderText: qsTr("URL")
                            floatingLabel: true
                            text: url
                            width: parent.width

                        }

                        TextField {
                            id: txtEditFaviconUrl
                            placeholderText: qsTr("Icon URL")
                            floatingLabel: true
                            text: faviconUrl
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
                            txtEditTitle.text = title;
                            txtEditUrl.text = url;
                            txtEditFaviconUrl.text = faviconUrl;
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
                            root.changeBookmark(url, txtEditTitle.text, txtEditUrl.text, txtEditFaviconUrl.text);
                            editDialog.close();
                        }
                    }


                }
            }
        }
    }


}
