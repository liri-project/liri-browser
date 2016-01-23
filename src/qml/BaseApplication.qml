import QtQuick 2.1
import Qt.labs.settings 1.0
import "js/utils.js" as Utils
import "model"

Item {
    id: application

    objectName: "application"

    property string webEngine: "qtwebengine"
    property string platform: "unknown/desktop"
    property bool enableShortCuts: true
    property bool enableNewWindowAction: true

    property bool useCustomFrame: false

    property string homeUrl: "https://www.google.com"

    property string searchEngine: "google"

    property bool darkTheme: false

    function getCurrentHour() {
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
    property bool tabsEntirelyColorized: true

    property bool uppercaseTabTitle: false

    property bool allowReducingTabsSizes: false

    property bool newTabPage: true

    onSearchEngineChanged: {
        Utils.searchEngine = searchEngine
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

    property alias bookmarksModel: __bookmarksModel
    property alias historyModel: __historyModel
    property alias dashboardModel: __dashboardModel

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
    property bool shadeBehindTabs: true

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
        property alias useCustomFrame: application.useCustomFrame
        property alias darkTheme: application.darkTheme
        property alias bookmarksBar: application.bookmarksBar
        property alias bookmarksBarAlwaysOn: application.bookmarksBarAlwaysOn
        property alias bookmarksBarOnlyOnDash: application.bookmarksBarOnlyOnDash
        property alias allowReducingTabsSizes: application.allowReducingTabsSizes
        property alias lightThemeColor: application.lightThemeColor
        property alias darkThemeColor: application.darkThemeColor
        property alias privateNavColor: application.privateNavColor
        property alias shadeBehindTabs: application.shadeBehindTabs
        property var customquicksearches
    }

    Component.onCompleted: {
        console.log("Locale name: " + Qt.locale().name)

        bookmarksModel.fromArray(settings.bookmarks)
        historyModel.fromArray(settings.history)
        dashboardModel.fromArray(settings.dashboard)

        // Load custom sites color
        var presets = application.sitesColorsPresets

        for (var t in presets)
          application.presetSitesColorsModel.append(presets[t])

        for (var z in application.settings.customsitescolors)
            application.customSitesColorsModel.append(application.settings.customsitescolors[z])

        var presets_qs = application.quickSearchesPresets
        for (t in presets_qs)
          application.presetQuickSearchesModel.append(presets_qs[t])

        // Load the quick searches model
        if (application.settings.customquicksearches) {
            for (var i=0; i<application.settings.customquicksearches.length; i++)
                application.customQuickSearchesModel.append(application.settings.customquicksearches[i]);
        }
    }

    Component.onDestruction: {
        application.settings.bookmarks = bookmarksModel.toArray();
        application.settings.history = historyModel.toArray();
        application.settings.dashboard = dashboardModel.toArray();
    }

    BookmarksModel {
        id: __bookmarksModel
    }

    DashboardModel {
        id: __dashboardModel
    }

    HistoryModel {
        id: __historyModel
    }
}
