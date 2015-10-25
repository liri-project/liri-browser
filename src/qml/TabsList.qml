import QtQuick 2.0
import Material 0.1

Item {

    ListView {
        id: listView
        anchors.fill: parent
        model: root.tabsModel
        anchors.margins: Units.gu(1)
        spacing: Units.dp(16)

        delegate: Card {
            property int uid: (index >= 0) ? listView.model.get(index).uid : -1

            property color backgroundColor: root.defaultBackgroundColor
            property color defaultTextColor: root.defaultForegroundColor
            property color textColor: defaultTextColor

            width: parent.width
            height: Units.dp(48)

            Rectangle {
                color: backgroundColor
                anchors.fill: parent

                Row {
                    id: row
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: closeButton.left
                    spacing: Units.dp(16)
                    anchors.margins: Units.dp(16)

                    Image {
                        id: icon
                        visible: isAFavicon && !model.webview.loading && !model.webview.newTabPage && !model.webview.settingsTabPage && model.webview.url != "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        width: webview.loading ?  0 : Units.dp(20)
                        height: Units.dp(20)
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.webview.icon
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
                        color: textColor
                        name: "action/description"
                        visible: !icon.isAFavicon && !model.webview.loading && !model.webview.newTabPage && !model.webview.settingsTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconDashboard
                        color: textColor
                        name: "action/dashboard"
                        visible: model.webview.newTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSettings
                        color: textColor
                        name: "action/settings"
                        visible: model.webview.settingsTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        id: iconSource
                        name: "action/code"
                        visible: model.webview.url == "http://liri-browser.github.io/sourcecodeviewer/index.html"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    LoadingIndicator {
                        id: prgLoading
                        visible: model.webview.loading
                        width: model.webview.loading ? Units.dp(24) : 0
                        height: Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: model.webview.title
                        color: textColor
                        width: parent.width - closeButton.width - icon.width - prgLoading.width - Units.dp(16)
                        elide: Text.ElideRight
                        smooth: true
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: root.fontFamily
                    }

                }

                MouseArea {
                    x: row.x
                    y: row.y
                    width: row.width
                    height: row.height

                    onClicked: {
                        setActiveTab(uid, true);
                        page.pop();
                    }
                }

                IconButton {
                    id: closeButton
                    color: textColor
                    anchors.right: parent.right
                    anchors.rightMargin: Units.dp(16)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.hasCloseButton
                    iconName: model.closeButtonIconName
                    onClicked: {
                        console.log("Close tab")
                        root.removeTab(uid);
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
        text: qsTr("Add tab")
        onClicked: root.addTab();
    }

}
