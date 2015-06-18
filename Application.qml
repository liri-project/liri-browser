import QtQuick 2.1
import QtWebEngine 1.1
import Qt.labs.settings 1.0

QtObject {
    id: application

    property string home_url: "https://www.google.de"

    property var bookmarks: []
    signal bookmarks_changed()

    property ListModel history_model: ListModel {
        id: history_model
        dynamicRoles: true
    }

    property QtObject settings: Settings {
        property alias home_url: application.home_url
        property var bookmarks
        property var history
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
        var tab = newDialog.add_tab("about:blank")
        request.openIn(tab.webview)
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
                application.history_model.append({"title": item.date, "url": false, "favicon_url": false, "date": item.date, "type": "date"})
                current_item_date = item.date
            }
            application.history_model.append(item);
        }
    }

    Component.onDestruction: {
        settings.bookmarks = application.bookmarks;

        // Save the browser history
        var history = [];
        for (var i=0; i<application.history_model.count; i++){
            var item = application.history_model.get(i);
            if (item.type !== "date")
                history.push({"title": item.title, "url": item.url, "favicon_url": item.favicon_url, "date": item.date, "type": item.type});
        }
        application.settings.history = history;
    }

}
