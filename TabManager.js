var open_tabs = [];
var last_tab_id = -1;
var current_tab_page;
var open_tabs_history = [];

function sortByKey(array, key) {
    // from http://stackoverflow.com/questions/8837454/sort-array-of-objects-by-single-key-with-date-value
    return array.sort(function(a, b) {
        var x = a[key]; var y = b[key];
        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
    });
}

function is_bookmarked(url){
    for (var i=0; i<root.app.bookmarks.length; i++){
        if (root.app.bookmarks[i].url === url)
            return true
    }
    return false

}

function add_bookmark(title, url, favicon_url){
    console.log(root.app.bookmarks)
    root.app.bookmarks.push({title: title, url: url, favicon_url: favicon_url});
    bookmarks_changed();
    reload_bookmarks();
}

function change_bookmark(url, title, new_url, favicon_url){
    for (var i=0; i<root.app.bookmarks.length; i++){
        if (root.app.bookmarks[i].url == url){
            root.app.bookmarks[i].url = new_url;
            root.app.bookmarks[i].title = title;
            root.app.bookmarks[i].favicon_url = favicon_url;
            reload_bookmarks();
            bookmarks_changed();
            return true
        }
    }
    return false

}

function remove_bookmark(url){
    for (var i=0; i<root.app.bookmarks.length; i++){
        if (root.app.bookmarks[i].url == url){
            root.app.bookmarks.splice(i, 1);
            reload_bookmarks();
            bookmarks_changed();
            return true;
        }
    }
    return false
}

function clear_bookmarks(){
    for(var i = bookmark_container.children.length; i > 0 ; i--) {
        bookmark_container.children[i-1].destroy();
  }
}

function load_bookmarks(){
    root.app.bookmarks = sortByKey(root.app.bookmarks, "title"); // Automatically sort root.app.bookmarks
    var bookmark_component = Qt.createComponent("BookmarkItem.qml");
    for (var i=0; i<root.app.bookmarks.length; i++){
        var b = root.app.bookmarks[i];
         var bookmark_object = bookmark_component.createObject(bookmark_container, { title: b.title, url: b.url, favicon_url: b.favicon_url });
    }

    if (root.app.bookmarks.length > 0)
        bookmark_bar.visible = true;
    else
        bookmark_bar.visible = false;

}

function reload_bookmarks(){
    clear_bookmarks();
    load_bookmarks();

    if (current_tab_page)
        current_tab_page.update_toolbar();
}

function bookmarks_changed() {
    // update
    root.app.bookmarks_changed();

}


function get_text_color_for_background(bg) {
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
        return root._tab_text_color_active
    }
}

function shade_color(color, percent) {
    // from http://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
    var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
}

function get_valid_url(url) {
    if (url.indexOf('.') !== -1){
        if (url.lastIndexOf('http://', 0) !== 0){
            if (url.lastIndexOf('https://', 0) !== 0){
                url = 'http://' + url;
            }
        }
    }
    else if (url !== "about:blank")
        url = "http://www.google.com/search?q=" + url;
    return url;
}


function add_tab(url, background){
    var tab_page = new TabPage(url, background);
    return tab_page;
}


function set_current_tab_url (url) {
    if (current_tab_page) {
        current_tab_page.set_url(url);
    }
    else {
        add_tab(url);
    }

}


function set_current_tab(tab_page) {
    if (tab_page === current_tab_page)
        return;
    tab_page.webview.visible = true;

    tab_page.active = true;
    txt_url.text = tab_page.webview.url
    if (current_tab_page) {
        current_tab_page.active = false;
        current_tab_page.webview.visible = false;
        current_tab_page.update_colors();
        open_tabs_history.push(current_tab_page);
    }
    current_tab_page = tab_page;
    root.title = tab_page.title + ' - Browser';

    if (tab_page.webview.loading){
        prg_loading.visible = true;
        btn_refresh.visible = false;
    }
    else{
        prg_loading.visible = false;
        btn_refresh.visible = true;
    }

    tab_page.update_colors();
    tab_page.update_toolbar();
}


function set_url(url) {
    if (open_tabs.length === 0 || !current_tab_page){
        add_tab(url);
    }
    else {
        current_tab_page.set_url(url);
    }
}


