import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles.Material 0.1
import Material 0.1

Component {
    id: component

    Item {
        id: item
        height: root.tabHeight
        width: editModeActive ? root.tabWidthEdit : root.tabWidth
        property int widthWithClose: editModeActive ? root.tabWidthEdit : root.tabWidth*1.7
        property int widthWithoutClose: editModeActive ? root.tabWidthEdit : root.tabWidth

        property color backgroundColor: itemContainer.state != "dragging" ? "transparent" : root.currentBackgroundColor
        property color foregroundColor: itemContainer.state == "inactive" ? root.currentInactiveForegroundColor: root.currentForegroundColor

        property alias state: itemContainer.state

        property QtObject modelData: listView.model.get(index)

        property url url: modelData.url ? modelData.url : ""

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


        Item {
            id: itemContainer
            anchors.fill: parent

            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            state: modelData.state

            states: [
                State {
                    name: "active"
                    StateChangeScript {
                      script: {
                        root.activeTabItem = item;
                      }
                    }
                },

                State {
                    name: "inactive"
                },

                State {
                    name: "dragging"; when: mouseArea.draggingId == itemContainer.uid
                    PropertyChanges {
                        target: rectDefault
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
                    anchors.leftMargin: Units.dp(10)
                    anchors.rightMargin: Units.dp(5)
                    spacing: Units.dp(7)

                    Image {
                        id: icon
                        visible: isAFavicon && !modelData.view.loading && typeof(modelData.view.icon) !== 'string'
                        width: view.loading ?  0 : Units.dp(20)
                        height: Units.dp(20)
                        anchors.verticalCenter: parent.verticalCenter
                        source: modelData.view.icon
                        property bool isAFavicon: true
                        onStatusChanged: {
                            if (icon.status == Image.Error || icon.status == Image.Null)
                                isAFavicon = false;
                            else
                                isAFavicon = true;
                        }
                    }

                    Icon {
                        id: iconNoFavicon
                        color:  item.foregroundColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        name: "action/description"
                        visible: !icon.isAFavicon && !modelData.view.loading && typeof(modelData.view.icon) !== 'string'
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        color:  item.foregroundColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        visible: typeof(modelData.view.icon) === 'string' && !iconNoFavicon.visible
                        name: modelData.view.icon
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    LoadingIndicator {
                        id: prgLoading
                        visible: modelData.view.loading
                        width: view.loading ? Units.dp(24) : 0
                        height: Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: title
                        text: root.app.uppercaseTabTitle ? modelData.view.title.toUpperCase() : modelData.view.title
                        color: item.foregroundColor
                        width: parent.width - closeButton.width - icon.width - prgLoading.width - Units.dp(16)
                        elide: Text.ElideRight
                        smooth: true
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: root.fontFamily
                        visible: !root.reduceTabsSizes
                        Behavior on color { ColorAnimation { duration : 500 }}
                    }

                    IconButton {
                        id: closeButton
                        color: item.foregroundColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        anchors.verticalCenter: parent.verticalCenter
                        visible: {
                            if(modelData.hasCloseButton) {
                               if(root.reduceTabsSizes) {
                                   if(itemContainer.state == "active") {
                                       item.width =  item.widthWithClose
                                       return true
                                    }
                                    else {
                                       item.width =  item.widthWithoutClose
                                       return false
                                    }
                               }
                               else
                                   item.width =  item.widthWithoutClose
                                   return true
                             }
                            else
                                item.width =  item.widthWithoutClose
                                return false
                        }
                        iconName: modelData.closeButtonIconName
                        onClicked: {
                            saveThisTabUrl(modelData.view.url)
                            removeTab(uid);
                        }
                    }
                }

                Rectangle {
                    id: rectIndicator
                    color: item.foregroundColor
                    visible: itemContainer.state == "active"
                    height: Units.dp(2)
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                MouseArea {
                    anchors.fill: parent

                    acceptedButtons: Qt.AllButtons

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            var isAlreadyActive = (itemContainer.state == "active")
                            root.activeTab = modelData;
                            if (isAlreadyActive && root.app.integratedAddressbars && mouse.x < closeButton.x) {
                                item.editModeActive = true;
                            }
                            mouse.accepted = false;
                        }
                        else if (mouse.button === Qt.MiddleButton) {
                            removeTab(uid);
                        }
                        else if (mouse.button === Qt.RightButton) {
                            if(!root.tabPreview.visible)
                                root.getTabModelDataByUID(uid).view.grabToImage(function(result) {
                                    root.tabPreview.source = result.url;
                                    root.tabPreview.visible = true
                                })
                            else
                                root.tabPreview.visible = false
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rectEdit
            visible: item.editModeActive
            color: backgroundColor

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
                    enabled: modelData.view.canGoBack

                    onClicked: modelData.view.goBack()
                    color: item.foregroundColor
                }

                IconButton {
                    id: btnGoForward
                    iconName : "navigation/arrow_forward"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoBack.right
                    anchors.margins: if (view.canGoForward) { Units.dp(16) } else { 0 }
                    enabled: modelData.view.canGoForward
                    visible: modelData.view.canGoForward
                    width: if (modelData.view.canGoForward) { Units.dp(24) } else { 0 }

                    Behavior on width {
                        SmoothedAnimation { duration: 200 }
                    }

                    onClicked: modelData.view.goForward()
                    color: item.foregroundColor
                }

                IconButton {
                    id: btnRefresh
                    visible: !modelData.view.loading
                    width: Units.dp(24)
                    hoverAnimation: true
                    iconName : "navigation/refresh"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                    color: item.foregroundColor
                    onClicked: {
                        item.editModeActive = false;
                        modelData.view.reload();
                    }
                }

                LoadingIndicator {
                    id: prgLoadingEdit
                    visible: modelData.view.loading
                    width: Units.dp(24)
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: btnGoForward.right
                    anchors.margins: Units.dp(16)
                }

                Icon {
                    id: iconConnectionType
                    name: modelData.view.secureConnection ? "action/lock" :  "social/public"
                    color:  modelData.view.secureConnection ? "green" :  item.foregroundColor
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
                    text: modelData.view.url
                    style: TextFieldStyle { textColor: root.currentForegroundColor }
                    showBorder: false
                    onTextChanged: {
                        if(isASearchQuery(text)) {
                            //connectionTypeIcon.searchIcon = true

                            //Get search suggestions
                            var req = new XMLHttpRequest, status;
                            req.open("GET", "https://duckduckgo.com/ac/?q=" + text);
                            req.onreadystatechange = function() {
                                status = req.readyState;
                                if (status === XMLHttpRequest.DONE) {
                                    var objectArray = JSON.parse(req.responseText);
                                    root.app.searchSuggestionsModel.clear();
                                    for(var i in objectArray)
                                        root.app.searchSuggestionsModel.append({"suggestion":objectArray[i].phrase})
                                }
                            }
                            req.send();
                        }
                        else {
                            root.app.searchSuggestionsModel.clear();
                            //connectionTypeIcon.searchIcon = false;
                        }

                    }
                    onAccepted: {
                        item.editModeActive = false;
                        root.setActiveTabURL(text);
                        root.selectedQueryIndex = 0
                    }
                    Keys.onDownPressed: {
                        if(root.selectedQueryIndex < root.app.searchSuggestionsModel.count - 1)
                            root.selectedQueryIndex += 1
                        text = root.app.searchSuggestionsModel.get(root.selectedQueryIndex).suggestion
                    }
                    Keys.onUpPressed: {
                        if(root.selectedQueryIndex >= 1)
                            root.selectedQueryIndex -= 1
                        text = root.app.searchSuggestionsModel.get(root.selectedQueryIndex).suggestion
                    }
                    onActiveFocusChanged: {
                        if (!activeFocus)
                            item.editModeActive = false;
                    }
                }

                IconButton {
                    id: btnTxtUrlHide
                    color: item.foregroundColor
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

                property color color: "transparent"
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
