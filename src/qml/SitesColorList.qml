
import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem

Item {
    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: 1000

            Item {
              height: Units.dp(60)
              width: parent.width
              Label {
                  style: "title"
                  text: qsTr("Sites")
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.margins: Units.gu(1)
                  anchors.left: parent.left
              }
            }
            ListView {
                id: listView
                anchors.fill: parent
                model: root.sitesColorModel
                anchors.margins: Units.gu(1)
                spacing: Units.dp(16)

                delegate: ListItem.Standard {
                    text: listView.model.get(index).domain
                    TextField {
                        text: listView.model.get(index).color
                        anchors{
                            margins: Units.dp(10)
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                         }
                    }
                }

            }

        }
        ActionButton {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Units.dp( 48 )
            iconName: "content/add"
            text: qsTr("Add new color")
            onClicked: root.addColorSite();
        }

}
