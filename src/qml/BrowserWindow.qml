import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.3 as Controls
import "TabManager.js" as TabManager
import QtWebEngine 1.1
import Qt.labs.settings 1.0

ApplicationWindow {
    id: root

    property QtObject app

    title: "Browser"
    visible: true

    width: 1000
    height: 640

    theme {
        id: theme
        //backgroundColor: ""
        primaryColor: "#2196F3"
        primaryDarkColor: "#1976D2"
        accentColor: "#4CAF50"
        //tabHighlightColor: ""
    }

    /* User Settings */


    property alias settings: settings

    Settings {
        id: settings
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias primaryColor: theme.primaryColor
        property alias accentColor: theme.accentColor
    }

    /* Style Settings */
    property color _tab_background_color: "#f1f1f1"
    property int _tab_height: Units.dp(40)
    property int _tab_width: Units.dp(200)
    property int _tab_width_edit: Units.dp(400)
    property bool _tabs_rounded: false
    property int _tabs_spacing: Units.dp(1)
    property int _titlebar_height: Units.dp(148)
    property color _tab_color_active: "#ffffff"
    property color _tab_color_inactive: "#e5e5e5"
    property alias _tab_indicator_color: theme.accentColor
    property color _tab_text_color_active: "#212121"
    property color _tab_text_color_inactive: "#757575"
    property color _icon_color: "#7b7b7b"
    property color _address_bar_color: "#e0e0e0"
    property color current_text_color: _tab_text_color_active
    property color current_icon_color: _icon_color

    property string font_family: "Roboto"

    property alias current_tab_icon: current_tab_icon
    property alias txt_search: txt_search
    property alias downloads_drawer: downloads_drawer
    property alias icon_connection_type: icon_connection_type
    property alias flickable: flickable

    property bool fullscreen: false
    property bool secure_connection: false

    function start_fullscreen_mode(){
        fullscreen = true;
        showFullScreen();

    }

    function end_fullscreen_mode() {
        fullscreen = false;
        showNormal();
    }

    function show_search_overlay() {
        website_search_overlay.visible = true;
        txt_search.forceActiveFocus();
        txt_search.selectAll();
    }

    function hide_search_overlay() {
        website_search_overlay.visible = false;
        TabManager.current_tab_page.find_text("");
    }

    function get_tab_manager() {
        return TabManager;
    }

    function remove_bookmark(url) {
        return TabManager.remove_bookmark(url);
    }

    function add_tab(url, background){
        return TabManager.add_tab(url, background)
    }

    function get_current_tab() {
        return TabManager.current_tab_page
    }

    function download_requested(download) {
       root.downloads_drawer.append(download);
       download.accept();
    }

    ShortcutActions {}

    initialPage: Rectangle {
        id: page

        View {
            visible: !root.fullscreen
            id: titlebar
            width: parent.width
            height: if (root.app.integrated_addressbars) {flickable.height + bookmark_bar.height} else {flickable.height + toolbar.height + bookmark_bar.height}

            elevation: Units.dp(2)

            /*onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = Units.dp(3);
                ctx.strokeStyle = "#dadada";
                ctx.fillStyle = "#dadada";
                ctx.moveTo(flickable.x, flickable.height - Units.dp(1));
                ctx.lineTo(flickable.x+flickable.width, flickable.height - ctx.lineWidth);
                ctx.fill()
                ctx.stroke();
            }*/

            Flickable {
                id: flickable
                width: parent.width
                height: root._tab_height
                contentHeight: height
                contentWidth: tab_row.width + btn_add_tab.width + Units.dp(100)

                Behavior on contentX {
                    SmoothedAnimation { duration: 100 }
                }

                onFlickStarted: {
                    // TODO: Set current tab back to normal state
                }

                Row {
                    id: tab_row
                    x: if (this.children.length > 0 ){flickable.x + 0} else {parent.x}
                    spacing: 0 // root._tabs_spacing
                    anchors.rightMargin: Units.dp(50)
                }

                Rectangle {
                    id: btn_add_tab

                    anchors.left: tab_row.right
                    visible: !(flickable.contentWidth > flickable.width)

                    color: root._tab_background_color
                    height: root._tab_height - Units.dp(4)
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

            Rectangle {
                id: toolbar_integrated
                //elevation: if (flickable.contentWidth > flickable.width) { Units.dp(2) } else {0}
                anchors.top: flickable.top
                anchors.bottom: flickable.bottom
                anchors.right: flickable.right
                width: if (root.app.integrated_addressbars) { btn_add_tab_integrated.width + btn_downloads_integrated.width + btn_menu_integrated.width + Units.dp(24)*3 } else { Units.dp(48) }

                IconButton {
                    id: btn_add_tab_integrated
                    visible: (flickable.contentWidth > flickable.width)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: btn_downloads_integrated.left
                    anchors.margins:if (root.app.integrated_addressbars) { Units.dp(24) } else { 12 }
                    color: root._icon_color
                    iconName: "content/add"

                    onClicked: TabManager.add_tab();
                }

                IconButton {
                    id: btn_downloads_integrated
                    visible: root.app.integrated_addressbars && downloads_drawer.active_downloads
                    width: if (root.app.integrated_addressbars && downloads_drawer.active_downloads) { Units.dp(24) } else { 0 }
                    color: if (downloads_drawer.active_downloads){ theme.accentColor } else { root._icon_color }
                    iconName : "file/file_download"
                    anchors.right: btn_menu_integrated.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: if (root.app.integrated_addressbars && downloads_drawer.active_downloads) { Units.dp(24) } else { 0 }
                    onClicked: downloads_drawer.open(btn_downloads)// downloads_popup.open(btn_downloads)

                    Rectangle {
                        visible: downloads_drawer.active_downloads
                        z: -1
                        width: parent.width + Units.dp(5)
                        height: parent.height + Units.dp(5)
                        anchors.centerIn: parent
                        color: "white"
                        radius: width*0.5
                    }
                }

                IconButton {
                    id: btn_menu_integrated
                    visible: root.app.integrated_addressbars
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins:if (root.app.integrated_addressbars) { Units.dp(24) } else { 0 }
                    width: if (root.app.integrated_addressbars) { Units.dp(24) } else { 0 }
                    color: root._icon_color
                    iconName : "navigation/more_vert"
                    onClicked: overflow_menu.open(btn_menu_integrated)

                }

            }

            Item {
                id: toolbar_container
                visible: !integrated_addressbars
                anchors.top: flickable.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Column{
                    anchors.fill: parent

                    Rectangle {
                        id: toolbar
                        //anchors.fill: parent
                        height: Units.dp(64)
                        width: parent.width
                        color: root._tab_color_active

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Units.dp(24)
                            spacing: Units.dp(24)

                            IconButton {
                                id: btn_go_back
                                iconName : "navigation/arrow_back"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: TabManager.current_tab_page.go_back()
                                color: root.current_icon_color
                            }

                            IconButton {
                                id: btn_go_forward
                                iconName : "navigation/arrow_forward"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: TabManager.current_tab_page.go_forward()
                                color: root.current_icon_color
                            }

                            IconButton {
                                id: btn_refresh
                                hoverAnimation: true
                                iconName : "navigation/refresh"
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.current_icon_color
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

                                Icon {
                                    x: Units.dp(16)
                                    id: icon_connection_type
                                    name: if (root.secure_connection) { "action/lock" } else { "social/public" }
                                    color: if (root.secure_connection){ "green" } else {root.current_icon_color}
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                TextField {
                                    id: txt_url
                                    anchors.fill: parent
                                    anchors.leftMargin: icon_connection_type.x + icon_connection_type.width + Units.dp(16)
                                    anchors.rightMargin: Units.dp(24)
                                    anchors.topMargin: Units.dp(4)
                                    showBorder: false
                                    text: ""
                                    placeholderText: qsTr("Input search or web address")
                                    opacity: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    textColor: root._tab_text_color_active
                                    onAccepted: {
                                        TabManager.set_current_tab_url(txt_url.text);
                                    }

                                }

                            }

                            Row {
                                id: right_toolbar
                                width: childrenRect.width + spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Units.dp(24)

                                IconButton {
                                    id: btn_bookmark
                                    color: root.current_icon_color
                                    iconName: "action/bookmark_border"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: TabManager.current_tab_page.bookmark()
                                }

                                IconButton {
                                    id: btn_downloads
                                    color: if (downloads_drawer.active_downloads){ theme.accentColor } else {root.current_icon_color}
                                    iconName : "file/file_download"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: downloads_drawer.open(btn_downloads)// downloads_popup.open(btn_downloads)

                                    Rectangle {
                                        visible: downloads_drawer.active_downloads
                                        z: -1
                                        width: parent.width + Units.dp(5)
                                        height: parent.height + Units.dp(5)
                                        anchors.centerIn: parent
                                        color: "white"
                                        radius: width*0.5
                                    }
                                }

                                IconButton {
                                    id: btn_menu
                                    color: root.current_icon_color
                                    iconName : "navigation/more_vert"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: overflow_menu.open(btn_menu)

                                }

                                Rectangle { width: Units.dp(24)} // placeholder

                            }

                        }
                    }

                    Rectangle {
                        id: bookmark_bar
                        color: toolbar.color
                        height: if (visible) { Units.dp(48) } else {0}
                        width: parent.width

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: Units.dp(5)
                            anchors.leftMargin: Units.dp(24)
                            contentWidth: bookmark_container.implicitWidth + Units.dp(16)

                            Row {
                                id: bookmark_container
                                anchors.fill: parent
                                spacing: Units.dp(15)

                            }

                        }

                    }


                    Dropdown {
                        id: overflow_menu
                        objectName: "overflowMenu"

                        width: Units.dp(250)
                        height: columnView.height + Units.dp(16)

                        ColumnLayout {
                            id: columnView
                            width: parent.width
                            anchors.centerIn: parent

                            ListItem.Standard {
                                text: qsTr("New window")
                                iconName: "action/open_in_new"
                                onClicked: app.createWindow()
                            }

                            /*ListItem.Standard {
                                text: qsTr("Save page")
                                iconName: "content/save"
                            }

                            ListItem.Standard {
                                text: qsTr("Print page")
                                iconName: "action/print"
                            }*/

                            ListItem.Standard {
                                text: qsTr("History")
                                iconName: "action/history"
                                onClicked: { overflow_menu.close(); history_drawer.open(); }
                            }

                            ListItem.Standard {
                                text: qsTr("Fullscreen")
                                iconName: "navigation/fullscreen"
                                onClicked: if (!root.fullscreen) {root.start_fullscreen_mode(); overflow_menu.close()}

                               }

                            ListItem.Standard {
                                text: qsTr("Search")
                                iconName: "action/search"
                                onClicked: root.show_search_overlay()
                            }

                            ListItem.Standard {
                                text: qsTr("Settings")
                                iconName: "action/settings"
                                onClicked: { overflow_menu.close(); settings_drawer.open(); }
                            }
                        }
                    }

                }

            }

        }


        Rectangle {
            id: fullscreen_bar
            z: 5
            visible: root.fullscreen
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Units.dp(48)

            Row {
                anchors.fill: parent
                anchors.leftMargin: Units.dp(24)
                anchors.rightMargin: Units.dp(24)
                spacing: Units.dp(24)

                Image {
                    id: current_tab_icon
                    width: Units.dp(18)
                    height: Units.dp(18)
                    anchors.verticalCenter: parent.verticalCenter

                }

                Text {
                    id: current_tab_title
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.font_family
                }

            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(7)
                iconName: "navigation/fullscreen_exit"
                onClicked: {
                    root.end_fullscreen_mode();
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true

                onEntered: {
                    parent.opacity = 1.0;
                }

                onExited: {
                    parent.opacity = 0.0;
                }

            }

            Behavior on opacity { NumberAnimation {duration: 300} }
            onVisibleChanged: {
                if (visible)
                    var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", parent);
                    timer.interval = 1500;
                    timer.repeat = false;
                    timer.triggered.connect(function () {
                        opacity = 0
                    });

                    timer.start();
            }

        }


        Item {
            anchors.top: if (fullscreen){parent.top} else { titlebar.bottom}
            anchors.topMargin: Units.dp(2)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Item {
                id: web_container
                anchors.fill: parent
            }

        }
    }

    SettingsDrawer { id: settings_drawer }

    DownloadsDrawer { id: downloads_drawer }

    HistoryDrawer { id: history_drawer }

    View {
        id: website_search_overlay
        visible: false
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Units.dp(48)
        elevation: Units.dp(4)

        Row {
            anchors.fill: parent
            anchors.margins: Units.dp(5)
            anchors.leftMargin: Units.dp(24)
            anchors.rightMargin: Units.dp(24)
            spacing: Units.dp(24)

            TextField {
                id: txt_search
                placeholderText: qsTr("Search")
                errorColor: "red"
                onAccepted: TabManager.current_tab_page.find_text(text)
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                iconName: "hardware/keyboard_arrow_up"
                onClicked: TabManager.current_tab_page.find_text(txt_search.text, true)
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                iconName: "hardware/keyboard_arrow_down"
                onClicked: TabManager.current_tab_page.find_text(txt_search.text)
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        IconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Units.dp(24)
            iconName: "navigation/close"
            color: root._icon_color
            onClicked: root.hide_search_overlay()
        }
    }

    Snackbar {
        id: snackbar
    }

    Snackbar {
        id: snackbar_tab_close
        property string url: ""
        buttonText: qsTr("Reopen")
        onClicked: {
            TabManager.add_tab(url);
        }
    }


    Component.onCompleted: {
        // Profile handling
        root.app.default_profile.downloadRequested.connect(root.download_requested);

        // Bookmark handling
        TabManager.load_bookmarks();
        root.app.bookmarks_changed.connect(TabManager.reload_bookmarks)
    }

}
