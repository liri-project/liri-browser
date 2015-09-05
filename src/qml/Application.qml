import QtQuick 2.1
import QtWebEngine 1.1
import Qt.labs.settings 1.0

QtObject {
    id: application

    property string home_url: "https://www.google.de"

    property var bookmarks: []
    signal bookmarks_changed()

    property bool integrated_addressbars: false
    property bool tabs_entirely_colorized: false

    property bool new_tab_page: true

    property ListModel history_model: ListModel {
        id: history_model
        dynamicRoles: true
    }

    property ListModel dashboard_model: ListModel {
        id: dashboard_model
        dynamicRoles: true
    }

    property QtObject settings: Settings {
        property alias home_url: application.home_url
        property alias new_tab_page: application.new_tab_page
        property var bookmarks
        property var history
        property var dashboard
        property alias integrated_addressbars: application.integrated_addressbars
        property alias tabs_entirely_colorized: application.tabs_entirely_colorized
    }


    property QtObject default_profile: WebEngineProfile {
        storageName: "Default"
    }

    property Component browser_window_component: BrowserWindow {
        app: application
    }

    function createWindow (){
        var newWindow = browser_window_component.createObject(application)
        return newWindow
    }
    function createDialog(request) {
        var newDialog = browser_window_component.createObject(application)
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

        // Load the browser history
        var locale = Qt.locale()
        var current_date = new Date()
        var date_string = current_date.toLocaleDateString();

        var current_item_date = date_string;
        for (var i=0; i<application.settings.history.length; i++){
            var item = application.settings.history[i];
            if (current_item_date != item.date) {
                application.history_model.append({"title": item.date, "url": false, "favicon_url": false, "date": item.date, "type": "date", color: item.color})
                current_item_date = item.date
            }
            application.history_model.append(item);
        }

        // Load the dashboard model
        for (var i=0; i<application.settings.dashboard.length; i++){
            var item = application.settings.dashboard[i];
            application.dashboard_model.append(item);
        }

    }

    Component.onDestruction: {
        settings.bookmarks = application.bookmarks;

        // Save the browser history
        var history = [];
        for (var i=0; i<application.history_model.count; i++){
            var item = application.history_model.get(i);
            if (item.type !== "date")
                history.push({"title": item.title, "url": item.url, "favicon_url": item.favicon_url, "date": item.date, "type": item.type, "color": item.color});
        }
        application.settings.history = history;

        // Save the dashboard model
        var dashboard = [];
        for (var i=0; i<application.dashboard_model.count; i++){
            var item = application.dashboard_model.get(i);
            dashboard.push({"title": item.title, "url": item.url, "icon_url": item.icon_url, "bg_color": item.bg_color, "fg_color": item.fg_color, "uid": item.uid})
        }
        application.settings.dashboard = dashboard;
    }

}
