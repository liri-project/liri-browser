var open_tabs = [];
var last_tab_id = -1;
var current_tab_page;

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
    else
        url = "http://www.google.com/search?q=" + url;
    return url;
}


function add_tab(url){
    return new TabPage(url);
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


function TabPage(url) {

    this.create = function() {

    }

    this.close = function(){
        var tab_id = this.tab_id;
        this.webview.destroy()
        snackbar_tab_close.open('Closed tab "' + this.title + '"');
        open_tabs.splice(open_tabs.indexOf(this));

        this.tab.destroy();
        txt_url.text = "";

        if(current_tab_page === this){
            current_tab_page = false;
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
        tab.tab.favicon = tab.webview.icon;

    }


    this.reload = function(){
        this.webview.reload();
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
    this.webview = webview_component.createObject(web_container, { page:this, visible: true, url: this.url });

    var tab_component = Qt.createComponent("BrowserTab.qml");
    this.tab = tab_component.createObject(tab_row, { page: this, webview: this.webview });
    this.tab.close.connect(this.close);

    var tab = this;
    this.webview.loadingChanged.connect(function(request){tab.loading_changed(tab, request)});

    open_tabs.push(this);
    this.select();


}
