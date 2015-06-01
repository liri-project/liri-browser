import QtQuick 2.4
import Material 0.1

View {
    id: view

    property int tab_id

    property bool active: false
    property alias text: _lbl.text
    signal close
    signal select (int tab_id)

    elevation: if (active) {2} else {0}
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

    Rectangle {
        anchors.fill: parent
        color: if (active) { root._tab_color_active } else { root._tab_color_inactive }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Units.dp(5)
            anchors.rightMargin: Units.dp(5)
            spacing: 5

            Text {
                id: _lbl
                text: ""
                color: if (view.active) {root._tab_text_color_active} else {root._tab_text_color_inactive}
                width: parent.width - Units.dp(30)
                elide: Text.ElideRight
                smooth: true
                clip:true
                anchors.verticalCenter: parent.verticalCenter

            }

            IconButton {
               id: _btn_close
               color: if (view.active) {root._tab_text_color_active} else {root._tab_text_color_inactive}
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