function TabPage(url, background) {

    this.bookmark = function() {
        if (is_bookmarked(this.url)) {
            snackbar.open('Removed bookmark "' + this.webview.title + '"');
            remove_bookmark(this.url)
        }
            //snackbar.open("There is already a bookmark for this page")
        else {
            snackbar.open('Added bookmark "' + this.webview.title + '"');
            add_bookmark(this.webview.title, this.webview.url, this.webview.icon);
        }
        this.update_toolbar();

    }

    this.close = function(){
        var tab_id = this.tab_id;

        this.tab.destroy();
        txt_url.text = "";


        this.webview.destroy()
        open_tabs.splice(open_tabs.indexOf(this));

        snackbar_tab_close.url = this.url
        snackbar_tab_close.open('Closed tab "' + this.title + '"');

        // Remove this from open tabs history
        while(open_tabs_history.indexOf(this) !== -1){
            var index = open_tabs_history.indexOf(this);
            open_tabs_history.splice(index, 1);
        }

        prg_loading.visible = false;
        btn_refresh.visible = true;

        if(current_tab_page === this){
            current_tab_page = false;
            if (open_tabs_history.length > 0)
                set_current_tab(open_tabs_history[open_tabs_history.length-1]);
        }


    }

    this.set_url = function(url) {
        url = get_valid_url(url);
        this.url = url;
        this.webview.url = get_valid_url(url);
    }

    this.go_back = function () {
        this.webview.goBack();
    }

    this.go_forward = function() {
        this.webview.goForward();
    }

    this.select = function() {
        set_current_tab(this);
    }

    this.update_colors = function() {
        if (this.active){
            //this.tab.elevation = 4;
            if (this.custom_color) {
                this.color = this.custom_color;
                var new_text_color = get_text_color_for_background(this.custom_color);
                this.text_color = new_text_color;
                toolbar.color = this.custom_color;
                root.current_text_color = new_text_color;
                this.icon_color = root.current_icon_color = new_text_color;
            }
            else {
                this.color = root._tab_color_active;
                this.text_color = root._tab_text_color_active;
                toolbar.color = root._tab_color_active;
                root.current_text_color = root._tab_text_color_active
                this.icon_color = root.current_icon_color = root._icon_color;
            }
        }
        else{
            if (this.custom_color) {
                this.color = this.custom_color_inactive
                this.text_color = root._tab_text_color_inactive;
                this.icon_color = root._tab_text_color_inactive;
            }
            else {
                //this.tab.elevation = 0;
                this.color = root._tab_color_inactive;
                this.text_color = root._tab_text_color_inactive;
                this.icon_color = root._tab_text_color_inactive;
            }
        }
        this.tab.update_colors();

    }

    this.update_toolbar = function() {
        if (this.webview.canGoBack){
            btn_go_back.enabled = true;
        }
        else {
            btn_go_back.enabled = false;

        }

        if (this.webview.canGoForward){
            btn_go_forward.enabled = true;
        }
        else {
            btn_go_forward.enabled = false;
        }

        if (is_bookmarked(this.url))
            btn_bookmark.iconName = "action/bookmark";
        else
            btn_bookmark.iconName = "action/bookmark_outline";

        current_tab_title.text = this.title;
        current_tab_icon.source = this.webview.icon

    }

    this.loading_changed = function(tab, request) {
        if (request.status === 0){
            // LoadStartedStatus
            if (tab === current_tab_page) {
                prg_loading.visible = true;
                btn_refresh.visible = false;
            }

        }
        else if (request.status === 2) {
            // LoadFinishedStatus
            if (tab === current_tab_page) {
                prg_loading.visible = false;
                btn_refresh.visible = true;
            }
            if (tab.url !== tab.webview.url)
                tab.url = tab.webview.url;
                tab.title = tab.webview.title;
                tab.tab.title = tab.title;
                if (tab === current_tab_page) {
                    txt_url.text = tab.webview.url;
                    root.title = tab.webview.title + ' - Browser';
                }
                // Looking for custom tab bar colors
                tab.webview.runJavaScript("function getThemeColor() { var metas = document.getElementsByTagName('meta'); for (i=0; i<metas.length; i++) { if (metas[i].getAttribute('name') === 'theme-color') { return metas[i].getAttribute('content');}} return '';} getThemeColor() ",
                    function(content){
                        if(content !== "") {
                            tab.custom_color = content;
                            tab.custom_color_inactive = shade_color(content, 0.6);
                            tab.update_colors();
                        }
                        else{
                            tab.custom_color = false;
                            tab.custom_color_inactive = false;
                            tab.update_colors();
                        }
                });

        }
        else if (request.status === 3) {
            // LoadFailedStatus
            var new_url = get_valid_url(txt_url.text)
            txt_url.text = new_url;
            tab.set_url(new_url);
        }

        tab.update_toolbar();

    }


    this.reload = function(){
        this.webview.reload();
    }

    this.find_text = function(text, backward) {
        var flags
        if (backward)
            flags |= WebEngineView.FindBackward
        this.webview.findText(text, flags, function(success) {
            if (success)
                root.txt_search.hasError = false;
            else{
                root.txt_search.hasError = true;
            }

        });

    }

    /* Initialization */


    if (url){
        this.url = get_valid_url(url);
    }
    else {
        this.url = start_page;
    }

    this.active = false;

    this.custom_color = false;
    this.custom_color_inactive = false;
    this.color = root._tab_color_active;
    this.text_color = root._tab_text_color_active;
    this.icon_color = root._icon_color;
    this.title = "New Tab";

    this.tab_id = last_tab_id = last_tab_id + 1;

    var webview_component = Qt.createComponent("BrowserWebView.qml");
    this.webview = webview_component.createObject(web_container, { page:this, visible: false, url: this.url, profile: root.app.default_profile });

    var tab_component = Qt.createComponent("BrowserTab.qml");
    this.tab = tab_component.createObject(tab_row, { page: this, webview: this.webview });
    this.tab.close.connect(this.close);

    var tab = this;
    this.webview.loadingChanged.connect(function(request){tab.loading_changed(tab, request)});

    open_tabs.push(this);
    if (!background)
        this.select();


}
