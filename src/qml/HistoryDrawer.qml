import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem


NavigationDrawer {
    id: drawer
    z: 25
    mode: "right"
    width: Units.dp(350)
    visible: anchors.rightMargin != -width - Units.dp(10)
    View {
        id: historyTitle
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
            text: qsTr("History")
            style: "title"
        }

        Button {
            id: clearHistory
            text: qsTr("Clear History")
            elevation: 1

            anchors {
                right: parent.right
                leftMargin: Units.dp(16)
                rightMargin: Units.dp(16)
                verticalCenter: parent.verticalCenter
            }

            backgroundColor: Theme.accentColor

            onClicked: {
                root.app.historyModel.clear()
            }
        }

    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            top: historyTitle.bottom
            bottom: parent.bottom
        }

        ListView {
            id: listView

            bottomMargin: Units.dp(8)
            interactive: count > 0
            model: root.app.historyModel
            delegate: historyItemDelegate

            Column {
                visible: listView.count == 0
                anchors.centerIn: parent
                spacing: Units.dp(8)

                Icon {
                    name: "action/history"
                    size: Units.dp(48)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    style: "subheading"
                    color: Theme.light.subTextColor
                    text: qsTr("No browser history found")
                    font.pixelSize: Units.dp(17)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Component {
        id: historyItemDelegate

        Item {
            height: childrenRect.height

            anchors {
                left: parent.left
                right: parent.right
            }

            ListItem.Subheader {
                text: title
                visible: type == "date"
            }

            ListItem.Standard {
                visible: type == "entry"
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
            }
        }
    }
}
