import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0

View {
    id: drawer
    z:25
    backgroundColor: "white"
    elevation: 2
    property bool shadowIsHere: root.shadow.visible
    property bool toOpen: false
    Connections {
        target: root.shadow
        onVisibleChanged: {
            if(root.shadow.visible)
                drawer.toOpen = false
        }
    }

    width: Units.dp(350)
    anchors {
        right: parent.right
        top: parent.top
        bottom: parent.bottom
        rightMargin: toOpen && shadowIsHere ? 0 : -width - 20
    }

    children: parent.content

    Behavior on anchors.rightMargin {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutCubic
        }
    }

    function open() {
        root.shadow.visible = true
        toOpen = true
    }

    function close() {
        root.shadow.visible = false
        toOpen = false
    }
}
