import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: fullscreenBar

    z: 5
    visible: root.fullscreen
    height: Units.dp(48)

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Units.dp(24)
        anchors.rightMargin: Units.dp(24)
        spacing: Units.dp(24)

        Image {
            source: root.activeTab.webview.icon
            width: Units.dp(18)
            height: Units.dp(18)
            anchors.verticalCenter: parent.verticalCenter

        }

        Text {
            text: root.activeTab.webview.title
            anchors.verticalCenter: parent.verticalCenter
            font.family: root.fontFamily
        }

    }

    IconButton {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Units.dp(7)
        iconName: "navigation/fullscreen_exit"
        onClicked: {
            root.endFullscreenMode();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onEntered: {
            parent.opacity = 1.0;
        }

        onExited: {
            parent.opacity = 0.0;
        }
    }

    onVisibleChanged: {
        if (visible) {
            var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", parent);
            timer.interval = 1500;
            timer.repeat = false;
            timer.triggered.connect(function () {
                opacity = 0
            });

            timer.start();
        }
    }
}
