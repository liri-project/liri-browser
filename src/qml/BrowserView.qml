import QtQuick 2.0
import Material 0.1

Item {
    id: browserView

    anchors.fill: parent

    property string viewType: "unknown"
    property string viewName: "unknown"

    property bool isWebView: viewType === "built-in" && viewName === "webview"
    property bool isDash: viewType === "built-in" && viewName === "dash"
    property bool isSettings: viewType === "built-in" && viewName === "settings"
    property bool isQuickSearchesSettings: viewType === "built-in" && viewName === "quick-searches-settings"
    property bool isSitesColorsSettings: viewType === "built-in" && viewName === "sites-colors-settings"


    /* View Properties */

    property var icon: loader.ready ? loader.item.icon : null
    property string title: loader.ready ? loader.item.title : "Loading ... "
    property var url: loader.ready ? loader.item.url : null
    property var profile
    property bool loading: loader.ready ? loader.item.loading : true
    property real loadProgress: loader.ready ? loader.item.loadProgress : loader.progress
    property bool reloadable: loader.ready ? loader.item.reloadable : false

    property bool canGoBack: loader.ready ? loader.item.canGoBack : false
    property bool canGoForward: loader.ready ? loader.item.canGoForward : false
    property bool secureConnection: loader.ready ? loader.item.secureConnection : false

    property var customColor: loader.ready ? loader.item.customColor : false
    property var customColorLight: loader.ready ? loader.item.customColorLight : false
    property var customTextColor: loader.ready ? loader.item.customTextColor : false
    property bool hasCloseButton: true

    /* Loading */

    function load (url) {
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
            url = getValidUrl(url);
            loadWebView(url);
        }

    }

    function loadWebView (url) {
        if (loader.ready && isWebView) {
            loader.item.url = url;
        }
        else {
            loader.sourceComponent = root.webviewComponent;
            if (loader.ready) {
                loader.item.url = url;
                loader.item.profile = root.app.defaultProfile;
                viewType = "built-in";
                viewName = "webview";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadNewTabPage (url) {
        if (!(loader.ready && isDash)) {
            loader.sourceComponent = root.newTabPageComponent;
            if (loader.ready) {
                viewType = "built-in";
                viewName = "dash";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadSettings () {
        if (!(loader.ready && isSettings)) {
            loader.sourceComponent = root.settingsViewComponent;
            if (loader.ready) {
                viewType = "built-in";
                viewName = "settings";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadQuickSearchesSettings () {
        if (!(loader.ready && isQuickSearchesSettings)) {
            loader.sourceComponent = root.quickSearchesSettingsViewComponent;
            if (loader.ready) {
                viewType = "built-in";
                viewName = "quick-searches-settings";
            }
            else {
                console.log("Warning, loader is not ready!");
            }
        }
    }

    function loadSitesColorsSettings () {
        if (!(loader.ready && isSitesColorsSettings)) {
            loader.sourceComponent = root.sitesColorsSettingsViewComponent;
            if (loader.ready) {
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
            loader.item.goBack();
    }

    function goForward() {
        if (isWebView)
            loader.item.goForward();
    }

    function runJavaScript(arg1, arg2) {
        if (isWebView)
            loader.item.runJavaScript(arg1, arg2);
    }

    function reload() {
        if (isWebView)
            loader.item.reload();
    }

    function stop() {
        if (isWebView)
            loader.item.stop();
    }

    function findText (text, backward, callback){
        if (isWebView)
            loader.item.findText(text, backward, callback);
    }


    Loader {
        id: loader
        anchors.fill: parent

        property bool ready: status === Loader.Ready

        onStatusChanged: {
            switch (loader.status) {
                case Loader.Ready:
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

