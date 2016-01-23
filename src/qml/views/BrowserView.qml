import QtQuick 2.0
import Material 0.2
import "dashboard"
import "../model"

Item {
    id: browserView

    anchors.fill: parent

    property Tab tab

    visible: tab == activeTab

    function load(url) {
        if (url == "liri://dash") {
            type = "dash"
            loader.sourceComponent = dashboardViewComponent
        } else if (url == "liri://settings") {
            type = "settings"
        } else if (url !== undefined && url !== null && String(url).length > 0) {
            type = "webview"
            loader.sourceComponent = webviewComponent
        } else {
            type = "blank"
            loader.sourceComponent = null;
        }

        console.log(url, item)

        item.url = url
    }

    property string type

    readonly property bool isWebView: type == "webview"

    /* View Properties */

    readonly property var icon: browserView.ready ? browserView.item.icon : null
    readonly property string title: browserView.ready ? browserView.item.title : "Loading ... "
    readonly property var url: browserView.ready ? browserView.item.url : null
    property var profile
    readonly property bool loading: browserView.ready ? browserView.item.loading : true
    readonly property real loadProgress: browserView.ready ? browserView.item.loadProgress : loader.progress
    readonly property bool reloadable: browserView.ready ? browserView.item.reloadable : false

    readonly property bool canGoBack: browserView.ready ? browserView.item.canGoBack : false
    readonly property bool canGoForward: browserView.ready ? browserView.item.canGoForward : false
    readonly property bool secureConnection: browserView.ready ? browserView.item.secureConnection : false

    readonly property var customColor: browserView.ready ? browserView.item.customColor : false
    readonly property var customColorLight: browserView.ready ? browserView.item.customColorLight : false
    readonly property var customTextColor: browserView.ready ? browserView.item.customTextColor : false
    property bool hasCloseButton: true

    readonly property var item: loader.item

    readonly property var ready: loader.status == Loader.Ready

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
