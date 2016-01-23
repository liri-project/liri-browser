import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import "model"

ApplicationWindow {
    id: window

    property var app

    property alias activeTab: tabsModel.activeTab

    property bool privateBrowsing: false
    property bool showBookmarksBar: activeTab.url == "liri://dash"
    property bool supportsDownloads: true
    property bool isMobile: false
    property bool isFullscreen: false
    property bool integratedAddressbars: false
    property bool usingCustomFrame: false
    property string defaultTabUrl: "liri://dash"

    property Component webviewComponent

    title: activeTab ? (activeTab.view.title || qsTr("Loading")) + " - " + Qt.application.name
                     : Qt.application.name
    visible: true

    initialPage: BrowserPage { id: browserPage }

    Component.onCompleted: {
        // WebView Component
        if (app.webEngine === "qtwebengine")
            webviewComponent = Qt.createComponent("BrowserWebView.qml");
        else if (app.webEngine === "oxide")
            webviewComponent = Qt.createComponent("BrowserOxideWebView.qml");

        console.log(webviewComponent.status == Component.Error)
        console.log(webviewComponent.errorString())

        tabsModel.addTab()
    }

    Component {
        id: browserViewComponent

        BrowserView {}
    }

    Component {
        id: newTabPageComponent

        NewTabPage {}
    }

    Snackbar {
        id: snackbar
    }

    Snackbar {
        id: snackbarTabClose
        property string url: ""
        buttonText: qsTr("Reopen")
        onClicked: {
            root.addTab(url);
        }
    }

    TabsModel {
        id: tabsModel
    }

    SearchSuggestionsModel {
        id: searchSuggestionsModel
    }

    ListModel {
        id: bookmarksModel
    }

    QtObject {
        id: styles

        property int tabHeight: Units.dp(40)
        property int tabWidth: !reduceTabsSizes ? Units.dp(200) : Units.dp(50)
        property int tabWidthEdit: Units.dp(400)
        property int tabsSpacing: Units.dp(1)
        property int titlebarHeight: Units.dp(148)
        property bool uppercaseTabTitle: false
        property bool reduceTabsSizes: false
    }
}
