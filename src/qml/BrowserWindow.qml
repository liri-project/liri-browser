import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.3 as Controls
import QtWebEngine 1.1
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0

ApplicationWindow {
    id: root

    property QtObject app

    title: activeTab ? (activeTab.webview.title || qsTr("Loading")) + " - Liri Browser" : "Liri Browser"
    visible: true

    width: 1000
    height: 640

    theme {
        id: theme
        //backgroundColor: ""
        primaryColor: "#2196F3"
        primaryDarkColor: "#1976D2"
        accentColor: "#4CAF50"
        //tabHighlightColor: ""
    }

    /* User Settings */

    property variant win;


    property Settings settings: Settings {
        id: settings
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
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

	property string searchEngine: "google"

    property alias txtSearch: txtSearch
    property alias downloadsDrawer: downloadsDrawer
    property alias iconConnectionType: iconConnectionType
    //property alias flickable: flickable

    property bool fullscreen: false
    property bool secureConnection: false


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
			else
				url = "https://www.google.com/search?q=" + url;
		}
        return url;
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
        changedBookmarks();
    }

    function changeBookmark(url, title, newUrl, faviconUrl){
        for (var i=0; i<root.app.bookmarks.length; i++){
            if (root.app.bookmarks[i].url == url){
                root.app.bookmarks[i].url = newUrl;
                root.app.bookmarks[i].title = title;
                root.app.bookmarks[i].faviconUrl = faviconUrl;
                changedBookmarks();
                return true;
            }
        }
        return false;

    }

    function removeBookmark(url){
        for (var i=0; i<root.app.bookmarks.length; i++){
            if (root.app.bookmarks[i].url == url){
                root.app.bookmarks.splice(i, 1);
                changedBookmarks();
                return true;
            }
        }
        return false;
    }

    function clearBookmarks(){
        for(var i = bookmarkContainer.children.length; i > 0 ; i--) {
            bookmarkContainer.children[i-1].destroy();
      }
    }

    function loadBookmarks(){
        root.app.bookmarks = sortByKey(root.app.bookmarks, "title"); // Automatically sort root.app.bookmarks
        var bookmarkComponent = Qt.createComponent("BookmarkItem.qml");
        for (var i=0; i<root.app.bookmarks.length; i++){
            var b = root.app.bookmarks[i];
            var bookmarkObject = bookmarkComponent.createObject(bookmarkContainer, { title: b.title, url: b.url, faviconUrl: b.faviconUrl });
        }

        if (root.app.bookmarks.length > 0)
            bookmarkBar.visible = true;
        else
            bookmarkBar.visible = false;
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



    /** NEW FUNCTIONS AND PROPERTIES **/

    property var activeTab
    property var activeTabItem
    property var lastActiveTab
    property var activeTabHistory: []

    property int lastTabUID: 0

    property ListModel tabsModel: ListModel {}

    property bool activeTabInEditMode: false
    property var activeTabInEditModeItem

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
        updateToolbar();
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
        var ntp = false;
        if (url){
            u = getValidUrl(url);
        }
        else if (root.app.newTabPage) {
            ntp = true;
        }
        else {
            u = root.app.homeUrl;
        }

        var webviewComponent = Qt.createComponent ("BrowserWebView.qml");
        var webview = webviewComponent.createObject(webContainer, {url: u, newTabPage: ntp, profile: root.app.defaultProfile, uid: lastTabUID});
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
                });
            }
        }
    }

    function ensureTabIsVisible(t) {
        if (typeof(t) === "number") {
            var modelIndex = getTabModelIndexByUID(t);
            listView.positionViewAtIndex(modelIndex, ListView.Visible);
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
            }
            else {
                callback();
                setActiveTab(getUIDByModelIndex(0), true);
            }
        }
        else {
            callback();
        }
    }

    function setActiveTabURL(url) {
        var u = getValidUrl(url);
        activeTab.webview.url = u;
    }

    function toggleActiveTabBookmark() {
        var url = activeTab.webview.url;
        var icon = activeTab.webview.icon;
        var title = activeTab.webview.title;
        if (isBookmarked(url)) {
            snackbar.open(qsTr('Removed bookmark %1').arg(title));
            removeBookmark(url)
        }
        else {
            snackbar.open(qsTr('Added bookmark "%1"').arg(title));
            addBookmark(title, url, icon, activeTab.customColor);
        }
        updateToolbar ();
    }

    function activeTabFindText(text, backward) {
        var flags
        if (backward)
            flags |= WebEngineView.FindBackward
        activeTab.webview.findText(text, flags, function(success) {
            if (success)
                root.txtSearch.hasError = false;
            else{
                root.txtSearch.hasError = true;
            }
        });

    }

    function activeTabViewSourceCode () {
      activeTab.webview.runJavaScript("function getSource() { return document.documentElement.innerHTML;} getSource() ",
          function(content){
            addTab("http://liri-browser.github.io/sourcecodeviewer/index.html?c=" + content);
      });
    }

    function updateToolbar () {
        var url = activeTab.webview.url;

        if (isBookmarked(url))
            btnBookmark.iconName = "action/bookmark";
        else
            btnBookmark.iconName = "action/bookmark_border";
    }

    /* Events */

    function activeTabUrlChanged() {
        updateToolbar ();
    }

    function downloadRequested(download) {
        downloadRequested(download);
    }


    /** ------------- **/

    ShortcutActions {}

    initialPage: Rectangle {
        id: page

        View {
            id: titlebar

            width: parent.width
            height: if (root.app.integratedAddressbars) {tabBar.height + bookmarkBar.height} else {tabBar.height + toolbar.height + bookmarkBar.height}

            elevation: 2

                Rectangle {
                    id: tabBar
                    height: root.tabHeight
                    color: root.tabBackgroundColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    ListView {
                        id: listView

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.right: toolbarIntegrated.left

                        orientation: ListView.Horizontal
                        spacing: Units.dp(1)
                        interactive: mouseArea.draggingId == -1

                        model: tabsModel

                        delegate: TabBarItemDelegate {}

                        MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                property int index: listView.indexAt(mouseX + listView.contentX, mouseY)
                                property int draggingId: -1
                                property int activeIndex
                                propagateComposedEvents: true

                                onClicked: mouse.accepted = false;

                                onPressed: if (root.activeTabInEditMode) {mouse.accepted = false;}

                                onPressAndHold: {
                                    if (root.activeTabInEditMode) {mouse.accepted = false;}
                                    else {
                                        var item = listView.itemAt(mouseX + listView.contentX, mouseY);
                                        if(item !== null) {
                                            //root.activeTab = item;
                                            draggingId = listView.model.get(activeIndex=index).uid;
                                        }
                                    }

                                }
                                onReleased: {
                                    if (activeTab.uid !== draggingId)
                                        getTabModelDataByUID(draggingId).state = "inactive";
                                    else
                                        getTabModelDataByUID(draggingId).state = "active";
                                    draggingId = -1
                                    mouse.accepted = false;
                                }
                                onPositionChanged: {
                                    if (draggingId != -1 && index != -1 && index != activeIndex) {
                                        listView.model.move(activeIndex, activeIndex = index, 1);
                                    }
                                    mouse.accepted = false;

                                }
                                onDoubleClicked: {
                                    mouse.accepted = false;
                                }

                                onWheel: {
                                    listView.flick(wheel.angleDelta.y*10, 0);
                                }
                         }

                    }

                    View {
                        id: toolbarIntegrated
                        elevation: Units.dp(2)
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: if (root.app.integratedAddressbars) { btnAddTabIntegrated.width + btnDownloadsIntegrated.width + btnMenuIntegrated.width + Units.dp(24)*3 } else { Units.dp(48) }

                        IconButton {
                            id: btnAddTabIntegrated
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: btnDownloadsIntegrated.left
                            anchors.margins:if (root.app.integratedAddressbars) { Units.dp(24) } else { 12 }
                            color: root.iconColor
                            iconName: "content/add"

                            onClicked: addTab();
                        }

                        IconButton {
                            id: btnDownloadsIntegrated
                            visible: root.app.integratedAddressbars && downloadsDrawer.activeDownloads
                            width: if (root.app.integratedAddressbars && downloadsDrawer.activeDownloads) { Units.dp(24) } else { 0 }
                            color: if (downloadsDrawer.activeDownloads){ theme.accentColor } else { root.iconColor }
                            iconName : "file/file_download"
                            anchors.right: btnMenuIntegrated.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: if (root.app.integratedAddressbars && downloadsDrawer.activeDownloads) { Units.dp(24) } else { 0 }
                            onClicked: downloadsDrawer.open(btnDownloads)// downloadsPopup.open(btnDownloads)

                            Rectangle {
                                visible: downloadsDrawer.activeDownloads
                                z: -1
                                width: parent.width + Units.dp(5)
                                height: parent.height + Units.dp(5)
                                anchors.centerIn: parent
                                color: "white"
                                radius: width*0.5
                            }
                        }

                        IconButton {
                            id: btnMenuIntegrated
                            visible: root.app.integratedAddressbars
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins:if (root.app.integratedAddressbars) { Units.dp(24) } else { 0 }
                            width: if (root.app.integratedAddressbars) { Units.dp(24) } else { 0 }
                            color: root.iconColor
                            iconName : "navigation/more_vert"
                            onClicked: overflowMenu.open(btnMenuIntegrated)

                        }

                    }

                }

                Item {
                    id: toolbarContainer
                    anchors.top: tabBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Column {
                        anchors.fill: parent

                        Rectangle {
                            id: toolbar
                            visible: !integratedAddressbars
                            //anchors.fill: parent
                            height: Units.dp(64)
                            width: parent.width
                            color: activeTab.customColor ? activeTab.customColor : root.tabColorActive

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Units.dp(24)
                                spacing: Units.dp(24)

                                IconButton {
                                    id: btnGoBack
                                    iconName : "navigation/arrow_back"
                                    enabled: root.activeTab.webview.canGoBack
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: root.activeTab.webview.goBack()
                                    color: root.currentIconColor
                                }

                                IconButton {
                                    id: btnGoForward
                                    iconName : "navigation/arrow_forward"
                                    enabled: root.activeTab.webview.canGoForward
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: root.activeTab.webview.goForward()
                                    color: root.currentIconColor
                                }

                                IconButton {
                                    id: btnRefresh
                                    hoverAnimation: true
                                    iconName : "navigation/refresh"
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: root.currentIconColor
                                    visible: !activeTab.webview.loading
                                    onClicked: activeTab.webview.reload()
                                }

                                LoadingIndicator {
                                    id: prgLoading
                                    visible: activeTab.webview.loading
                                    width: btnRefresh.width
                                    height: btnRefresh.height
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: parent.width - this.x - rightToolbar.width - parent.spacing
                                    radius: Units.dp(2)
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: parent.height - Units.dp(16)
                                    color: root.addressBarColor
                                    opacity: 0.5

                                    Icon {
                                        x: Units.dp(16)
                                        id: iconConnectionType
                                        name: root.activeTab.webview.secureConnection ? "action/lock" : "social/public"
                                        color: root.activeTab.webview.secureConnection ? "green" : root.currentIconColor
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    TextField {
                                        id: txtUrl
                                        anchors.fill: parent
                                        anchors.leftMargin: iconConnectionType.x + iconConnectionType.width + Units.dp(16)
                                        anchors.rightMargin: Units.dp(24)
                                        anchors.topMargin: Units.dp(4)
                                        showBorder: false
                                        text: root.activeTab.webview.url
                                        placeholderText: qsTr("Input search or web address")
                                        opacity: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        textColor: root.tabTextColorActive
                                        onAccepted: setActiveTabURL(text);
                                    }

                                }

                                Row {
                                    id: rightToolbar
                                    width: childrenRect.width + spacing
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Units.dp(24)

                                    IconButton {
                                        id: btnBookmark
                                        color: root.currentIconColor
                                        iconName: "action/bookmark_border"
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: toggleActiveTabBookmark();
                                    }

                                    IconButton {
                                        id: btnDownloads
                                        color: if (downloadsDrawer.activeDownloads){ theme.accentColor } else {root.currentIconColor}
                                        iconName : "file/file_download"
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: downloadsDrawer.open(btnDownloads)// downloadsPopup.open(btnDownloads)

                                        Rectangle {
                                            visible: downloadsDrawer.activeDownloads
                                            z: -1
                                            width: parent.width + Units.dp(5)
                                            height: parent.height + Units.dp(5)
                                            anchors.centerIn: parent
                                            color: "white"
                                            radius: width*0.5
                                        }
                                    }

                                    IconButton {
                                        id: btnMenu
                                        color: root.currentIconColor
                                        iconName : "navigation/more_vert"
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: overflowMenu.open(btnMenu)

                                    }

                                    Rectangle { width: Units.dp(24)} // placeholder

                                }

                            }
                        }

                        Rectangle {
                            id: bookmarkBar
                            color: toolbar.color
                            height: if (visible) { Units.dp(48) } else {0}
                            width: parent.width

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: Units.dp(5)
                                anchors.leftMargin: Units.dp(24)
                                contentWidth: bookmarkContainer.implicitWidth + Units.dp(16)

                                Row {
                                    id: bookmarkContainer
                                    anchors.fill: parent
                                    spacing: Units.dp(15)

                                }

                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }


                        Dropdown {
                            id: overflowMenu
                            objectName: "overflowMenu"

                            width: Units.dp(250)
                            height: columnView.height + Units.dp(16)

                            ColumnLayout {
                                id: columnView
                                width: parent.width
                                anchors.centerIn: parent

                                ListItem.Standard {
                                    text: qsTr("New window")
                                    iconName: "action/open_in_new"
                                    onClicked: app.createWindow()
                                }

                                /*ListItem.Standard {
                                    text: qsTr("Save page")
                                    iconName: "content/save"
                                }

                                ListItem.Standard {
                                    text: qsTr("Print page")
                                    iconName: "action/print"
                                }*/

                                ListItem.Standard {
                                    text: qsTr("History")
                                    iconName: "action/history"
                                    onClicked: { overflowMenu.close(); historyDrawer.open(); }
                                }

                                ListItem.Standard {
                                    text: qsTr("Fullscreen")
                                    iconName: "navigation/fullscreen"
                                    onClicked: if (!root.fullscreen) {root.startFullscreenMode(); overflowMenu.close()}

                                   }

                                ListItem.Standard {
                                    text: qsTr("Search")
                                    iconName: "action/search"
                                    onClicked: { overflowMenu.close(); root.showSearchOverlay();}
                                }

                                ListItem.Standard {
                                    text: qsTr("Bookmark")
                                    visible: root.app.integratedAddressbars
                                    iconName: "action/bookmark_border"
                                    onClicked: {  overflowMenu.close(); root.toggleActiveTabBookmark();}
                                }

                                ListItem.Standard {
                                    text: qsTr("Add to dash")
                                    //visible: root.app.integratedAddressbars
                                    iconName: "action/dashboard"
                                    onClicked: { overflowMenu.close(); root.addToDash(activeTab.webview.url, activeTab.webview.title, activeTab.customColor); }
                                }

                                ListItem.Standard {
                                    text: qsTr("View source")
                                    //visible: root.app.integratedAddressbars
                                    iconName: "action/code"
                                    onClicked: {
                                      overflowMenu.close();
                                      activeTabViewSourceCode();
                                    }
                                }

                                ListItem.Standard {
                                    text: qsTr("Settings")
                                    iconName: "action/settings"
                                    onClicked: { overflowMenu.close(); settingsDrawer.open(); }
                                }
                            }
                        }

                    }

                }

        }


        Rectangle {
            id: fullscreenBar
            z: 5
            visible: root.fullscreen
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Units.dp(48)

            Row {
                anchors.fill: parent
                anchors.leftMargin: Units.dp(24)
                anchors.rightMargin: Units.dp(24)
                spacing: Units.dp(24)

                Image {
                    source: root.activeTab.webview.icon
                    width: Units.dp(18)
                    height: Units.dp(18)
                    anchors.verticalCenter: parent.verticalCenter

                }

                Text {
                    text: root.activeTab.webview.title
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: root.fontFamily
                }

            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(7)
                iconName: "navigation/fullscreen_exit"
                onClicked: {
                    root.endFullscreenMode();
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true

                onEntered: {
                    parent.opacity = 1.0;
                }

                onExited: {
                    parent.opacity = 0.0;
                }

            }

            Behavior on opacity { NumberAnimation {duration: 300} }
            onVisibleChanged: {
                if (visible)
                    var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", parent);
                    timer.interval = 1500;
                    timer.repeat = false;
                    timer.triggered.connect(function () {
                        opacity = 0
                    });

                    timer.start();
            }

        }


        Item {
            anchors.top: if (fullscreen){parent.top} else { titlebar.bottom}
            anchors.topMargin: Units.dp(2)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Item {
                id: webContainer
                anchors.fill: parent
            }

        }
    }

    SettingsDrawer { id: settingsDrawer }

    DownloadsDrawer { id: downloadsDrawer }

    HistoryDrawer { id: historyDrawer }

    View {
        id: websiteSearchOverlay
        visible: false
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Units.dp(48)
        elevation: Units.dp(4)

        Row {
            anchors.fill: parent
            anchors.margins: Units.dp(5)
            anchors.leftMargin: Units.dp(24)
            anchors.rightMargin: Units.dp(24)
            spacing: Units.dp(24)

            TextField {
                id: txtSearch
                placeholderText: qsTr("Search")
                errorColor: "red"
                onAccepted: activeTabFindText(text)
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                iconName: "hardware/keyboard_arrow_up"
                onClicked: activeTabFindText(txtSearch.text, true)
                anchors.verticalCenter: parent.verticalCenter
            }

            IconButton {
                iconName: "hardware/keyboard_arrow_down"
                onClicked: activeTabFindText(txtSearch.text)
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        IconButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Units.dp(24)
            iconName: "navigation/close"
            color: root.iconColor
            onClicked: root.hideSearchOverlay()
        }
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
    Window {
         id: subWindowSource
         width: 555
         height: 333
         visible: false
         title: "Source of "
         flags: Qt.SubWindow
         Controls.ScrollView {
            anchors.fill: parent
            Text {
              id: sourceCode
              x:5
              width: subWindowSource.width - 30
              textFormat: Text.PlainText
              wrapMode: Text.WrapAnywhere
              text: "source"
            }
        }
    }
    Component.onCompleted: {
        // Add tab
        addTab();

        // Profile handling
        root.app.defaultProfile.downloadRequested.connect(root.downloadRequested);

        // Bookmark handling
        root.loadBookmarks();
        root.app.changedBookmarks.connect(root.reloadBookmarks)
    }

}
