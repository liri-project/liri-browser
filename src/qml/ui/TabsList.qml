import QtQuick 2.0
import Material 0.2

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
                        visible: isAFavicon && !model.view.loading && typeof(model.view.icon) !== 'string'
                        width: view.loading ?  0 : Units.dp(20)
                        height: Units.dp(20)
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.view.icon
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
                        visible: !icon.isAFavicon && !model.view.loading && typeof(model.view.icon) !== 'string'
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        color:  item.foregroundColor
                        Behavior on color { ColorAnimation { duration : 500 }}
                        visible: typeof(model.view.icon) === 'string' && !iconNoFavicon.visible
                        name: model.view.icon
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    LoadingIndicator {
                        id: prgLoading
                        visible: model.view.loading
                        width: model.view.loading ? Units.dp(24) : 0
                        height: Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: model.view.title
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
