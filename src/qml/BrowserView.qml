import QtQuick 2.0
import Material 0.1

Item {
    id: browserView

    anchors.fill: parent

    visible: false

    property string viewType: "unknown"
    property string viewName: "unknown"

    property bool isWebView: viewType === "built-in" && viewName === "webview"
    property bool isDash: viewType === "built-in" && viewName === "dash"
    property bool isSettings: viewType === "built-in" && viewName === "settings"
    property bool isQuickSearchesSettings: viewType === "built-in" && viewName === "quick-searches-settings"
    property bool isSitesColorsSettings: viewType === "built-in" && viewName === "sites-colors-settings"


    /* View Properties */

    property var icon: browserView.ready ? browserView.item.icon : null
    property string title: browserView.ready ? browserView.item.title : "Loading ... "
    property var url: browserView.ready ? browserView.item.url : null
    property var profile
    property bool loading: browserView.ready ? browserView.item.loading : true
    property real loadProgress: browserView.ready ? browserView.item.loadProgress : loader.progress
    property bool reloadable: browserView.ready ? browserView.item.reloadable : false

    property bool canGoBack: browserView.ready ? browserView.item.canGoBack : false
    property bool canGoForward: browserView.ready ? browserView.item.canGoForward : false
    property bool secureConnection: browserView.ready ? browserView.item.secureConnection : false

    property var customColor: browserView.ready ? browserView.item.customColor : false
    property var customColorLight: browserView.ready ? browserView.item.customColorLight : false
    property var customTextColor: browserView.ready ? browserView.item.customTextColor : false
    property bool hasCloseButton: true

    property var item: loader.item

    property var ready: true

    /* Loading */

    function load (url, webview) {
        // Dirty workaround because Oxide webviews may be created directly without the use of a loader (see loadWebview)
        browserView.item = Qt.binding(function(){return loader.item});
        browserView.ready = Qt.binding(function(){return loader.ready});

        // Ensure url is valid
        if (typeof(url) === "undefined") {
            if (root.app.newTabPage)
                url = "liri://dash";
            else
                url = app.homeUrl;
        }
        if (url.toString().lastIndexOf("liri://", 0) === 0) {
            // Built-in Liri specific URL handling
            if (url.toString().lastIndexOf("liri://dash", 0) === 0) {
                loadNewTabPage (url);
            }
            else if (url.toString().lastIndexOf("liri://settings", 0) === 0) {

                if (url.toString().lastIndexOf("liri://settings/quick-searches", 0) === 0) {
                    loadQuickSearchesSettings(url);
                }
                else if (url.toString().lastIndexOf("liri://settings/sites-colors", 0) === 0) {
                    loadSitesColorsSettings(url);
                }
                else {
                    loadSettings (url);
                }
            }
        }
        // TODO: Handle plugins
        else {
            // Default WebView
            if(url.indexOf("file://") >= 0){
                url = url;
            }else{
                url = getValidUrl(url);
            }


            loadWebView(url, webview);
        }

    }

    function loadWebView (url, webview) {
        if (browserView.ready && isWebView) {
            browserView.item.url = url;
        }
        else {
            if (root.app.webEngine === "qtwebengine" || !webview)
                loader.sourceComponent = root.webviewComponent;
            else {
                // Dirty workaround: Directly override the loader's data.
                // The problem with this is that Oxide webview sometimes *must* be created within onNewViewRequested.
                loader.data = webview;
                browserView.item = webview;
                browserView.ready = true;
            }
            if (browserView.ready) {
                if (!webview)
                    browserView.item.url = url;
                if (root.app.webEngine === "qtwebengine")
                    browserView.item.profile = root.app.defaultProfile;
                viewType = "built-in";
                viewName = "webview";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadNewTabPage (url) {
        if (!(browserView.ready && isDash)) {
            loader.sourceComponent = root.newTabPageComponent;
            if (browserView.ready) {
                viewType = "built-in";
                viewName = "dash";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadSettings () {
        if (!(browserView.ready && isSettings)) {
            loader.sourceComponent = root.settingsViewComponent;
            if (browserView.ready) {
                viewType = "built-in";
                viewName = "settings";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadQuickSearchesSettings () {
        if (!(browserView.ready && isQuickSearchesSettings)) {
            loader.sourceComponent = root.quickSearchesSettingsViewComponent;
            if (browserView.ready) {
                viewType = "built-in";
                viewName = "quick-searches-settings";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadSitesColorsSettings () {
        if (!(browserView.ready && isSitesColorsSettings)) {
            loader.sourceComponent = root.sitesColorsSettingsViewComponent;
            if (browserView.ready) {
                viewType = "built-in";
                viewName = "sites-colors-settings";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }


    function loadPluginView () {

    }

    /* WebView functionality */

    function goBack() {
        if (isWebView)
            browserView.item.goBack();
    }

    function goForward() {
        if (isWebView)
            browserView.item.goForward();
    }

    function runJavaScript(arg1, arg2) {
        if (isWebView)
            browserView.item.runJavaScript(arg1, arg2);
    }

    function reload() {
        if (isWebView)
            browserView.item.reload();
    }

    function zoomIn() {
        if (isWebView)
            browserView.item.zoomFactor += 0.25;
    }

    function zoomOut() {
        if (isWebView)
            browserView.item.zoomFactor -= 0.25
    }

    function zoomReset() {
        if (isWebView)
            browserView.item.zoomFactor = 1.0
    }

    function stop() {
        if (isWebView)
            browserView.item.stop();
    }

    function findText (text, backward, callback){
        if (isWebView)
            browserView.item.findText(text, backward, callback);
    }


    Loader {
        id: loader
        anchors.fill: parent

        property bool ready: status === Loader.Ready

        onStatusChanged: {
            switch (loader.status) {
                case loader.ready:
                    console.log("Loaded");
                    break;
                case Loader.Loading:
                    break;
                case Loader.Error:
                    console.log("Error");
                    break;
            }
        }
    }
}

