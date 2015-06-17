import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem


NavigationDrawer {
    id: drawer
    z: 25
    mode: "right"
    width: Units.dp(350)    

    Column {
        anchors.fill: parent
        anchors.margins: Units.dp(24)
        spacing: Units.dp(5)

        View {
            id: history_title
            height: label.height + Units.dp(30)
            width: parent.width
            Label {
                id: label
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Units.dp(16)
                    rightMargin: Units.dp(16)
                    centerIn:parent
                }
                text:  qsTr("History")
                style: "title"
                font.pixelSize: Units.dp(24)
            }
        }

        Item {
            width: parent.width
            height: parent.height - history_title.height

            ListModel {
                id: history_model
                property var history: []
            }

            Component {
                id: history_item_delegate

                ListItem.Standard {
                    text: history_model.history[index]
                }
            }

            ScrollView {
                anchors.fill: parent
                ListView {
                    id: list_view
                    anchors.fill: parent

                    spacing: 5

                    model: history_model
                    delegate: history_item_delegate

                    Text {
                        visible: !list_view.count
                        font.family: root.font_family
                        text: qsTr("History unavailable")
                        anchors.top: history_title.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

            }


        }

    }

}
