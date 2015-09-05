import QtQuick 2.0
import QtQuick.Controls 1.4

import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: root._tab_height
        width: editModeActive ? root._tab_width_edit : root._tab_width

        property color inactiveColor: (root.app.tabs_entirely_colorized && modelData.customColorLight) ? modelData.customColorLight: root._tab_color_inactive
        property color activeColor: (root.app.tabs_entirely_colorized && modelData.customColor) ? modelData.customColor: root._tab_color_active
        property color backgroundColor: (rect_container.state == "active") ? activeColor : inactiveColor
        property color defaultTextColor: (rect_container.state == "active") ? root._tab_text_color_active : root._tab_text_color_inactive
        property color textColor: (root.app.tabs_entirely_colorized && modelData.customTextColor) ? modelData.customTextColor: defaultTextColor
        //property color draggingColor: root._tab_color_dragging
        property alias state: rect_container.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url

        property bool editModeActive: false

        onEditModeActiveChanged: {
            if (editModeActive) {
                if (activeTabInEditModeItem && activeTabInEditModeItem !== item) {
                    activeTabInEditModeItem.editModeActive = false;
                }

                ensureTabIsVisible(uid);
                canvas_edit_background.height = parent.height;
                item_edit_components.opacity = 1;
                txt_url.forceActiveFocus();
                txt_url.selectAll();

                root.activeTabInEditMode = editModeActive;
                activeTabInEditModeItem = item;
            }
            else {
                canvas_edit_background.height = 0;
                item_edit_components.opacity = 0;
            }
            root.activeTabInEditMode = editModeActive;
        }


        Rectangle {
            id: rect_container
            anchors.fill: parent

            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            states: [
                State {
                    name: "active"
                    PropertyChanges {
                        target: rect_default
                        color: item.activeColor
                    }

                    StateChangeScript {
                      script: {
                        root.activeTabItem = item;
                      }
                    }
                },

                State {
                    name: "inactive"
                    PropertyChanges {
                        target: rect_default
                        color: item.inactiveColor
                    }
                },

                State {
                    name: "dragging"; when: mouseArea.draggingId == rect_container.uid
                    PropertyChanges {
                        target: rect_default
                        //color: item.draggingColor
                        x: mouseArea.mouseX-rect_default.width/2;
                        z: 10;
                        parent: listView
                        anchors.fill: null
                        y: item.y
                        width: item.width
                        height: item.height
                    }
                }
            ]

            Rectangle {
                id: rect_default
                anchors.fill: parent
                visible: !item.editModeActive
                color: backgroundColor

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
                        color: item.textColor
                        width: parent.width - closeButton.width - icon.width - prg_loading.width - Units.dp(16)
                        elide: Text.ElideRight
                        smooth: true
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: root.font_family

                    }

                    IconButton {
                        id: closeButton
                        color: item.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        visible: modelData.hasCloseButton
                        iconName: modelData.closeButtonIconName
                        onClicked: {
                            removeTab(uid);
                        }
                    }
                }

                Rectangle {
                    id: rect_indicator
                    color: root._tab_indicator_color
                    visible: !root.app.tabs_entirely_colorized && rect_container.state == "active"
                    height: Units.dp(1)
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var is_already_active = (rect_container.state == "active")
                        root.activeTab = modelData;
                        if (is_already_active && root.app.integrated_addressbars && mouse.x < closeButton.x && !modelData.webview.new_tab_page) {
                            item.editModeActive = true;
                        }
                        mouse.accepted = false;
                    }
                }
            }
        }

        Rectangle {
            id: rect_edit
            visible: item.editModeActive

            anchors.fill: parent

            Item {
                id: item_edit_components
                anchors.fill: parent
                opacity: 0
                z: 1
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                IconButton {
                    id: btn_go_back
                    iconName : "navigation/arrow_back"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: Units.dp(16)
                    enabled: modelData.webview.canGoBack

                    onClicked: modelData.webview.goBack()
                    color: root._icon_color
                }

                IconButton {
                    id: btn_go_forward
                    iconName : "navigation/arrow_forward"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btn_go_back.right
                    anchors.margins: if (webview.canGoForward) { Units.dp(16) } else { 0 }
                    enabled: modelData.webview.canGoForward
                    visible: modelData.webview.canGoForward
                    width: if (modelData.webview.canGoForward) { Units.dp(24) } else { 0 }

                    Behavior on width {
                        SmoothedAnimation { duration: 200 }
                    }

                    onClicked: modelData.webview.goForward()
                    color: root._icon_color
                }

                IconButton {
                    id: btn_refresh
                    visible: !modelData.webview.loading
                    width: Units.dp(24)
                    hoverAnimation: true
                    iconName : "navigation/refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btn_go_forward.right
                    anchors.margins: Units.dp(16)
                    color: root._icon_color
                    onClicked: {
                        item.editModeActive = false;
                        modelData.webview.reload();
                    }
                }

                LoadingIndicator {
                    id: prg_loading_edit
                    visible: modelData.webview.loading
                    width: Units.dp(24)
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btn_go_forward.right
                    anchors.margins: Units.dp(16)
                }

                Icon {
                    id: icon_connection_type
                    name: modelData.webview.secureConnection ? "action/lock" :  "social/public"
                    color:  modelData.webview.secureConnection ? "green" :  root.current_icon_color
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: prg_loading_edit.right
                    anchors.margins: Units.dp(16)
                }

                TextField {
                    id: txt_url
                    anchors.margins: Units.dp(5)
                    anchors.left: icon_connection_type.right
                    anchors.right: btn_txt_url_hide.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    text: modelData.webview.url
                    showBorder: false
                    onAccepted: {
                        item.editModeActive = false;
                        root.setActiveTabURL(text);
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            item.editModeActive = false;
                    }
                }

                IconButton {
                    id: btn_txt_url_hide
                    color: root._icon_color
                    anchors.margins: Units.dp(16)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: "hardware/keyboard_return"
                    onClicked: {
                        item.editModeActive = false;
                    }
                }

            }

            Canvas {
                id: canvas_edit_background
                visible: true
                height: 0
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                property color color: item.activeColor ? item.activeColor : root._tab_indicator_color
                Behavior on height {
                    SmoothedAnimation { duration: 100 }
                }
                onPaint: {
                    // get context to draw with
                    var ctx = getContext("2d");

                    ctx.clearRect(0, 0, width, height);
                    // setup the fill
                    ctx.fillStyle = color;
                    // begin a new path to draw
                    ctx.beginPath();
                    ctx.globalAlpha = 0.2;
                    // top-left start point
                    ctx.moveTo(0,0);
                    ctx.lineTo(width,0);
                    ctx.lineTo(width,height);
                    ctx.lineTo(0,height);
                    ctx.closePath();

                    // fill using fill style
                    ctx.fill();

                    // setup the stroke
                    ctx.strokeStyle = color;
                    ctx.globalAlpha = 1;
                    ctx.lineWidth = Units.dp(1)

                    // create a path
                    ctx.beginPath()
                    ctx.moveTo(0,0)
                    ctx.lineTo(width,0)

                    // stroke path
                    ctx.stroke()
                }
            }

        }

    }
}
