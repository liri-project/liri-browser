import QtQuick 2.1
import QtWebEngine 1.1
import Qt.labs.settings 1.0
import Material.Extras 0.1
import "model"
import "ui"

BaseApplication {
    id: application

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Default"

        onDownloadRequested: downloadsModel.downloadRequested(download)
    }

    property alias downloadsModel: __downloadsModel

    function createWindow() {
        var newWindow = browserWindowComponent.createObject(application)
        return newWindow
    }

    // TODO: Why is this named createDialog?
    function createDialog(request) {
        var newDialog = browserWindowComponent.createObject(application)
        var tab = newDialog.addTab("about:blank")
        request.openIn(tab.view.item.view)
        return newDialog
    }

    // TODO: Is this still needed?
    function load() {
        var browserWindow = createWindow()
    }

    Component.onCompleted: {
        downloadsModel.loadHistory()
    }

    Component.onDestruction: {
        downloadsModel.saveHistory(true);
    }

    DownloadsModel {
        id: __downloadsModel
    }

    Component {
        id: browserWindowComponent

        BrowserWindow {
            app: application
        }
    }
}
