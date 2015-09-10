import QtQuick 2.1
import Qt.labs.settings 1.0

Item {
    id: application

    property string webEngine: "oxide"
    property bool enableShortCuts: false
    property bool enableNewWindowAction: false

    property string homeUrl: "https://www.google.de"

    property string sourcetemp: "test"
    property string sourceHighlightTheme: "zenburn"

    property string searchEngine: "google"

    property var bookmarks: []
    signal changedBookmarks ()

    property bool integratedAddressbars: false
    property bool tabsEntirelyColorized: false

    property bool newTabPage: true

    property ListModel historyModel: ListModel {
        id: historyModel
        dynamicRoles: true
    }

    property ListModel dashboardModel: ListModel {
        id: dashboardModel
        dynamicRoles: true
    }

    property var settings: Settings {
        property alias homeUrl: application.homeUrl
        property alias searceEngine: application.searchEngine
        property alias newTabPage: application.newTabPage
        property alias sourceHighlightTheme: application.sourceHighlightTheme
        property var bookmarks
        property var history
        property var dashboard
        property alias integratedAddressbars: application.integratedAddressbars
        property alias tabsEntirelyColorized: application.tabsEntirelyColorized
    }


    //property QtObject defaultProfile: WebEngineProfile {
    //    storageName: "Default"
    //}

    //property Component browserWindowComponent: BrowserWindow {
    //    app: application
    //}

    function createWindow (){
        var newWindow = browserWindowComponent.createObject(application)
        return newWindow
    }
    function createDialog(request) {
        var newDialog = browserWindowComponent.createObject(application)
        var tab = newDialog.addTab("about:blank")
        request.openIn(tab.webview.view)
        return newDialog
    }
    function load() {
        var browserWindow = createWindow()
    }

    Component.onCompleted: {
        console.log("Locale name: " + Qt.locale().name)
        if (!settings.bookmarks)
            settings.bookmarks = [];

        if (!settings.history)
            settings.history = [];

        application.bookmarks = settings.bookmarks;
        console.log("BOOMARKS,", bookmarks)

        // Load the browser history
        var locale = Qt.locale()
        var currentDate = new Date()
        var dateString = currentDate.toLocaleDateString();

        var currentItemDate = dateString;
        for (var i=0; i<application.settings.history.length; i++){
            var item = application.settings.history[i];
            if (currentItemDate != item.date) {
                application.historyModel.append({"title": item.date, "url": false, "faviconUrl": false, "date": item.date, "type": "date", color: item.color})
                currentItemDate = item.date
            }
            application.historyModel.append(item);
        }

        // Load the dashboard model
        for (var i=0; i<application.settings.dashboard.length; i++){
            var item = application.settings.dashboard[i];
            application.dashboardModel.append(item);
        }

    }

    Component.onDestruction: {
        settings.bookmarks = application.bookmarks;

        // Save the browser history
        var history = [];
        for (var i=0; i<application.historyModel.count; i++){
            var item = application.historyModel.get(i);
            if (item.type !== "date")
                history.push({"title": item.title, "url": item.url, "faviconUrl": item.faviconUrl, "date": item.date, "type": item.type, "color": item.color});
        }
        application.settings.history = history;

        // Save the dashboard model
        var dashboard = [];
        for (var i=0; i<application.dashboardModel.count; i++){
            var item = application.dashboardModel.get(i);
            dashboard.push({"title": item.title, "url": item.url, "iconUrl": item.iconUrl, "bgColor": item.bgColor, "fgColor": item.fgColor, "uid": item.uid})
        }
        application.settings.dashboard = dashboard;
    }

}
