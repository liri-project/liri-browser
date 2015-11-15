import QtQuick 2.1
import Qt.labs.settings 1.0

Item {
    id: application

    objectName: "application"

    property string webEngine: "qtwebengine"
    property string platform: "unknown/desktop"
    property bool enableShortCuts: true
    property bool enableNewWindowAction: true

    property bool customFrame: false

    property string homeUrl: "https://www.google.com"

    property string searchEngine: "google"

    property bool darkTheme: true

    function getCurrentHour () {
        var d = new Date()
        return d.getHours()
    }

    property color lightThemeColor: "#FAFAFA"
    property color darkThemeColor: "#263238"
    property color privateNavColor: "#212121"
    property bool isNight: (getCurrentHour() >= 19 || getCurrentHour() <= 7)

    property string sourcetemp: "unknown"
    property string sourceHighlightTheme: "monokai_sublime"
    property string sourceHighlightFont: "Roboto Mono"
    property int sourceHighlightFontPixelSize: 12

    property bool integratedAddressbars: false
    property bool tabsEntirelyColorized: false

    property bool uppercaseTabTitle: false

    property bool allowReducingTabsSizes: false

    property bool newTabPage: true

    function getBookmarksArray() {
        var bookmarks = [], bM_l = application.bookmarksModel.count;
        for (var i=0; i<bM_l; i++){
            var item = application.bookmarksModel.get(i);
            bookmarks.push({"title": item.title, "url": item.url.toString(), "faviconUrl": item.faviconUrl.toString()});
        }
        return bookmarks;
    }

    function getHistoryArray() {
        var history = [], hM_l = application.historyModel.count;
        for (var i=0; i<hM_l; i++){
            var item = application.historyModel.get(i);
            if (item.type !== "date")
                history.push({"title": item.title, "url": item.url.toString(), "faviconUrl": item.faviconUrl.toString(), "date": item.date, "type": item.type, "color": item.color});
        }
        return history;
    }

    property ListModel bookmarksModel: ListModel {
        id: bookmarksModel
        dynamicRoles: true
    }

    function saveBookmarks() {
        application.settings.bookmarks = getBookmarksArray();
    }

    function saveHistory() {
        application.settings.history = getHistoryArray();
    }

    function saveDashboard() {
        var dashboard = [], dM_l = application.dashboardModel.count;
        for (var i=0; i<dM_l; i++){
            var item = application.dashboardModel.get(i);
            dashboard.push({"title": item.title, "url": item.url, "iconUrl": item.iconUrl, "bgColor": item.bgColor, "fgColor": item.fgColor, "uid": item.uid})
        }
        application.settings.dashboard = dashboard;
    }

    function saveSitesColors(){
        var customsitescolors = [], cscM_l = application.customSitesColorsModel.count;
        for (var i=0; i<cscM_l; i++){
             var item = application.customSitesColorsModel.get(i);
             customsitescolors.push({"domain": item.domain, "color": item.color})
        }
        application.settings.customsitescolors = customsitescolors;
    }

    function saveQuickSearches(){
        var customquicksearches = [], cqsm_l = application.customQuickSearchesModel.count;
        for (var i=0; i<cqsm_l; i++){
             var item = application.customQuickSearchesModel.get(i);
             customquicksearches.push({"name": item.name, "key": item.key, "url": item.url})
        }
        application.settings.customquicksearches = customquicksearches;
    }

    property ListModel searchSuggestionsModel: ListModel {
        objectName: "searchSuggestionsModel"
        id: searchSuggestionsModel
        dynamicRoles: true
        function appendSuggestion(suggestion, icon, insertMode) {
            if (insertMode === "start")
                searchSuggestionsModel.insert(0, {"suggestion": suggestion, "icon": icon})
            else
                searchSuggestionsModel.append({"suggestion": suggestion, "icon": icon});
        }
    }

    property ListModel historyModel: ListModel {
        id: historyModel
        dynamicRoles: true
    }

    property ListModel dashboardModel: ListModel {
        id: dashboardModel
        dynamicRoles: true
    }

    property bool customSitesColors: true
    property bool quickSearches: true

    property ListModel customSitesColorsModel: ListModel {
        id: customSitesColorsModel
        dynamicRoles: true
    }

    property ListModel presetSitesColorsModel: ListModel {
        id: presetSitesColorsModel
        dynamicRoles: true
    }

    property ListModel customQuickSearchesModel: ListModel {
        id: customQuickSearchesModel
        dynamicRoles: true
    }

    property ListModel presetQuickSearchesModel: ListModel {
        id: presetQuickSearchesModel
        dynamicRoles: true
    }

    function getInfosOfQuickSearch(key) {
        var name, url, result, i,count = application.customQuickSearchesModel.count, count_pre = application.presetQuickSearchesModel.count;
        for(i=0;i<count_pre;i++) {
            if(""+application.presetQuickSearchesModel.get(i).key+"" === key) {
                result = application.presetQuickSearchesModel.get(i)
            }
        }
        for(i=0;i<count;i++) {
            if(""+application.customQuickSearchesModel.get(i).key+"" === key) {
                result = application.customQuickSearchesModel.get(i)
            }
        }
        return result
    }

    property var sitesColorsPresets: [
        {'domain':'facebook.com', 'color': '#3b5998'} ,
        {'domain':'linkedin.com', 'color': '#646464'} ,
        {'domain':'twitter.com', 'color': '#00aced'} ,
        {'domain':'github.com', 'color': '#f5f5f5'} ,
        {'domain':'youtube.com', 'color': '#b31217'} ,
        {'domain':'9gag.com', 'color': '#262626'} ,
        {'domain':'reddit.com', 'color': '#c5dbf9'} ,
        {'domain':'soundcloud.com', 'color': '#f64100'} ,
        {'domain':'khanacademy.org', 'color': '#66CD00'}
    ]
    property var quickSearchesPresets: [
            {'name':'Youtube', 'key': 'ytb', 'url': 'https://www.youtube.com/results?search_query='},
            {'name':'Google Play Store', 'key': 'gps', 'url': 'https://play.google.com/store/search?q='}
        ]
    property bool bookmarksBar: true
    property bool bookmarksBarAlwaysOn: false
    property bool bookmarksBarOnlyOnDash: true

    property QtObject settings: Settings {
        property alias homeUrl: application.homeUrl
        property alias searceEngine: application.searchEngine
        property alias sourceHighlightTheme: application.sourceHighlightTheme
        property alias sourceHighlightFont: application.sourceHighlightFont
        property alias sourceHighlightFontPixelSize: application.sourceHighlightFontPixelSize
        property alias newTabPage: application.newTabPage
        property var bookmarks
        property var history
        property var dashboard
        property var downloads
        property var customsitescolors
        property bool customSitesColors: application.customSitesColors
        property alias uppercaseTabTitle: application.uppercaseTabTitle
        property alias integratedAddressbars: application.integratedAddressbars
        property alias tabsEntirelyColorized: application.tabsEntirelyColorized
        property alias customFrame: application.customFrame
        property alias darkTheme: application.darkTheme
        property alias bookmarksBar: application.bookmarksBar
        property alias bookmarksBarAlwaysOn: application.bookmarksBarAlwaysOn
        property alias bookmarksBarOnlyOnDash: application.bookmarksBarOnlyOnDash
        property alias allowReducingTabsSizes: application.allowReducingTabsSizes
        property alias lightThemeColor: application.lightThemeColor
        property alias darkThemeColor: application.darkThemeColor
        property alias privateNavColor: application.privateNavColor
        property var customquicksearches
    }

    Component.onCompleted: {
        console.log("Locale name: " + Qt.locale().name)

        if (!settings.history)
            settings.history = [];

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
        var presets = application.sitesColorsPresets

        for (var t in presets)
          application.presetSitesColorsModel.append(presets[t])

        for (var z in application.settings.customsitescolors)
            application.customSitesColorsModel.append(application.settings.customsitescolors[z])

        // Load the dashboard model
        for (var i=0; i<application.settings.dashboard.length; i++)
            application.dashboardModel.append(application.settings.dashboard[i]);

        // Load the bookmarks model
        for (i=0; i<application.settings.bookmarks.length; i++) {
            var data = application.settings.bookmarks[i];
            data["uid"] = i;
            application.bookmarksModel.append(data);
        }

        var presets_qs = application.quickSearchesPresets
        for (t in presets_qs)
          application.presetQuickSearchesModel.append(presets_qs[t])

        // Load the quick searches model
        if (application.settings.customquicksearches) {
            for (var i=0; i<application.settings.customquicksearches.length; i++)
                application.customQuickSearchesModel.append(application.settings.customquicksearches[i]);
        }
    }

}
