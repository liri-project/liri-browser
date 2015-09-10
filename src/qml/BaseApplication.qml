import QtQuick 2.1
import Qt.labs.settings 1.0
import "url.js" as URL

Item {
    id: application

    property string webEngine: "qtwebengine"
    property string platform: "unknown/desktop"
    property bool enableShortCuts: true
    property bool enableNewWindowAction: true

    property string homeUrl: "https://www.google.de"

    property string searchEngine: "google"

    property string sourcetemp: "unknown"
    property string sourceHighlightTheme: "monokai_sublime"

    property var bookmarks

    property bool integratedAddressbars: false
    property bool tabsEntirelyColorized: false

    property bool newTabPage: true
    property int maxFrequentSites: 10
    property int minVisitsToBeFrequent: 5

    property ListModel historyModel: ListModel {
        id: historyModel
        dynamicRoles: true
    }

    property var frequentSites: []

    property QtObject settings: Settings {
        property alias homeUrl: application.homeUrl
        property alias searceEngine: application.searchEngine
        property alias sourceHighlightTheme: application.sourceHighlightTheme
        property alias newTabPage: application.newTabPage
        property alias bookmarks: application.bookmarks
        property var history
        property var downloads
        property alias integratedAddressbars: application.integratedAddressbars
        property alias tabsEntirelyColorized: application.tabsEntirelyColorized
    }

    function updateFrequentSites() {
        var sites = {}

        for (var i = 0; i < historyModel.count; i++){
            var item = historyModel.get(i);

            if (item.type !== "date") {
                var url = new URL.URL(item.url)
                var baseURL = url.protocol + "//" + url.host + url.pathname

                if (sites.hasOwnProperty(baseURL)) {
                    sites[baseURL].count++
                    if (item.faviconUrl !== "" && sites[baseURL].faviconURL === "")
                        sites[baseURL].faviconUrl = item.faviconUrl
                } else {
                    sites[baseURL] = {
                        "title": item.title,
                        "url": baseURL,
                        "faviconUrl": item.faviconUrl,
                        "count": 1
                    }
                }
            }
        }

        var siteNames = Object.keys(sites)

        // Sort frequent sites first
        siteNames.sort(function (a, b) {
            return sites[b].count - sites[a].count
        })

        // Require a minimum visit count to be considered frequent
        siteNames = siteNames.filter(function(siteName) {
            return sites[siteName].count >= minVisitsToBeFrequent
        })

        // Only show a certain number of frequent sites
        frequentSites = siteNames.slice(0, maxFrequentSites).map(function(siteName) {
            return sites[siteName]
        })
    }

    Component.onCompleted: {
        console.log("Locale name: " + Qt.locale().name)

        if (!bookmarks)
            bookmarks = []

        if (!settings.history)
            settings.history = [];

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

        updateFrequentSites()
        historyModel.countChanged.connect(updateFrequentSites)
    }

    Component.onDestruction: {
        // Save the browser history
        var history = [];
        for (var i=0; i<application.historyModel.count; i++){
            var item = application.historyModel.get(i);
            if (item.type !== "date") {
                history.push({
                    "title": item.title,
                    "url": item.url,
                    "faviconUrl": item.faviconUrl,
                    "date": item.date,
                    "type": item.type,
                    "color": item.color
                });
            }
        }
        application.settings.history = history;
    }
}
