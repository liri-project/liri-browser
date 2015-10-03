import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0

MaterialWindow {
    id: root

    property QtObject app

    title: activeTab ? (activeTab.webview.title || qsTr("Loading")) + " - Liri Browser" : "Liri Browser"
    visible: true
    width: 1000
    height: 640

    theme {
        id: theme
        primaryColor: "#F44336"
        primaryDarkColor: "#D32F2F"
        accentColor: "#FF5722"
    }

    /* User Settings */

    property variant win;

    property bool customFrame: false

    property bool snappedRight: false
    property bool snappedLeft: false

    property Settings settings: Settings {
        id: settings
        property alias x: root.x
        property alias y: root.y
        //property alias width: root.width
        //property alias height: root.height
        property alias primaryColor: theme.primaryColor
        property alias accentColor: theme.accentColor
        property alias searchEngine: root.searchEngine
    }

    /* Style Settings */
    property color tabBackgroundColor: "#f1f1f1"
    property int tabHeight: Units.dp(40)
    property int tabWidth: Units.dp(200)
    property int tabWidthEdit: Units.dp(400)
    property int tabsSpacing: Units.dp(1)
    property int titlebarHeight: Units.dp(148)
    property color tabColorActive: "#ffffff"
    property color tabColorInactive: "#e5e5e5"
    property alias tabIndicatorColor: theme.accentColor
    property color tabTextColorActive: "#212121"
    property color tabTextColorInactive: "#757575"
    property color iconColor: "#7b7b7b"
    property color addressBarColor: "#e0e0e0"
    property color currentTextColor: activeTab.customTextColor ? activeTab.customTextColor : iconColor
    property color currentIconColor: activeTab.customTextColor ? activeTab.customTextColor : iconColor

    property string fontFamily: "Roboto"

    property alias omniboxText: page

    property string searchEngine: "google"

    property string sourcetemp: "test"

    property alias txtSearch: page.txtSearch
    property alias websiteSearchOverlay: page.websiteSearchOverlay
    property var downloadsDrawer

    property bool fullscreen: false

    property bool mobile: Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2)) < Units.dp(1000) || width < Units.dp(640)

    property var activeTab
    property var activeTabItem
    property var lastActiveTab
    property var activeTabHistory: []

    property int lastTabUID: 0

    property ListModel tabsModel: ListModel {}

    property ListModel sitesColorModel: ListModel {
        ListElement {
            domain: "youtube.com"
            color: "#E62117"
        }
    }

    property bool activeTabInEditMode: false
    property var activeTabInEditModeItem

    /* Functions */

    function startFullscreenMode(){
        fullscreen = true;
        showFullScreen();

    }

    function endFullscreenMode() {
        fullscreen = false;
        showNormal();
    }

    function showSearchOverlay() {
        websiteSearchOverlay.visible = true;
        txtSearch.forceActiveFocus();
        txtSearch.selectAll();
    }

    function hideSearchOverlay() {
        websiteSearchOverlay.visible = false;
    }

    function sortByKey(array, key) {
        // from http://stackoverflow.com/questions/8837454/sort-array-of-objects-by-single-key-with-date-value
        return array.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    }

    function getValidUrl(url) {
        if (url.indexOf('.') !== -1){
            if (url.lastIndexOf('http://', 0) !== 0){
                if (url.lastIndexOf('https://', 0) !== 0){
                    url = 'http://' + url;
                }
            }
        }
        else if (url.lastIndexOf('http://', 0) !== 0 &&  url.lastIndexOf('https://', 0) !== 0 && url !== "about:blank") {
      	    if(root.app.searchEngine == "duckduckgo")
     	        url = "https://duckduckgo.com/?q=" + url;
      	    else if(root.app.searchEngine == "yahoo")
                url = "https://search.yahoo.com/search?q=" + url;
            else if(root.app.searchEngine == "bing")
                url = "http://www.bing.com/search?q=" + url;
      	    else
                url = "https://www.google.com/search?q=" + url;
      	}
        return url;
    }

    function searchForCustomColor(url) {
        var domains = url.split(".")
        if(domains[0].indexOf("://") != 1)
            domains[0]=domains[0].substring(domains[0].indexOf("://")+3,domains[0].length)
        if(domains[0] == "www")
            domains.shift()
        var domains_l = domains.length;
        if(domains[domains_l-1].indexOf("/") != -1)
            domains[domains_l-1] = domains[domains_l-1].substring(0,domains[domains_l-1].indexOf("/"))
        var domain = domains.join(".")
        var nb=sitesColorModel.count,i,result = "none"
        console.log(domain)
        for(i=0;i<nb;i++) {
            if (sitesColorModel.get(i).domain == domain)
                result=sitesColorModel.get(i).color
        }
        return result
    }

    function isASearchQuery(url) {
      if (url.indexOf('.') !== -1){
          if (url.lastIndexOf('http://', 0) !== 0){
              if (url.lastIndexOf('https://', 0) !== 0){
                  return false;
              }
          }
      }
      else
        return true;
    }

    function getBetterIcon(url, title, color, callback){
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var json = JSON.parse(doc.responseText);
                if ("error" in json) {
                    callback(url, title, color, false);
                }
                else {
                    callback(url, title, color, json["icons"][0].url);
                }
            }
        }
        doc.open("get", "http://icons.better-idea.org/api/icons?url=" + url);
        doc.setRequestHeader("Content-Encoding", "UTF-8");
        doc.send();
    }

    function addToDash(url, title, color) {
        var uidMax = 0;
        for (var i=0; i<root.app.dashboardModel.count; i++) {
            if (root.app.dashboardModel.get(i).uid > uidMax){
                uidMax = root.app.dashboardModel.get(i).uid;
            }
        }

        getBetterIcon(url, title, color, function(url, title, color, iconUrl){
            var fgColor
            if (color)
                fgColor = getTextColorForBackground(color.toString())
            else
                fgColor = "black"
            root.app.dashboardModel.append({"title": title, "url": url.toString(), "iconUrl": iconUrl.toString(), "uid": uidMax+1, "bgColor": color || "white", "fgColor": fgColor});
            //: %1 is a title
            snackbar.open(qsTr('Added website "%1" to dash').arg(title));
        });
    }

    function isBookmarked(url){
        for (var i=0; i<root.app.bookmarks.length; i++){
            if (root.app.bookmarks[i].url === url)
                return true
        }
        return false
    }

    function addBookmark(title, url, faviconUrl, color){
        root.app.bookmarks.push({title: title, url: url, faviconUrl: faviconUrl, color: color});
        root.app.changedBookmarks();
    }

    function changeBookmark(url, title, newUrl, faviconUrl){
        for (var i=0; i<root.app.bookmarks.length; i++){
            if (root.app.bookmarks[i].url == url){
                root.app.bookmarks[i].url = newUrl;
                root.app.bookmarks[i].title = title;
                root.app.bookmarks[i].faviconUrl = faviconUrl;
                root.app.changedBookmarks();
                return true;
            }
        }
        return false;

    }

    function removeBookmark(url){
        for (var i=0; i<root.app.bookmarks.length; i++){
            if (root.app.bookmarks[i].url == url){
                root.app.bookmarks.splice(i, 1);
                root.app.changedBookmarks();
                return true;
            }
        }
        return false;
    }

    function clearBookmarks(){
        for(var i = page.bookmarkContainer.children.length; i > 0 ; i--) {
            page.bookmarkContainer.children[i-1].destroy();
        }
    }

    function loadBookmarks() {
        root.app.bookmarks = sortByKey(root.app.bookmarks, "title"); // Automatically sort root.app.bookmarks
        var bookmarkComponent = Qt.createComponent("BookmarkItem.qml");
        for (var i=0; i<root.app.bookmarks.length; i++){
            var b = root.app.bookmarks[i];
            var bookmarkObject = bookmarkComponent.createObject(page.bookmarkContainer, { title: b.title, url: b.url, faviconUrl: b.faviconUrl });
        }
    }

    function reloadBookmarks(){
        clearBookmarks();
        loadBookmarks();
    }

    function bookmarksChanged() {
        root.app.changedBookmarks();
    }

    function shadeColor(color, percent) {
        // from http://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
        var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
        return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
    }

    function getTextColorForBackground(bg) {
        // from http://stackoverflow.com/questions/12043187/how-to-check-if-hex-color-is-too-black
        var c = bg.substring(1);      // strip #
        var rgb = parseInt(c, 16);   // convert rrggbb to decimal
        var r = (rgb >> 16) & 0xff;  // extract red
        var g = (rgb >>  8) & 0xff;  // extract green
        var b = (rgb >>  0) & 0xff;  // extract blue

        var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; // per ITU-R BT.709

        if (luma < 200) {
            return "white";
        }
        else {
            return root.TabTextColorActive
        }
    }

    onActiveTabChanged: {
        // Handle last active tab
        if (lastActiveTab !== undefined && lastActiveTab !== null && lastActiveTab !== false) {
            lastActiveTab.state = "inactive";
            lastActiveTab.webview.visible = false;
        }
        // Handle now active tab
        if (activeTab) {
            if (activeTabInEditModeItem)
                activeTabInEditModeItem.editModeActive = false;
            lastActiveTab = activeTab;
            activeTab.state = "active";
            activeTab.webview.visible = true;
            activeTabHistory.push(activeTab.uid);
        }
        page.updateToolbar();
    }

    function getTabModelDataByUID (uid) {
        for (var i=0; i<tabsModel.count; i++) {
            if (tabsModel.get(i).uid == uid) {
                return tabsModel.get(i);
            }
        }
        return false;
    }

    function getTabModelIndexByUID (uid) {
        for (var i=0; i<tabsModel.count; i++) {
            if (tabsModel.get(i).uid == uid) {
                return i;
            }
        }
        return false;
    }

    function getUIDByModelIndex(i) {
        return tabsModel.get(i).uid;
    }

    function addTab(url, background) {
        var u;
        var ntp = false, stp = false;
        if (url) {
            if (url == "liri://settings") {
                stp = true;
                u = url;
            } else {
                u = getValidUrl(url);
            }
        } else if (root.app.newTabPage && !stp) {
            ntp = true;
        } else {
            u = root.app.homeUrl;
        }

        var webviewComponent;

        if (app.webEngine === "qtwebengine")
            webviewComponent = Qt.createComponent ("BrowserWebView.qml");
        else if (app.webEngine === "oxide")
            webviewComponent = Qt.createComponent ("BrowserOxideWebView.qml");
        var webview = webviewComponent.createObject(page.webContainer, {url: u, newTabPage: ntp, settingsTabPage: stp ,profile: root.app.defaultProfile, uid: lastTabUID});
        var modelData = {
            url: url,
            webview: webview,
            uid: lastTabUID,
            state:"inactive",
            hasCloseButton: true,
            closeButtonIconName: "navigation/close",
            iconSource: webview.icon,
            customColor: false,
            customColorLight: false,
            customTextColor: false,
        }
        tabsModel.append(modelData);
        if (!background)
            setActiveTab(lastTabUID, true);
        lastTabUID++;
        return modelData;
    }

    function removeTab(t) {
        // t is uid
        if (typeof(t) === "number") {
            // Remove all uid references from activeTabHistory:
            while (activeTabHistory.indexOf(t) > -1) {
                activeTabHistory.splice(activeTabHistory.indexOf(t), 1);
            }

            // Set last active tab:
            if (activeTab.uid === t) {
                setLastActiveTabActive(function(){
                    var modelData = getTabModelDataByUID(t);
                    modelData.webview.visible = false;
                    modelData.webview.destroy();
                    tabsModel.remove(getTabModelIndexByUID(t));
                    // Was the last tab closed?
                    if (tabsModel.count === 0) {
                        addTab();
                    }
                });
            }
            else {
                var modelData = getTabModelDataByUID(t);
                modelData.webview.visible = false;
                modelData.webview.destroy();
                tabsModel.remove(getTabModelIndexByUID(t));
            }
        }
    }

    function ensureTabIsVisible(t) {
        if (typeof(t) === "number") {
            var modelIndex = getTabModelIndexByUID(t);
            page.listView.positionViewAtIndex(modelIndex, ListView.Visible);
        }
    }

    function setActiveTab(t, ensureVisible, callback) {
        if (typeof(t) === "number") {
            activeTab = getTabModelDataByUID(t);
        }
        if (ensureVisible)
            ensureTabIsVisible(t);
        if (callback)
            callback();
    }

    function setLastActiveTabActive (callback) {
        if (tabsModel.count > 1) {
            if (activeTabHistory.length > 0) {
                setActiveTab(activeTabHistory[activeTabHistory.length-1], true, callback);
            } else {
                callback();
                setActiveTab(getUIDByModelIndex(0), true);
            }
        } else {
            callback();
        }
    }

    function setActiveTabURL(url) {
        if (url == "liri://settings") {
            u = url;
            activeTab.webview.settingsTabPage = true;
            activeTab.webview.newTabPage = false;
        } else {
            var u = getValidUrl(url);
            activeTab.webview.settingsTabPage = false;
            activeTab.webview.url = u;
        }
    }

    function toggleActiveTabBookmark() {
        var url = activeTab.webview.url;
        var icon = activeTab.webview.icon;
        var title = activeTab.webview.title;
        if (isBookmarked(url)) {
            snackbar.open(qsTr('Removed bookmark %1').arg(title));
            removeBookmark(url)
        } else {
            snackbar.open(qsTr('Added bookmark "%1"').arg(title));
            addBookmark(title, url, icon, activeTab.customColor);
        }
        page.updateToolbar ();
    }

    function activeTabFindText(text, backward) {
        var flags
        activeTab.webview.findText(text, backward, function(success) {
            root.txtSearch.hasError = !success;
        });
    }

    function activeTabViewSourceCode () {
        activeTab.webview.runJavaScript("function getSource() { return '' + document.documentElement.innerHTML + '';} getSource() ", function(content) {
            addTab("http://liri-browser.github.io/sourcecodeviewer/index.html");
            root.app.sourcetemp = content;
            root.app.sourcetemp = root.app.sourcetemp.replace(/\r?\n|\r/g,"");
            root.app.sourcetemp = root.app.sourcetemp.replace(/    /g,"");
            root.app.sourcetemp = encodeURI(root.app.sourcetemp);
        });
    }

    /* Events */

    function activeTabUrlChanged() {
        page.updateToolbar ();
    }

    /** ------------- **/

    Item {
        id: shortCutActionsContainer
    }

    initialPage: BrowserPage { id: page }

    HistoryDrawer { id: historyDrawer }

    SettingsPage { id: settingsPage }

    TabsListPage { id: tabsListPage }

    SitesColorPage { id: sitesColorPage }

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

    Dialog {
        id: dlgCertificateError

        property var page
        property var error
        property string url

        visible: false
        width: Units.dp(400)
        title: qsTr("This Connection Is Untrusted")
        //: %1 is an URL
        text: qsTr("You are about to securely connect to %1 but we can't confirm that your connection is secure because this site's identity can't be verified.").arg("'" + url + "'")
        positiveButtonText: qsTr("Continue anyway")
        negativeButtonText: qsTr("Leave page")

        onAccepted: {
           error.ignoreCertificateError();
        }

        onRejected: {
            error.rejectCertificate();
        }

        function showError(error) {
            error.defer();
            url = error.url;
            dlgCertificateError.error = error;
            dlgCertificateError.show();
        }
    }

    Component.onCompleted: {
        // Create shortcut actions
        if (app.enableShortCuts) {
            var component = Qt.createComponent("ShortcutActions.qml");
            component.createObject(shortCutActionsContainer);
        }

        // Create download drawer
        if (app.webEngine === "qtwebengine") {
            var component = Qt.createComponent("DownloadsDrawer.qml");
            downloadsDrawer = component.createObject(page);
        }


        // Add tab
        addTab();

        // Bookmark handling
        root.loadBookmarks();
        root.app.changedBookmarks.connect(root.reloadBookmarks)
    }
}
