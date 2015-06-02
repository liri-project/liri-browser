import QtQuick 2.4
import Material 0.1
import QtQuick.Controls 1.3 as Controls
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import "TabManager.js" as TabManager


ApplicationWindow {
    id: root

    title: "Browser"
    visible: true

    theme {
        //backgroundColor: ""
        primaryColor: "#FF4719"
        //primaryDarkColor: ""
        accentColor: "#00bcd4"
        //tabHighlightColor: ""
    }

    /* Internal Style Settings */
    property color _tab_background_color: "#fafafa"
    property int _tab_height: Units.dp(40)
    property int _tab_width: Units.dp(160)
    property bool _tabs_rounded: false
    property int _tabs_spacing: 1
    property int _titlebar_height: Units.dp(100)
    property color _tab_color_active: "#eeeeee"
    property color _tab_color_inactive: "#e0e0e0"
    property color _tab_text_color_active: "#212121"
    property color _tab_text_color_inactive: "#757575"
    property color _icon_color: "#757575"
    property color _address_bar_color: "#e0e0e0"
    property color current_text_color: _tab_text_color_active


    /* Tab Management */
    property var tabs: []
    property int current_tab_id: -1
    property int last_tab_id: -1


    /* User Settings */
    property string start_page: "https://www.google.com"



    initialPage: Item {
        id: page

        Rectangle {
            id: titlebar
            width: parent.width
            height: root._titlebar_height
            color: root._tab_background_color

            Flickable {
                id: flickable
                width: parent.width
                height: root._tab_height
                contentHeight: this.height
                contentWidth: tab_row.width + rect_add_tab.width + Units.dp(16)

                Row {
                    id: tab_row
                    spacing: root._tabs_spacing
                    anchors.rightMargin: 50
                }

                Rectangle {

                    anchors.left: tab_row.right
                    visible: !(flickable.contentWidth > flickable.width)

                    color: root._tab_background_color
                    height: root._tab_height
                    width: Units.dp(48)
                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root._icon_color
                        iconName: "content/add"

                        onClicked: TabManager.add_tab();
                    }
                }

            }
            View {
                elevation: 2
                x: flickable.width - this.width
                height: root._tab_height
                width: Units.dp(48)
                visible: (flickable.contentWidth > flickable.width)

                Rectangle {
                    id: rect_add_tab
                    anchors.fill: parent
                    color: root._tab_background_color
                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root._icon_color
                        iconName: "content/add"

                        onClicked: root.add_tab()
                    }
                }
            }


            Item {
                anchors.top: flickable.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right


                Rectangle {
                    id: toolbar
                    anchors.fill: parent
                    color: root._tab_color_active

                    Row {
                        anchors.fill: parent
                        spacing: 5

                        IconButton {
                            id: btn_go_back
                            iconName : "navigation/arrow_back"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: TabManager.current_tab_page.go_back()
                            color: root.current_text_color
                        }

                        IconButton {
                            id: btn_go_forward
                            iconName : "navigation/arrow_forward"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: TabManager.current_tab_page.go_forward()
                            color: root.current_text_color
                        }

                        IconButton {
                            id: btn_refresh
                            hoverAnimation: true
                            iconName : "navigation/refresh"
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.current_text_color
                            onClicked: TabManager.current_tab_page.reload()
                        }

                        LoadingIndicator {
                            id: prg_loading
                            visible: false
                            width: btn_refresh.width
                            height: btn_refresh.height
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: parent.width - this.x - right_toolbar.width - parent.spacing
                            radius: Units.dp(2)
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height - Units.dp(16)
                            color: root._address_bar_color
                            opacity: 0.5

                            TextField{
                                id: txt_url
                                anchors.fill: parent
                                anchors.leftMargin: Units.dp(5)
                                anchors.rightMargin: Units.dp(5)
                                anchors.topMargin: Units.dp(4)
                                text: ""
                                opacity: 1
                                textColor: root._tab_text_color_active
                                onAccepted: {
                                    TabManager.set_current_tab_url(txt_url.text);
                                }

                            }

                        }

                        Row {
                            id: right_toolbar
                            width: childrenRect.width
                            anchors.verticalCenter: parent.verticalCenter

                            IconButton {
                                id: btn_bookmark
                                color: root.current_text_color
                                iconName : "action/bookmark_outline"
                                anchors.verticalCenter: parent.verticalCenter

                            }

                            IconButton {
                                id: btn_menu
                                color: root.current_text_color
                                iconName : "navigation/more_vert"
                                anchors.verticalCenter: parent.verticalCenter

                            }

                        }

                    }
                }

            }

        }

        Item {
            anchors.top: titlebar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Controls.ScrollView {
                anchors.fill: parent
                id: web_container

            }

        }
    }

    ActionButton {

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Units.dp(32)
        }

        iconName: "social/share"

        onClicked: {
            snackbar_bookmark.open('Added bookmark "' + root.get_tab_by_id(root.current_tab_id).webview.title + '"')
        }
    }

    Snackbar {
        id: snackbar_bookmark
        buttonText: "Undo"
        onClicked: {
            console.log('Undo Bookmark Creation ...')
        }
    }

    Snackbar {
        id: snackbar_tab_close
        property string url: ""
        buttonText: "Reopen"
        onClicked: {
            console.log('Reopen url '+ url)
        }
    }

}
