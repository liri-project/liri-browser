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

    ListView {
        id: bookmarkView
        boundsBehavior: Flickable.StopAtBounds
        anchors.leftMargin: Units.dp(20)
        anchors.rightMargin: Units.dp(20)
        anchors.fill: parent
        model: root.app.bookmarksModel
        orientation: ListView.Horizontal
        spacing: Units.dp(20)
        delegate: BookmarkItem {}
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}

