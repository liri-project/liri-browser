import QtQuick 2.4
import Material 0.2
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

        interactive: mouseArea.draggingId === -1

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true
            property int index: bookmarkView.indexAt(mouseX + bookmarkView.contentX, mouseY)
            property int draggingId: -1
            property int activeIndex
            propagateComposedEvents: true

            onClicked: mouse.accepted = false;

            onPressAndHold: {
                var item = bookmarkView.itemAt(mouseX + bookmarkView.contentX, mouseY);
                if(item !== null) {
                    bookmarkView.model.get(activeIndex=index).state = "dragging";
                    draggingId = bookmarkView.model.get(activeIndex=index).uid;
                }

            }
            onReleased: {
                draggingId = -1
                mouse.accepted = false;
            }
            onPositionChanged: {
                if (draggingId != -1 && index != -1 && index != activeIndex) {
                    bookmarkView.model.move(activeIndex, activeIndex = index, 1);
                    root.app.saveBookmarks();
                }
                mouse.accepted = false;

            }
            onDoubleClicked: {
                mouse.accepted = false;
            }

            onWheel: {
                bookmarkView.flick(wheel.angleDelta.y*10, 0);
            }
         }

    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}

