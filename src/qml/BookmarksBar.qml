import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: bookmarksBar

    color: toolbar.backgroundColor
    height: visible ? Units.dp(48) : 0

    anchors {
        left: parent.left
        right: parent.right
    }



    property alias bookmarkContainer: bookmarkContainer

    Flickable {
        anchors.fill: parent
        anchors.margins: Units.dp(5)
        anchors.leftMargin: Units.dp(24)
        contentWidth: bookmarkContainer.implicitWidth + Units.dp(16)

        Row {
            id: bookmarkContainer
            anchors.fill: parent
            spacing: Units.dp(15)
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}

