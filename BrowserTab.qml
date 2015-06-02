import QtQuick 2.4
import Material 0.1

View {
    id: view

    property var page

    property alias title: _lbl.text
    property color color
    property color text_color
    signal close
    signal select (int tab_id)

    elevation: if (page.active) { 2 } else { 0 }
    height: root._tab_height
    width: root._tab_width

    function update_colors(){
        color = page.color;
        text_color = page.text_color;
    }

    Rectangle {
        id: rect_rounded
        width: parent.width
        height: Units.dp(5) * 2
        x: parent.x
        radius: if (root._tabs_rounded) { Units.dp(2) } else { 0 }
        color: view.color
    }

    Rectangle {
        width: parent.width
        height: parent.height - rect_rounded.height / 2
        x: parent.x
        y: parent.y + rect_rounded.height / 2
        color: view.color

        Row {
            anchors.fill: parent
            anchors.leftMargin: Units.dp(5)
            anchors.rightMargin: Units.dp(5)
            spacing: 5

            Text {
                id: _lbl
                text: page.title
                color: view.text_color
                width: parent.width - Units.dp(30)
                elide: Text.ElideRight
                smooth: true
                clip:true
                anchors.verticalCenter: parent.verticalCenter

            }

            IconButton {
               id: _btn_close
               color: view.text_color
               anchors.verticalCenter: parent.verticalCenter
               iconName: "navigation/close"
               onClicked: page.close()
            }

        }

    }

    MouseArea {
        width: parent.width - _btn_close.width
        height: parent.height
        onClicked: page.select()
    }

}
