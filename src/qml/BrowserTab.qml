import QtQuick 2.4
import QtQuick.Controls 1.2 as Controls
import QtGraphicalEffects 1.0
import Material 0.1

View {
    id: view

    property var page

    property alias title: _lbl.text
    property color color: root._tab_color_active
    property color text_color: root._tab_text_color_active
    property color icon_color: root._tab_text_color_active

    property var webview
    property alias txt_url: txt_url

    signal close
    signal select (int tab_id)

    height: root._tab_height
    width: root._tab_width

    state: "inactive"

    states: [
      State {
        name: "inactive"
        StateChangeScript {
          script: {
              view.width = root._tab_width;
              container_edit.visible = false;
              container_default.visible = true;
              mouse_area.visible = true;
              canvas_edit_background.height = 0;
              item_edit_components.opacity = 0;

              rect_indicator.visible = false;

              // Update colors
              icon_color = text_color = root._tab_text_color_inactive;
              color = root._tab_color_inactive;
              update_colors();
          }
        }
      },
      State {
        name: "active"
        StateChangeScript {
          script: {
              view.width = root._tab_width;
              container_edit.visible = false;
              container_default.visible = true;
              mouse_area.visible = true;
              canvas_edit_background.height = 0;
              item_edit_components.opacity = 0;

              if (!root.app.tabs_entirely_colorized)
                rect_indicator.visible = true;

              // Update colors
              icon_color = text_color = root._tab_text_color_active;
              color = root._tab_color_active;
              update_colors();
          }
        }
      },
      State {
        name: "active_edit"
        StateChangeScript {
          script: {
              mouse_area.visible = false;
              view.width = root._tab_width_edit;
              container_edit.visible = true;
              container_default.visible = false;
              view.ensure_visible(root._tab_width_edit);
              txt_url.forceActiveFocus();
              //rect_indicator_edit.y = 0;
              canvas_edit_background.height = container_edit.height;
              item_edit_components.opacity = 1;

              if (!root.app.tabs_entirely_colorized)
                rect_indicator.visible = true;

              // Update colors
              icon_color = text_color = root._tab_text_color_active;
              color = root._tab_color_active;

              update_colors();
          }
        }
      }
    ]

    function update_colors() {
        rect_indicator.color = page.custom_color || root._tab_indicator_color;
        canvas_edit_background.color = page.custom_color || root._tab_indicator_color;
        canvas_edit_background.requestPaint();

        if (root.app.tabs_entirely_colorized) {
            color = page.color;
            text_color = page.text_color;
            icon_color = page.icon_color;
        }
        else {
            if (state !== "inactive")
                color = root._tab_color_active;
            else
                color = root._tab_color_inactive;
            text_color = root._tab_text_color_active
            icon_color = root._tab_text_color_active
        }
    }

    function ensure_visible(width) {
        var right_margin = Units.dp(120)
        var spacing = Units.dp(64)
        if (!width)
            width = view.width;
        // Ensure that the tab is visible
        if (view.x + width >= flickable.contentX+root.flickable.width - right_margin) {
            root.flickable.contentX = view.x-root.flickable.width + width + right_margin + spacing;
        }
        else if (view.x < flickable.contentX) {
            if (view.x-spacing <= 0)
                root.flickable.contentX = 0;
            else
                root.flickable.contentX = view.x - spacing;
        }
    }

    Item {
        id: container_default
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
                    visible: !webview.loading && !webview.new_tab_page
                    width: if (webview.loading) { 0 } else { Units.dp(20) }
                    height: Units.dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Icon {
                    id: icon_dashboard
                    name: "action/dashboard"
                    visible: webview.new_tab_page
                    anchors.verticalCenter: parent.verticalCenter

                }

                LoadingIndicator {
                    id: prg_loading
                    visible: webview.loading
                    width: if (webview.loading) { Units.dp(24) } else { 0 }
                    height: Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: _lbl
                    text: page.title
                    color: view.text_color
                    width: parent.width - _btn_close.width - img_favicon.width - prg_loading.width - Units.dp(16)
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

            Rectangle {
                id: rect_indicator
                height: Units.dp(1)
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }

    }

    Item {
        id: container_edit
        visible: false

        anchors.fill: parent

        Item {
            id: item_edit_components
            anchors.fill: parent
            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            IconButton {
                id: btn_go_back
                iconName : "navigation/arrow_back"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: Units.dp(16)
                enabled: webview.canGoBack

                onClicked: root.get_tab_manager().current_tab_page.go_back()
                color: root._icon_color
            }

            IconButton {
                id: btn_go_forward
                iconName : "navigation/arrow_forward"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: btn_go_back.right
                anchors.margins: if (webview.canGoForward) { Units.dp(16) } else { 0 }
                enabled: webview.canGoForward
                visible: webview.canGoForward
                width: if (webview.canGoForward) { Units.dp(24) } else { 0 }

                Behavior on width {
                    SmoothedAnimation { duration: 200 }
                }

                onClicked: root.get_tab_manager().current_tab_page.go_forward()
                color: root._icon_color
            }

            IconButton {
                id: btn_refresh
                visible: !webview.loading
                width: Units.dp(24)
                hoverAnimation: true
                iconName : "navigation/refresh"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: btn_go_forward.right
                anchors.margins: Units.dp(16)
                color: root._icon_color
                onClicked: {
                    view.state = "active";
                    root.get_tab_manager().current_tab_page.reload();
                }
            }

            LoadingIndicator {
                id: prg_loading_edit
                visible: webview.loading
                width: Units.dp(24)
                height: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: btn_go_forward.right
                anchors.margins: Units.dp(16)
            }

            Icon {
                id: icon_connection_type
                name: if (root.secure_connection) { "action/lock" } else { "social/public" }
                color: if (root.secure_connection) { "green" } else {root.current_icon_color}
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: prg_loading_edit.right
                anchors.margins: Units.dp(16)
            }

            TextField {
                id: txt_url
                anchors.margins: Units.dp(5)
                anchors.left: icon_connection_type.right
                anchors.right: btn_txt_url_hide.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                text: "https://google.com"
                showBorder: false
                onAccepted: {
                    view.state = "active";
                    root.get_tab_manager().set_current_tab_url(txt_url.text);
                }
            }

            IconButton {
                id: btn_txt_url_hide
                color: root._icon_color
                anchors.margins: Units.dp(16)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "hardware/keyboard_return"
                onClicked: {
                    view.state = "active"
                }
            }

        }

        Canvas {
            id: canvas_edit_background
            visible: true
            height: 0
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            property color color
            z: -1
            Behavior on height {
                SmoothedAnimation { duration: 100 }
            }
            onPaint: {
                // get context to draw with
                var ctx = getContext("2d");

                ctx.clearRect(0, 0, width, height);
                // setup the fill
                ctx.fillStyle = color;
                // begin a new path to draw
                ctx.beginPath();
                ctx.globalAlpha = 0.2;
                // top-left start point
                ctx.moveTo(0,0);
                ctx.lineTo(width,0);
                ctx.lineTo(width,height);
                ctx.lineTo(0,height);
                ctx.closePath();

                // fill using fill style
                ctx.fill();

                // setup the stroke
                ctx.strokeStyle = color
                ctx.globalAlpha = 1;
                ctx.lineWidth = Units.dp(1)

                // create a path
                ctx.beginPath()
                ctx.moveTo(0,0)
                ctx.lineTo(width,0)

                // stroke path
                ctx.stroke()
            }
        }

        /*Rectangle {
            id: rect_edit_background
            height: 0
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            z: -1
            opacity: 0.2
            Behavior on height {
                SmoothedAnimation { duration: 100 }
            }
        }

        Rectangle {
            id: rect_indicator_edit
            color: "red"
            height: Units.dp(1)
            anchors.left: parent.left
            anchors.right: parent.right
            y: parent.height - height
            Behavior on y {
                SmoothedAnimation { duration: 100 }
            }
        }*/

    }


    Behavior on width {
        SmoothedAnimation { duration: 100 }
    }


    MouseArea {
        id: mouse_area
        width: parent.width - _btn_close.width
        height: parent.height
        onClicked: {
            var is_already_selected = (view.state == "active");
            page.select();
            if (is_already_selected && root.app.integrated_addressbars) {
                view.state = "active_edit";
            }
        }
    }

}
