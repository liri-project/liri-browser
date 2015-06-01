import QtQuick 2.4
import Material 0.1
import QtQuick.Controls 1.3 as Controls
import QtWebKit 3.0
import QtWebKit.experimental 1.0


ApplicationWindow {
    id: application_window

    title: "Browser"
    visible: true

    theme {
        //backgroundColor: ""
        primaryColor: "#FF4719"
        //primaryDarkColor: ""
        accentColor: "#00bcd4"
        //tabHighlightColor: ""
    }


    /* User Settings */
    property string start_page: "https://www.google.com"



    initialPage: Item {
        id: root

        /* Internal Style Settings */         // Red and White | Green | Grey
        property color _tab_background_color: "#fafafa"
        property int _tab_height: Units.dp(40)
        property int _tab_width: Units.dp(160)
        property bool _tabs_rounded: false
        property int _tabs_spacing: 1 // Units.dp(5)
        property int _titlebar_height: Units.dp(100)
        property color _tab_color_active:       "#eeeeee"
        property color _tab_color_inactive:    "#e0e0e0"
        property color _tab_text_color_active: "#212121"
        property color _tab_text_color_inactive: "#757575"
        property color _icon_color: "#757575"
        property color _address_bar_color: "#e0e0e0"
        property color current_text_color: _tab_text_color_active


        /* Tab Management */
        property var tabs: []
        property int current_tab_id: -1
        property int last_tab_id: -1

        function get_text_color_for_background(bg) {
            // from http://stackoverflow.com/questions/12043187/how-to-check-if-hex-color-is-too-black
            var c = "#1b5e20".substring(1);      // strip #
            var rgb = parseInt(c, 16);   // convert rrggbb to decimal
            var r = (rgb >> 16) & 0xff;  // extract red
            var g = (rgb >>  8) & 0xff;  // extract green
            var b = (rgb >>  0) & 0xff;  // extract blue

            var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; // per ITU-R BT.709

            if (luma < 100) {
                return "white";
            }
            else {
                return "#212121"
            }
        }

        function get_tab_by_id(id) {
            for (var i=0; i<tabs.length; i++) {
                if (tabs[i].id === id)
                    return tabs[i]
            }
        }

        function add_tab(url) {
            if (!url)
                url = start_page;
            else {
                if (url.indexOf('.') !== -1){
                    if (url.lastIndexOf('http://', 0) !== 0){
                        if (url.lastIndexOf('https://', 0) !== 0){
                            url = 'http://' + url;
                        }
                    }
                }
                else
                    url = "http://www.google.com/search?q=" + url;

            }


            var new_tab_id = last_tab_id + 1
            last_tab_id = new_tab_id

            var browser_tab_component = Qt.createComponent("BrowserTab.qml");
            var browser_tab_object = browser_tab_component.createObject(tab_row, { tab_id: new_tab_id,text: "New Tab", });
            browser_tab_object.close.connect(function (){

                var tab_id = browser_tab_object.tab_id;
                get_tab_by_id(tab_id).webview.destroy()
                snackbar_tab_close.open('Closed tab "' + get_tab_by_id(tab_id).webview.title + '"');
                tabs.splice(tabs.indexOf(get_tab_by_id(tab_id)));

                browser_tab_object.remove();
                txt_url.text = ""
                if(current_tab_id === tab_id)
                    current_tab_id = -1;

            });
            browser_tab_object.select.connect(function(tab_id){
                set_current_tab(tab_id);
            });

            var webview_component = Qt.createComponent("BrowserWebView.qml");
            var webview_object = webview_component.createObject(web_container, { tab_id: new_tab_id, visible: false, url: url });
            webview_object.loadingChanged.connect(function(loadRequest){
                tab_loading_changed(webview_object.tab_id, loadRequest);
            });

            tabs.push({id: new_tab_id, webview: webview_object, tab: browser_tab_object})
            set_current_tab(new_tab_id)

        }

        function set_current_tab(tab_id) {
            if (tab_id === current_tab_id)
                return                
            var tab = get_tab_by_id(tab_id);
            tab.webview.visible = true;
            tab.tab.active = true;
            txt_url.text = tab.webview.url
            if (current_tab_id !== -1) {
                get_tab_by_id(current_tab_id).tab.active = false;
                get_tab_by_id(current_tab_id).webview.visible = false;
                get_tab_by_id(current_tab_id).tab.update_color();
            }
            current_tab_id = tab_id;
            application_window.title = tab.tab.text + ' - Browser';

            // Update tab color
            tab.tab.update_color();
            if (tab.tab.custom_color){
                current_text_color = get_text_color_for_background(tab.tab.custom_color);
                set_custom_bar_color(tab.tab.custom_color);
            }
            else {
                set_default_bar_color();
                current_text_color = _tab_text_color_active;
            }

            if (tab.webview.loading){
                prg_loading.visible = true;
                btn_refresh.visible = false;
            }
            else{
                prg_loading.visible = false;
                btn_refresh.visible = true;
            }
        }

        function set_current_tab_url(url) {
            if (tabs.length === 0 || current_tab_id === -1){
                add_tab(url);
                return;
            }

            var tab = get_tab_by_id(current_tab_id);

            if (url.indexOf('.') !== -1){
                if (url.lastIndexOf('http://', 0) !== 0){
                    if (url.lastIndexOf('https://', 0) !== 0){
                        url = 'http://' + url;
                    }
                }
            }

            tab.webview.url = url;
        }

        function current_tab_go_back() {
            var tab = get_tab_by_id(current_tab_id);
            tab.webview.goBack();
        }

        function tab_loading_changed(tab_id, request) {
            var tab = get_tab_by_id(tab_id)


            if (request.status === 0){
                console.log("LoadStartedStatus");
                if (tab_id === current_tab_id) {
                    prg_loading.visible = true;
                    btn_refresh.visible = false;
                }

            }
            else if (request.status === 2) {
                console.log("LoadFinishedStatus");
                if (tab_id === current_tab_id) {
                    prg_loading.visible = false;
                    btn_refresh.visible = true;
                }
                if (tab.webview.url !== txt_url.text)
                    tab.tab.text = tab.webview.title
                    if (tab_id === current_tab_id) {
                        txt_url.text = tab.webview.url
                        application_window.title = tab.webview.title + ' - Browser';
                    }

                    // Looking for custom tab bar colors
                    tab.webview.experimental.evaluateJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                        function(content){
                            if(content !== "") {
                                tab.tab.custom_color = content;
                                tab.tab.update_color();
                                if (tab_id === current_tab_id){
                                    set_custom_bar_color(content);
                                    current_text_color = get_text_color_for_background(content);
                                }
                            }
                            else{
                                tab.tab.custom_color = null;
                                tab.tab.update_color();
                                if (tab_id === current_tab_id)
                                    set_default_bar_color()
                            }
                    });

            }
            else if (request.status === 3) {
                console.log("LoadFailedStatus");
                var new_url = "http://www.google.com/search?q=" + txt_url.text
                txt_url.text = new_url;
                set_current_tab_url(new_url);
            }

        }

        function set_custom_bar_color(color) {
            toolbar.color = color;
        }

        function set_default_bar_color() {
           toolbar.color = root._tab_color_active;
        }


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

                        onClicked: root.add_tab()
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
                            onClicked: root.current_tab_go_back()
                            color: root.current_text_color
                        }

                        IconButton {
                            id: btn_refresh
                            hoverAnimation: true
                            iconName : "navigation/refresh"
                            anchors.verticalCenter: parent.verticalCenter
                            color: root.current_text_color
                            onClicked: {
                                root.get_tab_by_id(root.current_tab_id).webview.reload();
                            }

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
                                    root.set_current_tab_url(txt_url.text)
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
