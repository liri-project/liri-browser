import QtQuick 2.1
import QtWebEngine 1.1

QtObject {
    id: application



    property Component browserWindowComponent: BrowserWindow {
        app: application
        /*onClosing: destroy()*/
    }
    /*property Component browserDialogComponent: BrowserDialog {
        onClosing: destroy()
    }*/

    function createWindow(profile) {
        var newWindow = browserWindowComponent.createObject(application)
        //newWindow.get_current_tab().webview.profile = profile;
        //profile.downloadRequested.connect(newWindow.onDownloadRequested)
        return newWindow
    }
    function createDialog(request) {
        var newDialog = browserWindowComponent.createObject(application)
        var tab = newDialog.add_tab("about:blank")
        request.openIn(tab.webview)
        //newDialog.currentWebView.profile = profile
        return newDialog
    }
    function load() {
        var browserWindow = createWindow() /*(defaultProfile)
        browserWindow.currentWebView.url = url*/
    }
}
