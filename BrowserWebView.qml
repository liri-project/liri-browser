import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import Material 0.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0

Controls.ScrollView {
    anchors.fill: parent

    property var view: webview

    property alias title: webview.title
    property alias url: webview.url
    property alias experimental: webview.experimental
    property alias icon: webview.icon

    WebView {
        id: webview
        property var page

        anchors.fill: parent
    }
}
