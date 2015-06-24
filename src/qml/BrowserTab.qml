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

        }
        else {

        }
    }

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            id: rect
            width: parent.width
            height: parent.height
            x: parent.x
            y: parent.y
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

    Item {
        id: container_details
        visible: false

        anchors.fill: parent

        TextField {
            id: address_bar
            anchors.fill: parent
            text: "https://google.com"
            showBorder: false
        }
    }


    Behavior on width {
        SmoothedAnimation { duration: 100 }
    }

    MouseArea {
        id: mouse_area
        width: parent.width - _btn_close.width
        height: parent.height
        onClicked: {
            var is_already_selected = page.active;
            page.select();
            if (is_already_selected) {
                view.width = Units.dp(300)
                container_details.visible = true;
                container.visible = false
                mouse_area.visible = false
                if (view.x + view.width >= root.flickable.contentX+root.flickable.contentWidth + Units.dp(48))
                    root.flickable.contentX = view.x + view.width + Units.dp(48);
                else
                    root.flickable.contentX = view.x + Units.dp(48);
                address_bar.forceActiveFocus();

            }
        }
    }

}
