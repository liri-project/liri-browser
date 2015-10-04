import QtQuick 2.1
import Qt.labs.settings 1.0

Item {
    id: application

    property string webEngine: "qtwebengine"
    property string platform: "unknown/desktop"
    property bool enableShortCuts: true
    property bool enableNewWindowAction: true

    property bool customFrame: true

    property string homeUrl: "https://www.google.com"

    property string searchEngine: "google"

    property bool darkTheme: true

    function getCurrentHour () {
        var d = new Date()
        return d.getHours()
    }

    property string darkThemeColor: "#263238"
    property bool isNight: (getCurrentHour() >= 19 || getCurrentHour() <= 7)

    property string sourcetemp: "unknown"
    property string sourceHighlightTheme: "monokai_sublime"

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

    property bool customSitesColors: true

    property ListModel customSitesColorsModel: ListModel {
        id: customSitesColorsModel
        dynamicRoles: true
    }

    property ListModel presetSitesColorsModel: ListModel {
        id: presetSitesColorsModel
        dynamicRoles: true
    }

    property string sitesColorsPresets: "[ \
            {'domain':'facebook.com', 'color': '#3b5998'} , \
            {'domain':'linkedin.com', 'color': '#646464'} , \
            {'domain':'twitter.com', 'color': '#00aced'} \
        ]"

    property QtObject settings: Settings {
        property alias homeUrl: application.homeUrl
        property alias searceEngine: application.searchEngine
        property alias sourceHighlightTheme: application.sourceHighlightTheme
        property alias newTabPage: application.newTabPage
        property var bookmarks
        property var history
        property var dashboard
        property var downloads
        property var customsitescolors
        property bool customSitesColors: application.customSitesColors
        property alias integratedAddressbars: application.integratedAddressbars
        property alias tabsEntirelyColorized: application.tabsEntirelyColorized
        property alias customFrame: application.customFrame
        property alias darkTheme: application.darkTheme
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
        var currentDate = new Date()
        var dateString = currentDate.toLocaleDateString();

        var currentItemDate = dateString;
        var history_l = application.settings.history.length
        for (var i=0; i<history_l; i++){
            var item = application.settings.history[i];
            if (currentItemDate != item.date) {
                application.historyModel.append({"title": item.date, "url": false, "faviconUrl": false, "date": item.date, "type": "date", color: item.color})
                currentItemDate = item.date
            }
            application.historyModel.append(item);
        }

        // Load custom sites color
        var presets = eval(application.sitesColorsPresets)

        for (var t in presets)
          application.presetSitesColorsModel.append(presets[t])

        for (var z in application.settings.customsitescolors)
            application.customSitesColorsModel.append(application.settings.customsitescolors[z])

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

        // Save sites color model
        var customsitescolors = [];
        for (var i=0; i<application.customSitesColorsModel.count; i++){
            var item = application.customSitesColorsModel.get(i);
            customsitescolors.push({"domain": item.domain, "color": item.color})
        }
        application.settings.customsitescolors = customsitescolors;
    }
}
