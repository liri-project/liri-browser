import QtQuick 2.4
import Material 0.1
import QtWebEngine 1.1
//import QtWebEngine.experimental 1.1



Item {
    id: browser_web_view
    anchors.fill: parent

    visible: false

    property alias view: webview
    property bool new_tab_page

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    property alias profile: webview.profile
    property alias icon: webview.icon
    property alias title: webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward

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
            if (page.tab.state !== "inactive")
                root.current_tab_icon.source = icon;

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
                 var tab = root.add_tab("about:blank");
                 request.openIn(tab.webview);
             } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                 var tab = root.add_tab("about:blank", true);
                 request.openIn(tab.webview);
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
    }

    NewTabPage {
        id: item_new_tab_page
        visible: new_tab_page
        anchors.fill: parent
    }

}
