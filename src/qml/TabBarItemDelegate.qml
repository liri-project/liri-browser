import QtQuick 2.0
import QtQuick.Controls 1.4

import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: root._tab_height
        width: root._tab_width

        property color inactiveColor: root._tab_color_inactive
        property color activeColor: root._tab_color_active
        property color draggingColor: root._tab_color_dragging
        property alias state: rect.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url

        Rectangle {
            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            id: rect
            anchors.fill: parent

            Row {
                anchors.fill: parent
                anchors.leftMargin: Units.dp(20)
                anchors.rightMargin: Units.dp(5)
                spacing: Units.dp(7)

                Image {
                    id: icon
                    //visible: icon_url !== ""
                    visible: !modelData.webview.loading && !modelData.webview.new_tab_page
                    width: webview.loading ?  0 : Units.dp(20)
                    height: Units.dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.webview.icon
                }

                Icon {
                    id: icon_dashboard
                    name: "action/dashboard"
                    visible: modelData.webview.new_tab_page
                    anchors.verticalCenter: parent.verticalCenter
                }

                LoadingIndicator {
                    id: prg_loading
                    visible: modelData.webview.loading
                    width: webview.loading ? Units.dp(24) : 0
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: title
                    text: modelData.webview.title
                    color: view.text_color
                    width: parent.width - closeButton.width - icon.width - prg_loading.width - Units.dp(16)
                    elide: Text.ElideRight
                    smooth: true
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.font_family

                }

                IconButton {
                    id: closeButton
                    color: root._tab_text_color_active
                    anchors.verticalCenter: parent.verticalCenter
                    visible: modelData.hasCloseButton
                    iconName: modelData.closeButtonIconName
                    onClicked: {
                        removeTab(uid);
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
                    root.activeTab = modelData;
                    mouse.accepted = false;
                }
                propagateComposedEvents: true
            }
        }
    }
}
