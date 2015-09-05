import QtQuick 2.4
import Material 0.1
import QtWebEngine 1.1
//import QtWebEngine.experimental 1.1



Item {
    id: browser_web_view
    anchors.fill: parent

    visible: false

    property var uid
    property alias view: webview
    property bool new_tab_page

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    property alias profile: webview.profile
    property alias icon: webview.icon
    property string title: new_tab_page ? qsTr("New tab") : webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property bool secureConnection: false

    function goBack() {
        webview.goBack();
    }

    function goForward() {
        webview.goForward();
    }

    function runJavaScript(arg1, arg2) {
        webview.runJavaScript(arg1, arg2);
    }

    function reload() {
        webview.reload();
    }

    function findText (text, flags, callback){
        webview.findText(text, flags, callback);
    }

    WebEngineView {
        id: webview
        property var page
        anchors.fill: parent
        visible: !new_tab_page

        onIconChanged: {
            // Set the favicon in history
            var history_model = root.app.history_model;
            for (var i=0; i<history_model.count; i++) {
                var item = history_model.get(i);
                if (item.url == webview.url){
                    item.favicon_url = webview.icon
                    history_model.set(i, item);
                    break;
                }
                console.log(i)
            }
        }

        onUrlChanged: {
            if (url.toString().lastIndexOf("https://", 0) === 0)
                browser_web_view.secureConnection = true;
            else
                browser_web_view.secureConnection = false;
            if (root.activeTab.webview == browser_web_view)
                activeTabUrlChanged();
        }

        /*settings.autoLoadImages: appSettings.autoLoadImages
                     settings.javascriptEnabled: appSettings.javaScriptEnabled
                     settings.errorPageEnabled: appSettings.errorPageEnabled*/

         onCertificateError: {
             dlg_certificate_error.show_error(error);
         }

         onNewViewRequested: {
             console.log("onNewViewRequested")
             if (!request.userInitiated)
                 console.log("Warning: Blocked a popup window.")
             else if (request.destination === WebEngineView.NewViewInTab) {
                 var tab = root.addTab("about:blank");
                 request.openIn(tab.webview.view);
             } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                 var tab = root.addTab("about:blank", true);
                 request.openIn(tab.webview.view);
             } else if (request.destination === WebEngineView.NewViewInDialog) {
                 var dialog = root.app.createDialog(request);
             } else {
                 // New window
                 var dialog = root.app.createDialog(request);
             }
         }

         onFullScreenRequested: {
             console.log("onFullScreenRequested")
             if (request.toggleOn) {
                 root.start_fullscreen_mode();
             }
             else {
                 root.end_fullscreen_mode();
             }
             request.accept();
         }

         onLoadingChanged: {
            if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                // pass
            }

            else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                // Looking for custom tab bar colors
                runJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                    function(content){
                        if(content !== "") {
                            root.getTabModelDataByUID(uid).customColor = content;
                            root.getTabModelDataByUID(uid).customColorLight = root.get_tab_manager().shade_color(content, 0.6);
                            root.getTabModelDataByUID(uid).customTextColor = root.get_tab_manager().get_text_color_for_background(content);

                            //customColor
                            // TBD

                            //tab.custom_color = content;
                            //tab.custom_color_inactive = shade_color(content, 0.6);
                            //tab.update_colors();
                        }
                        else{
                            root.getTabModelDataByUID(uid).customColor = false;
                            // tab.custom_color_inactive = false;
                            // tab.update_colors();
                        }
                });

                // Add history entry
                if (title && url.toString() != root.app.home_url) {
                    var locale = Qt.locale()
                    var current_date = new Date()
                    var date_string = current_date.toLocaleDateString();

                    var item = {
                        "url": url.toString(),
                        "title": title,
                        "favicon_url": icon.toString(),
                        "date": date_string,
                        "type": "entry"
                    }

                    root.app.history_model.insert(0, item);
                }

            }

            else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                root.setActiveTabURL('about:blank');
            }


             /*

               DEPRECATED FUNCTION (AS REFERENCE):


                this.loading_changed = function(tab, request) {
                    if (request.status === 0){
                        // LoadStartedStatus
                        if (tab === current_tab_page) {
                            prg_loading.visible = true;
                            btn_refresh.visible = false;
                        }

                    }
                    else if (request.status === 2) {
                        // LoadFinishedStatus
                        if (tab === current_tab_page) {
                            prg_loading.visible = false;
                            btn_refresh.visible = true;
                        }
                        if (tab.url !== tab.webview.url)
                            tab.url = tab.webview.url;
                            tab.title = tab.webview.title;
                            tab.tab.title = tab.title;

                            //if (tab.tab.state == "active_edit")
                            //   tab.tab.state = "active";

                            if (tab === current_tab_page) {
                                txt_url.text = tab.webview.url;
                                tab.tab.txt_url.text = tab.webview.url;
                                root.title = tab.webview.title + ' - Browser';
                            }
                            // Looking for custom tab bar colors
                            tab.webview.runJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                                function(content){
                                    if(content !== "") {
                                        tab.custom_color = content;
                                        tab.custom_color_inactive = shade_color(content, 0.6);
                                        tab.update_colors();
                                    }
                                    else{
                                        tab.custom_color = false;
                                        tab.custom_color_inactive = false;
                                        tab.update_colors();
                                    }
                            });

                            // Check for secure connection
                            if (tab.url.toString().lastIndexOf("https://", 0) === 0)
                                root.secure_connection = true;
                            else
                                root.secure_connection = false;

                            // Add history entry
                            if (tab.webview.title && tab.url.toString() != root.app.home_url) {
                                var locale = Qt.locale()
                                var current_date = new Date()
                                var date_string = current_date.toLocaleDateString();

                                var item = {
                                    "url": tab.url.toString(),
                                    "title": tab.webview.title,
                                    "favicon_url": tab.webview.icon.toString(),
                                    "date": date_string,
                                    "type": "entry"
                                }

                                root.app.history_model.insert(0, item);
                            }

                    }
                    else if (request.status === 3) {
                        // LoadFailedStatus
                        var new_url = "about:blank";
                        if (root.app.integrated_addressbars) {
                            tab.tab.txt_url.text = new_url;
                            tab.set_url(new_url);
                        }
                        else {
                            txt_url.text = new_url;
                            tab.set_url(new_url);
                        }
                    }

                    tab.update_toolbar();

                }






            */
         }
    }

    NewTabPage {
        id: item_new_tab_page
        visible: new_tab_page
        anchors.fill: parent
    }

}
