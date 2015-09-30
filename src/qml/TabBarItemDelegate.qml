import QtQuick 2.0
import QtQuick.Controls 1.2

import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: root.tabHeight
        width: editModeActive ? root.tabWidthEdit : root.tabWidth

        property color inactiveColor: (root.app.tabsEntirelyColorized && modelData.customColorLight) ? modelData.customColorLight: root.tabColorInactive
        property color activeColor: (root.app.tabsEntirelyColorized && modelData.customColor) ? modelData.customColor: root.tabColorActive
        property color backgroundColor: (rectContainer.state == "active") ? activeColor : inactiveColor
        property color defaultTextColor: (rectContainer.state == "active") ? root.tabTextColorActive : root.tabTextColorInactive
        property color textColor: (root.app.tabsEntirelyColorized && modelData.customTextColor) ? modelData.customTextColor: defaultTextColor
        //property color draggingColor: root.TabColorDragging
        property alias state: rectContainer.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url

        property bool editModeActive: false

        onEditModeActiveChanged: {
            if (editModeActive) {
                if (activeTabInEditModeItem && activeTabInEditModeItem !== item) {
                    activeTabInEditModeItem.editModeActive = false;
                }

                ensureTabIsVisible(uid);
                canvasEditBackground.height = parent.height;
                itemEditComponents.opacity = 1;
                txtUrl.forceActiveFocus();
                txtUrl.selectAll();

                root.activeTabInEditMode = editModeActive;
                activeTabInEditModeItem = item;
            }
            else {
                canvasEditBackground.height = 0;
                itemEditComponents.opacity = 0;
            }
            root.activeTabInEditMode = editModeActive;
        }


        Rectangle {
            id: rectContainer
            anchors.fill: parent

            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            states: [
                State {
                    name: "active"
                    PropertyChanges {
                        target: rectDefault
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
                        target: rectDefault
                        color: item.inactiveColor
                    }
                },

                State {
                    name: "dragging"; when: mouseArea.draggingId == rectContainer.uid
                    PropertyChanges {
                        target: rectDefault
                        //color: item.draggingColor
                        x: mouseArea.mouseX-rectDefault.width/2;
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
                id: rectDefault
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
                        //visible: iconUrl !== ""
                        visible: isAFavicon && !modelData.webview.loading && !modelData.webview.newTabPage && !modelData.webview.settingsTabPage && modelData.webview.url != "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        width: webview.loading ?  0 : Units.dp(20)
                        height: Units.dp(20)
                        anchors.verticalCenter: parent.verticalCenter
                        source: modelData.webview.icon
                        property var isAFavicon: true
                        onStatusChanged: {
                            if (icon.status == Image.Error || icon.status == Image.Null)
                                isAFavicon = false;
                            else
                                isAFavicon = true;
                        }
                    }

                    Icon {
                        id: iconNoFavicon
                        name: "action/description"
                        visible: !icon.isAFavicon && !modelData.webview.loading && !modelData.webview.newTabPage && !modelData.webview.settingsTabPage
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.iconColor
                    }

                    Icon {
                        id: iconDashboard
                        name: "action/dashboard"
                        visible: modelData.webview.newTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSettings
                        name: "action/settings"
                        visible: modelData.webview.settingsTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSource
                        name: "action/code"
                        visible: modelData.webview.url == "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    LoadingIndicator {
                        id: prgLoading
                        visible: modelData.webview.loading
                        width: webview.loading ? Units.dp(24) : 0
                        height: Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: title
                        text: modelData.webview.title
                        color: item.textColor
                        width: parent.width - closeButton.width - icon.width - prgLoading.width - Units.dp(16)
                        elide: Text.ElideRight
                        smooth: true
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: root.fontFamily

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
                    id: rectIndicator
                    color: root.tabIndicatorColor
                    visible: !root.app.tabsEntirelyColorized && rectContainer.state == "active"
                    height: Units.dp(1)
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.AllButtons

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            var isAlreadyActive = (rectContainer.state == "active")
                            root.activeTab = modelData;
                            if (isAlreadyActive && root.app.integratedAddressbars && mouse.x < closeButton.x) {
                                item.editModeActive = true;
                            }
                            mouse.accepted = false;
                        }
                        else if (mouse.button === Qt.MiddleButton) {
                            removeTab(uid);
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rectEdit
            visible: item.editModeActive

            anchors.fill: parent

            Item {
                id: itemEditComponents
                anchors.fill: parent
                opacity: 0
                z: 1
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                IconButton {
                    id: btnGoBack
                    iconName : "navigation/arrow_back"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: Units.dp(16)
                    enabled: modelData.webview.canGoBack

                    onClicked: modelData.webview.goBack()
                    color: root.iconColor
                }

                IconButton {
                    id: btnGoForward
                    iconName : "navigation/arrow_forward"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoBack.right
                    anchors.margins: if (webview.canGoForward) { Units.dp(16) } else { 0 }
                    enabled: modelData.webview.canGoForward
                    visible: modelData.webview.canGoForward
                    width: if (modelData.webview.canGoForward) { Units.dp(24) } else { 0 }

                    Behavior on width {
                        SmoothedAnimation { duration: 200 }
                    }

                    onClicked: modelData.webview.goForward()
                    color: root.iconColor
                }

                IconButton {
                    id: btnRefresh
                    visible: !modelData.webview.loading
                    width: Units.dp(24)
                    hoverAnimation: true
                    iconName : "navigation/refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                    color: root.iconColor
                    onClicked: {
                        item.editModeActive = false;
                        modelData.webview.reload();
                    }
                }

                LoadingIndicator {
                    id: prgLoadingEdit
                    visible: modelData.webview.loading
                    width: Units.dp(24)
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                }

                Icon {
                    id: iconConnectionType
                    name: modelData.webview.secureConnection ? "action/lock" :  "social/public"
                    color:  modelData.webview.secureConnection ? "green" :  root.currentIconColor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: prgLoadingEdit.right
                    anchors.margins: Units.dp(16)
                }

                TextField {
                    id: txtUrl
                    anchors.margins: Units.dp(5)
                    anchors.left: iconConnectionType.right
                    anchors.right: btnTxtUrlHide.left
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
                    id: btnTxtUrlHide
                    color: root.iconColor
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
                id: canvasEditBackground
                visible: true
                height: 0
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                property color color: item.activeColor ? item.activeColor : root.tabIndicatorColor
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
