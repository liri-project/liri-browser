import QtQuick 2.0
import Material 0.1

Rectangle {
    id: page_root
    anchors.fill: parent

    GridView {
        id: grid

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: 165; cellHeight: 95
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
                        source: icon_url
                    }

                    Text {
                        font.family: root.font_family
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Units.dp(16)
                        text: title
                        font.pixelSize: Units.dp(14)
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
            anchors.fill: parent
            hoverEnabled: true
            preventStealing : true
            property int index: grid.indexAt(mouseX, mouseY) //item underneath cursor
            property int activeId: -1 // uid of active item
            property int activeIndex // current position of active item

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
                if (index != -1) {
                    var url = grid.model.get(activeIndex=index).url;
                    webview.page.set_url(url);
                }
            }
        }


    }
}

