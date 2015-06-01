import QtQuick 2.4
import Material 0.1

View {
    id: view

    property int tab_id

    property bool active: false
    property alias text: _lbl.text
    property var custom_color
    property color color
    property color text_color
    signal close
    signal select (int tab_id)

    elevation: if (active) { 2 } else { 0 }
    height: root._tab_height
    width: root._tab_width

    function remove() {
        view.destroy()
    }

    function smoothRemove() {
        var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", view);
        timer.interval = 350;
        timer.repeat = false;
        timer.triggered.connect(function () {
            view.remove();
        });

        timer.start()

    }

    function update_color() {
        if (active){
            if (custom_color) {
                color = custom_color;
                text_color = root.get_text_color_for_background(custom_color);
            }
            else {
                color = root._tab_color_active;
                text_color = root._tab_text_color_active;
            }
        }
        else{
            color = root._tab_color_inactive;
            text_color = root._tab_text_color_inactive;
        }
    }

    Rectangle {
        id: rect_rounded
        width: parent.width
        height: Units.dp(5) * 2
        x: parent.x
        radius: if (root._tabs_rounded) { Units.dp(2) } else { 0 }
        color: view.color //if (active) { root._tab_color_active } else { root._tab_color_inactive }
    }

    Rectangle {
        width: parent.width
        height: parent.height - rect_rounded.height / 2
        x: parent.x
        y: parent.y + rect_rounded.height / 2
        color: view.color //if (active) { root._tab_color_active } else { root._tab_color_inactive }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Units.dp(5)
            anchors.rightMargin: Units.dp(5)
            spacing: 5

            Text {
                id: _lbl
                text: ""
                color: text_color
                width: parent.width - Units.dp(30)
                elide: Text.ElideRight
                smooth: true
                clip:true
                anchors.verticalCenter: parent.verticalCenter

            }

            IconButton {
               id: _btn_close
               color: text_color
               anchors.verticalCenter: parent.verticalCenter
               iconName: "navigation/close"
               onClicked: view.close()
            }

        }

    }

    MouseArea {
        width: parent.width - _btn_close.width
        height: parent.height
        onClicked: {view.select(view.tab_id);}
    }

}
