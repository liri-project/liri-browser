import QtQuick 2.4
import QtGraphicalEffects 1.0
import Material 0.1

Item {
    id: view
    z: 5

    property var page

    property alias title: _lbl.text
    property color color
    property color text_color
    property color icon_color

    property var webview

    signal close
    signal select (int tab_id)

    height: root._tab_height
    width: root._tab_width

    function update_colors(){
        color = page.color;
        text_color = page.text_color;
        icon_color = page.icon_color;
        if (page.active){
            drop_shadow.visible = true;
            fake_shadow.visible = false;
        }
        else {
            drop_shadow.visible = false;
            fake_shadow.visible = true;
        }
    }

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            id: rect
            width: parent.width - Units.dp(3)
            height: parent.height - Units.dp(3)
            x: parent.x + Units.dp(3)
            y: parent.y + Units.dp(3)
            color: view.color

            Row {
                anchors.fill: parent
                anchors.leftMargin: Units.dp(20)
                anchors.rightMargin: Units.dp(5)
                spacing: Units.dp(7)

                Image {
                    id: img_favicon
                    source: view.webview.icon //view.favicon
                    //visible: icon_url !== ""
                    width: Units.dp(20)
                    height: Units.dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: _lbl
                    text: page.title
                    color: view.text_color
                    width: parent.width - _btn_close.width - img_favicon.width - Units.dp(16)
                    elide: Text.ElideRight
                    smooth: true
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.font_family

                }

                IconButton {
                   id: _btn_close
                   color: icon_color
                   anchors.verticalCenter: parent.verticalCenter
                   iconName: "navigation/close"
                   onClicked: page.close()
                }

            }

        }

    }

    DropShadow {
        id: drop_shadow
        anchors.fill: container
        horizontalOffset: -Units.dp(3)
        verticalOffset: -Units.dp(3)

        radius: 8.0;
        samples: 16;
        color: "#dadada";

        smooth: true;
        source: container;
    }

    Rectangle {
        z: 2
        id: fake_shadow
        color: "#dadada";
        width: parent.width
        height: Units.dp(3)
        x: 0
        y: parent.height - height
    }

    MouseArea {
        width: parent.width - _btn_close.width
        height: parent.height
        onClicked: page.select()
    }

}
