import QtQuick 2.1
import QtWebEngine 1.1
import Qt.labs.settings 1.0

BaseApplication {
    id: application

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Default"
    }

    property Component browserWindowComponent: BrowserWindow {
        app: application
    }

    function createWindow (){
        var newWindow = browserWindowComponent.createObject(application)
        return newWindow
    }
    function createDialog(request) {
        var newDialog = browserWindowComponent.createObject(application)
        var tab = newDialog.addTab("about:blank")
        request.openIn(tab.webview.view)
        return newDialog
    }
    function load() {
        var browserWindow = createWindow()
    }

}
