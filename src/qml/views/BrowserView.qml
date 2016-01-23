import QtQuick 2.0
import Material 0.2
import "dashboard"

Item {
    id: browserView

    anchors.fill: parent

    property Tab tab

    // visible: tab == activeTab

    readonly property string type: {
        var url = String(tab.url)
        console.log(tab, url)
        if (url == "liri://dash") {
            return "dash"
        } else if (url == "liri://settings") {
            return "settings"
        } else if (url !== undefined && url !== null && String(url).length > 0) {
            return "webview"
        } else {
            return "blank"
        }
    }

    readonly property bool isWebView: type == "webview"

    onTypeChanged: {
        var url = String(tab.url)
        console.log(url, type)
        if (type == "dash") {
            loader.sourceComponent = dashboardViewComponent;
        } else if (type == "settings") {

        } else if (type == "webview") {
            loader.sourceComponent = webviewComponent;
        } else {
            loader.sourceComponent = null;
        }
    }

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

    property var ready: loader.status == Loader.Ready

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

    function findText (text, backward, callback) {
        if (isWebView)
            browserView.item.findText(text, backward, callback);
    }

    Connections {
        target: tab

        onUrlChanged: browserView.url = url
    }

    Loader {
        id: loader
        anchors.fill: parent

        property alias tab: browserView.tab

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

    Component {
        id: dashboardViewComponent

        DashboardView {}
    }
}
