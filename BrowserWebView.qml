import QtQuick 2.4
import Material 0.1
import QtWebEngine 1.1
//import QtWebEngine.experimental 1.1


WebEngineView {
    id: webbview
    property var page
    anchors.fill: parent

    onIconChanged: {
        if (page.active)
            root.current_tab_icon.source = icon;
    }

    /*settings.autoLoadImages: appSettings.autoLoadImages
                 settings.javascriptEnabled: appSettings.javaScriptEnabled
                 settings.errorPageEnabled: appSettings.errorPageEnabled*/

     onCertificateError: {
         console.log("onCertificateError")
         console.log(error)
         /*error.defer()
         sslDialog.enqueue(error)*/
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
         request.accept()
     }

     profile.onDownloadRequested: {
        console.log("WebEngineView.profile.onDownloadRequested")
        console.log(download)
        root.downloads_popup.append(download);
        download.accept();
     }
}
