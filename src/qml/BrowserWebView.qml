import QtQuick 2.4
import Material 0.1
import QtWebEngine 1.1
//import QtWebEngine.experimental 1.1


WebEngineView {
    id: webbview
    property var page
    anchors.fill: parent

    onIconChanged: {
        if (page.tab.state !== "inactive")
            root.current_tab_icon.source = icon;

        // Set the favicon in history
        var history_model = root.app.history_model;
        for (var i=0; i<history_model.count; i++) {
            var item = history_model.get(i);
            if (item.url == webbview.url){
                item.favicon_url = webbview.icon
                history_model.set(i, item);
                break;
            }
            console.log(i)
        }
    }

    /*settings.autoLoadImages: appSettings.autoLoadImages
                 settings.javascriptEnabled: appSettings.javaScriptEnabled
                 settings.errorPageEnabled: appSettings.errorPageEnabled*/

     onCertificateError: {
         dlg_certificate_error.show_error(error);
     }

     onNewViewRequested: {
         console.log("onNewViewRequested")
         if (!request.userInitiated)
             console.log("Warning: Blocked a popup window.")
         else if (request.destination === WebEngineView.NewViewInTab) {
             var tab = root.add_tab("about:blank");
             request.openIn(tab.webview);
         } else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
             var tab = root.add_tab("about:blank", true);
             request.openIn(tab.webview);
         } else if (request.destination === WebEngineView.NewViewInDialog) {
             var dialog = root.app.createDialog(request);
         } else {
             // New window
             var dialog = root.app.createDialog(request);
         }
     }

     onFullScreenRequested: {
         console.log("onFullScreenRequested")
         if (request.toggleOn) {
             root.start_fullscreen_mode();
         }
         else {
             root.end_fullscreen_mode();
         }
         request.accept();
     }
}
