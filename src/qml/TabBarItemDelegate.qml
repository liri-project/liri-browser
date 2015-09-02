import QtQuick 2.0
import QtQuick.Controls 1.4

import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: listView.height
        width: Units.dp(256)

        property color inactiveColor: "grey"
        property color activeColor: "white"
        property color draggingColor: "green"
        property alias state: rect.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url

        Rectangle {
            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            id: rect
            anchors.fill: parent

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Units.dp(16)

                Image {
                    id: icon
                    width: source != "" ? Units.dp(16) : 0
                    height: source != "" ? Units.dp(16) : 0
                    source: modelData.iconSource
                }

                Text {
                    id: title
                    text: modelData.title
                    width: parent.width - icon.width - closeButton.width
                }

                IconButton {
                    id: closeButton
                    visible: modelData.hasCloseButton
                    iconName: modelData.closeButtonIconName
                    onClicked: {
                        console.log("on close")
                        removeTab(uid)
                    }
                }
            }

            states: [
                State {
                    name: "active"
                    PropertyChanges {
                        target: rect
                        color: item.activeColor
                    }
                },

                State {
                    name: "inactive"
                    PropertyChanges {
                        target: rect
                        color: item.inactiveColor

                    }
                },

                State {
                    name: "dragging"; when: mouseArea.draggingId == rect.uid
                    PropertyChanges {
                        target: rect
                        color: item.draggingColor
                        x: mouseArea.mouseX-rect.width/2;
                        z: 10;
                        parent: listView
                        anchors.fill: null
                        y: item.y
                        width: item.width
                        height: item.height

                    }
                }
            ]

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("*");
                    tabView.activeTab = modelData

                    mouse.accepted = false;
                }
                propagateComposedEvents: true
            }
        }
    }
}
