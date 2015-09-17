import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtWebEngine 1.1


Item {
    id: browserWebView
    anchors.fill: parent

    visible: false

    property var uid
    property alias view: webview
    property bool newTabPage
    property bool settingsTabPage
    property bool sourceTapPage: url == "http://liri-browser.github.io/sourcecodeviewer/index.html"

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    property alias profile: webview.profile
    property alias icon: webview.icon
    property string title: newTabPage ? qsTr("New tab") : settingsTabPage ? qsTr("Settings") : webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property bool secureConnection: false
    property real progress: webview.loadProgress/100

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

    function stop() {
        webview.stop();
    }

    function findText (text, backward, callback){
        var flags;
        if (backward)
            flags |= WebEngineView.FindBackward
        webview.findText(text, flags, callback);

    }

    WebEngineView {
        id: webview
        property var page
        anchors.fill: parent
        visible: !newTabPage && !settingsTabPage

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

         onFullScreenRequested: {
             console.log("onFullScreenRequested")
             if (request.toggleOn) {
                 root.startFullscreenMode();
             }
             else {
                 root.endFullscreenMode();
             }
             request.accept();
         }

         onLoadingChanged: {
            if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                if (newTabPage) {
                    newTabPage = false;
                }
            }
            else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
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

                if(!loading && url.toString().substring(0,57)=="http://liri-browser.github.io/sourcecodeviewer/index.html") {
                    runJavaScript("
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
                      setSource();");
                }
            }

            else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                root.setActiveTabURL('about:blank');
            }
         }

         onLinkHovered: {
             clickDetector.checkMenu(hoveredUrl)
         }
    }

    MouseArea {
        id: clickDetector
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        preventStealing: true
        propagateComposedEvents: true
        property string hoverUrl
        property string tempUrl

        function checkMenu(hUrl){
            hoverUrl = hUrl
        }

        onPressed: {
            if(hoverUrl == "")
                return
            else{
                tempUrl = hoverUrl
                linkRightClickMenu.open(clickDetector, -clickDetector.width + mouseX + linkRightClickMenu.width, mouseY)
            }
        }

        onReleased:
            hoverUrl = ""
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

    function getPageTitle(url, callback){
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                //console.log(doc.responseText);
                var json = JSON.parse(doc.responseText);
                if ("error" in json) {
                    console.log("An error occurred parsing the website")
                    callback(url)
                }
                else {
                    callback(json["title"][0])
                }
            }
        }
        doc.open("get", url);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }

    Dropdown {
        id: linkRightClickMenu
        width: Units.dp(250)
        height: columnView.height + Units.dp(16)

        ColumnLayout{
            id: columnView
            width: parent.width
            anchors.centerIn: parent

            ListItem.Standard {
                text: qsTr("Open in new tab")
                iconName: "action/open_in_new"
                onClicked: {
                    root.addTab(clickDetector.tempUrl)
                    clickDetector.tempUrl = ""
                    linkRightClickMenu.close()
                }
            }

            ListItem.Standard {
                text: qsTr("Open in new window")
                iconName: "action/open_in_new"
                onClicked: {
                    app.createWindow().setActiveTabURL(clickDetector.tempUrl)
                    clickDetector.tempUrl = ""
                    linkRightClickMenu.close()
                }
            }
        }

    }

    // Non-material design menus, will re-implement the rest of the features as a Dropdown once I figure out how to extract
    // the title of a webpage without loading it (through URL alone)

    /*MenuItem{
        id: newTab
        text: qsTr("Open in new tab")
        onTriggered: {
            root.addTab(clickDetector.hoverUrl)
        }
    }

    MenuItem{
        id: newWindow
        text: qsTr("Open in new window")
        onTriggered: {
            app.createWindow().setActiveTabURL(clickDetector.hoverUrl)
        }
    }

    MenuSeparator{}

    MenuItem{
        id: copyLink
        text: qsTr("Copy link")
    }

    MenuSeparator{}

    MenuItem{
        id: addToBookmarks
        text: qsTr("Add link to bookmarks")
        onTriggered: {
            var tmp = webview.url
            webview.url = clickDetector.hoverUrl
            root.getBetterIcon(webview.url, webview.title, activeTab.customColor, function(url, title, color, iconUrl){
                root.addBookmark(title, url, iconUrl, color)
            })
            webview.url = tmp
        }
    }

    MenuItem{
        id: addToDash
        text: qsTr("Add link to dash")
        onTriggered: {
            getPageTitle(clickDetector.hoverUrl, function(titl){
              console.log(titl)
            })

            //var tmp = webview.url
            //webview.url = clickDetector.hoverUrl
            //root.addToDash(webview.url, webview.title, activeTab.customColor)
            //webview.url = tmp
        }
    }*/
}
