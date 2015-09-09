import QtQuick 2.4
import Material 0.1
import com.canonical.Oxide 1.0

Item {
    id: browserWebView
    anchors.fill: parent

    visible: false

    property var uid
    property alias webview: webview
    property bool newTabPage

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    //property alias profile: webview.profile
    property alias icon: webview.icon
    property string title: newTabPage ? qsTr("New tab") : webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property bool secureConnection: false

    property string usContext: "messaging://"


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

    WebContext {
        id: webcontext
        userScripts: [
            UserScript {
                context: usContext
                url: Qt.resolvedUrl("ubuntu/oxide-user.js")
            }
        ]
    }

    WebView {
        id: webview
        property var page
        anchors.fill: parent
        visible: !newTabPage

        context: webcontext

        onIconChanged: {
            // Set the favicon in history
            var historyModel = root.app.historyModel;
            for (var i=0; i<historyModel.count; i++) {
                var item = historyModel.get(i);
                if (item.url == webview.url){
                    item.faviconUrl = webview.icon
                    historyModel.set(i, item);
                    break;
                }
            }
        }

        onUrlChanged: {
            if (url.toString().lastIndexOf("https://", 0) === 0)
                browserWebView.secureConnection = true;
            else
                browserWebView.secureConnection = false;
            if (root.activeTab.webview == browserWebView)
                activeTabUrlChanged();
        }

        /*settings.autoLoadImages: appSettings.autoLoadImages
                     settings.javascriptEnabled: appSettings.javaScriptEnabled
                     settings.errorPageEnabled: appSettings.errorPageEnabled*/

         onCertificateError: {
             dlgCertificateError.showError(error);
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

         /*onFullScreenRequested: {
             console.log("onFullScreenRequested")
             if (request.toggleOn) {
                 root.startFullscreenMode();
             }
             else {
                 root.endFullscreenMode();
             }
             request.accept();
         }*/

         onLoadingChanged: {
             console.log(JSON.stringify(loadEvent))
            if (loadEvent.type === 0) {
                if (newTabPage) {
                    newTabPage = false;
                }
            }

            else if (loadEvent.type === 2) {
                // Looking for custom tab bar colors
                runJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                    function(content){
                        if(content !== "") {
                            root.getTabModelDataByUID(uid).customColor = content;
                            root.getTabModelDataByUID(uid).customColorLight = root.shadeColor(content, 0.6);
                            root.getTabModelDataByUID(uid).customTextColor = root.getTextColorForBackground(content);
                        }
                        else{
                            root.getTabModelDataByUID(uid).customColor = false;
                        }
                });

                // Add history entry
                if (title && url.toString() != root.app.homeUrl) {
                    var locale = Qt.locale()
                    var currentDate = new Date()
                    var dateString = currentDate.toLocaleDateString();

                    var item = {
                        "url": url.toString(),
                        "title": title,
                        "faviconUrl": icon.toString(),
                        "date": dateString,
                        "type": "entry"
                    }

                    root.app.historyModel.insert(0, item);
                }

            }

            else if (loadRequest.isError) {
                root.setActiveTabURL('about:blank');
            }
         }

         function getHTML(callback) {
             var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {})
             req.onreply = function (msg) {
                 callback(msg.html);
             }
             req.onerror = function (code, explanation) {
                 console.log("Error " + code + ": " + explanation)
             }
         }

         function runJavaScript(js, callback) {
             var req = webview.rootFrame.sendMessage(usContext, "RUN_JAVASCRIPT", {script: js})
             req.onreply = function (msg) {
                 callback(msg.result);
             }
             req.onerror = function (code, explanation) {
                 console.log("Error " + code + ": " + explanation)
             }
         }
    }


    NewTabPage {
        id: itemNewTabPage
        visible: newTabPage
        anchors.fill: parent
    }

}
