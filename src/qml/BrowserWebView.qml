import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtWebEngine 1.2
import Clipboard 1.0


BaseBrowserView {
    id: browserWebView
    anchors.fill: parent

    property var uid
    property alias view: webview

    // TODO: Handle this locally
    property bool sourceTapPage: url == "http://liri-browser.github.io/sourcecodeviewer/index.html"

    /* Wrapping WebEngineView functionality */
    property alias page: webview.page
    property alias url: webview.url
    property alias profile: webview.profile
    property alias icon: webview.icon
    property string title: webview.title
    property alias loading: webview.loading
    property alias canGoBack: webview.canGoBack
    property alias canGoForward: webview.canGoForward
    property bool secureConnection: false
    property real loadProgress: webview.loadProgress/100
    property alias zoomFactor: webview.zoomFactor

    reloadable: true

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
            root.app.saveHistory();
        }

        onUrlChanged: {
            if (url.toString().lastIndexOf("https://", 0) === 0)
                browserWebView.secureConnection = true;
            else
                browserWebView.secureConnection = false;
            if (root.activeTab.webview == browserWebView)
                activeTabUrlChanged();
            if(isMedia("" + url + "")) {

                setActiveTabURL(url)
            }
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
                 request.openIn(tab.view.item.view);
             } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
                 var tab = root.addTab("about:blank", true);
                 request.openIn(tab.view.item.view);
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
                root.app.searchSuggestionsModel.clear()
            }
            else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                // Looking for custom tab bar colors
                runJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                    function(content){
                        if(content !== "") {
                            browserWebView.customColor = content;
                            browserWebView.customColorLight = root.shadeColor(content, 0.6);
                            browserWebView.customTextColor = root.getTextColorForBackground(content);

                            if(!root.privateNav && !root.app.darkTheme && root.app.tabsEntirelyColorized && view.visible) {
                                root.initialPage.ink.color = content
                                root.initialPage.ink.createTapCircle(root.width/2, root.height/1.5)
                                root.initialPage.inkTimer.restart()
                            }
                        }
                        else{
                            var customColor = root.app.customSitesColors ? searchForCustomColor(url.toString()) : "none";
                            if(customColor != "none") {
                                browserWebView.customColor = customColor;
                                browserWebView.customColorLight = root.shadeColor(customColor, 0.6);
                                browserWebView.customTextColor = root.getTextColorForBackground(customColor);
                                if(!root.privateNav && root.app.tabsEntirelyColorized && view.visible) {
                                    root.initialPage.ink.color = customColor
                                    root.initialPage.ink.createTapCircle(root.width/2, root.height/1.5)
                                    root.initialPage.inkTimer.restart()
                                }
                            }
                            else {
                                browserWebView.customColor = false;
                                browserWebView.customColorLight = false;
                                browserWebView.customTextColor = false;
                            }
                        }
                });

                // Add history entry
                if (!root.privateNav && title && url.toString() != root.app.homeUrl) {
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
                    root.app.saveHistory();
                }

                // TODO: Handle this locally
                if(!loading && url.toString().indexOf("http://liriproject.me/browser/sourcecodeviewer/index.html") === 0) {
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
                          var source_container = document.getElementById('source_container')
                          source_container.style.fontFamily = '" + root.app.sourceHighlightFont + "';
                          source_container.style.fontSize = '" + root.app.sourceHighlightFontPixelSize + "px';
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
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton
        preventStealing: true
        propagateComposedEvents: true
        property string hoverUrl
        property string tempUrl
        property bool needLinkDropdown: false

        function checkMenu(hUrl){
            hoverUrl = hUrl
        }

        onWheel: {
            if (wheel.modifiers & Qt.ControlModifier) {
                if (wheel.angleDelta.y > 0)
                    root.activeTab.view.zoomIn();
                else
                    root.activeTab.view.zoomOut();
            }
            else
                wheel.accepted = false
        }

        onPressed: {
            var putX = mouseX
            var putY = mouseY
            if(mouseY + webRightClickMenu.height > clickDetector.height)
                putY -= webRightClickMenu.height
            if(mouseX + webRightClickMenu.width > clickDetector.width)
                putX -= webRightClickMenu.width
            if(hoverUrl == "") {
                webRightClickMenu.open(clickDetector, -clickDetector.width + putX + webRightClickMenu.width, putY)
                return
            }
            else{
                tempUrl = hoverUrl
                linkRightClickMenu.open(clickDetector, -clickDetector.width + putX + webRightClickMenu.width, putY)
            }
        }

        onReleased:
            hoverUrl = ""
    }

    Clipboard {
        id: clip
    }

    function getPageTitle(url, callback){
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === 4) {
                var json = JSON.parse(doc.responseText);
                if ("error" in json) {
                    console.log("An error occurred parsing the website")
                    callback(url)
                }
                else {
                    if(json[1] === undefined)
                        callback(url)
                    else
                        callback(json[1])
                }
            }
        }
        doc.open("get", "http://decenturl.com/api-title?u=" + url);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }

    Dropdown {
        id: webRightClickMenu
        width: Units.dp(250)
        height: column.height + Units.dp(16)
        ColumnLayout{
            id: column
            width: parent.width
            anchors.centerIn: parent

            ListItem.Standard {
                text: qsTr("Reload")
                iconName: "navigation/refresh"
                onClicked: {
                    webview.reload()
                    webRightClickMenu.close()
                }
            }

            ListItem.Standard {
                text: qsTr("Add to bookmarks")
                iconName: "action/bookmark_border"
                onClicked: {
                    getPageTitle(clickDetector.tempUrl, function(titl){
                        getBetterIcon(clickDetector.tempUrl, titl, activeTab.customColor, function(url, title, color, iconUrl){
                            addBookmark(title, url, iconUrl, color)
                            clickDetector.tempUrl = ""
                            webRightClickMenu.close()
                        })
                    })
                }
            }

            ListItem.Standard {
                text: qsTr("Add to dash")
                iconName: "action/dashboard"
                onClicked: {
                    getPageTitle(clickDetector.tempUrl, function(titl){
                        addToDash(clickDetector.tempUrl, titl, activeTab.customColor)
                        clickDetector.tempUrl = ""
                        webRightClickMenu.close()
                    })
                }
            }

            ListItem.Standard {
                text: qsTr("View source")
                iconName: "action/code"
                onClicked: {
                    activeTabViewSourceCode();
                    webRightClickMenu.close()
                }
            }

            // TODO: Figure out how to save a URL locally AND change cursor on link (idk why it doesn't work '--)

            /*ListItem.Standard {
                text: qsTr("Save as...")
                iconName: "file/file_download"
            }*/
        }

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



            ListItem.Standard {
                text: qsTr("Play in browser")
                iconName: "av/play_arrow"
                visible: isMedia(clickDetector.tempUrl)
                onClicked: {
                    addTab(encodeURI(clickDetector.tempUrl))
                    linkRightClickMenu.close()
                }
            }

            ListItem.Standard {
                text: qsTr("Copy URL")
                iconName: "content/content_copy"
                onClicked: {
                    clip.copyText(clickDetector.tempUrl)
                    clickDetector.tempUrl = ""
                    linkRightClickMenu.close()
                }
            }

            ListItem.Standard {
                text: qsTr("Add to bookmarks")
                iconName: "action/bookmark_border"
                onClicked: {
                    getPageTitle(clickDetector.tempUrl, function(titl){
                        getBetterIcon(clickDetector.tempUrl, titl, activeTab.customColor, function(url, title, color, iconUrl){
                            addBookmark(title, url, iconUrl, color)
                            clickDetector.tempUrl = ""
                            linkRightClickMenu.close()
                        })
                    })
                }
            }

            ListItem.Standard {
                text: qsTr("Add to dash")
                iconName: "action/dashboard"
                onClicked: {
                    getPageTitle(clickDetector.tempUrl, function(titl){
                        addToDash(clickDetector.tempUrl, titl, activeTab.customColor)
                        clickDetector.tempUrl = ""
                        linkRightClickMenu.close()
                    })
                }
            }

            // TODO: Figure out how to save a URL locally AND change cursor on link (idk why it doesn't work '--)

            /*ListItem.Standard {
                text: qsTr("Save as...")
                iconName: "file/file_download"
            }*/
        }

    }


}
