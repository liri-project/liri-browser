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
    property bool settingsTabPage

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    //property alias profile: webview.profile
    property alias icon: webview.icon
    property string title: newTabPage ? qsTr("New tab") : settingsTabPage ? qsTr("Settings") : webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property bool secureConnection: false

    property string usContext: "messaging://"

    property var preview


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

    function findText (text, backward, callback){
        webview.findController.text = text;
        if (backward)
            webview.findController.previous();
        else
            webview.findController.next();
        callback(webview.findController.count > 0);
    }

    WebContext {
        id: webcontext
        property string defaultUserAgent: "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        property string mobileUserAgent: "Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19 "
        userScripts: [
            UserScript {
                context: usContext
                url: Qt.resolvedUrl("ubuntu/oxide-user.js")
            }
        ]
        userAgent: mobile ? mobileUserAgent : defaultUserAgent
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

         onFullscreenRequested: {
             webview.fullscreen = fullscreen;
             if (fullscreen) {
                 root.startFullscreenMode();
             }
             else {
                 root.endFullscreenMode();
             }
         }

         onDownloadRequested: {
             Qt.openUrlExternally(request.url)
         }

         onLoadingChanged: {
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
                            root.getTabModelDataByUID(uid).customColorLight = false;
                            root.getTabModelDataByUID(uid).customTextColor = false;
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

                if(!loading && url.toString().substring(0,57) == "http://liri-browser.github.io/sourcecodeviewer/index.html") {

                    setSource(root.app.sourceHighlightTheme, root.app.sourcetemp)
                    /*runJavaScript("
                    function setSource(){
                        var head = document.head, link = document.createElement('link');
                        link.type = 'text/css';
                        link.rel = 'stylesheet';
                        link.href = 'http://softwaremaniacs.org/media/soft/highlight/styles/" + root.app.sourceHighlightTheme +".css';
                        head.appendChild(link);
                        var sc = '<!DOCTYPE html><html>' + decodeURI(\"" + root.app.sourcetemp + "\") + '</html>';
                        sc = style_html(sc, {
                          'indent_size': 2,
                          'indent_char': ' ',
                          'max_char': 48,
                          'brace_style': 'expand',
                          'unformatted': ['a', 'sub', 'sup', 'b', 'i', 'u']
                        });
                        sc = sc.replace(/</g, '&lt');
                        sc = sc.replace(/>/g, '&gt');
                        document.getElementById('source_container').innerHTML = sc;
                        hljs.highlightBlock(document.getElementById('source_container'));
                        document.getElementById('source_container').style.fontFamily = 'Hack';
                    }
                    setSource();");*/
                }

                webview.grabToImage(function(result) {
                    preview = result.image;
                });

            }

            else if (loadEvent.isError) {
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

         function setSource(theme, temp) {
             var req = webview.rootFrame.sendMessage(usContext, "SET_SOURCE", {theme: theme, temp: temp})
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


    SettingsTabPage {
        id: itemSettingsTabPage
        visible: settingsTabPage && !newTabPage
        anchors.fill: parent
    }


}
