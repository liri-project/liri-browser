import QtQuick 2.1
import QtWebEngine 1.1
import Qt.labs.settings 1.0
import Material.Extras 0.1

BaseApplication {
    id: application

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "Default"

        onDownloadRequested: {
            downloadsModel.insert(0, { modelData: download })
            // TODO: Should we confirm the download and location first?
            download.accept()
            download.stateChanged.connect(downloadsModel.downloadsChanged)
            download.receivedBytesChanged.connect(downloadsModel.progressChanged)

            downloadsModel.downloadsChanged()

            console.log("Starting download to " + download.path)
        }
    }

    property Component browserWindowComponent: BrowserWindow {
        app: application
    }

    property ListModel downloadsModel: ListModel {
        id: downloadsModel
        dynamicRoles: true

        property bool hasActiveDownloads
        property bool hasDownloads: count > 0

        property real overallProgress

        function loadHistory() {
            if (application.settings.downloads) {
                downloadsModel.clear()

                for (var i = 0; i < application.settings.downloads.length; i++) {
                    var download = application.settings.downloads[i]

                    downloadsModel.append({ modelData: download })
                }
            }
        }

        function saveHistory(teardown) {
            // Save a history of downloads
            var list = [];
            for (var i = 0; i < downloadsModel.count; i++) {
                var download = downloadsModel.get(i).modelData
                var state = download.state === WebEngineDownloadItem.DownloadInProgress ||
                            download.state === WebEngineDownloadItem.DownloadRequested
                        ? WebEngineDownloadItem.DownloadCancelled
                        : download.state

                list.push({
                    "path": download.path,
                    "state": state,
                    "receivedBytes": download.receivedBytes,
                    "totalBytes": download.totalBytes
                })

                if (teardown && download.hasOwnProperty("cancel"))
                    download.cancel()
            }
            application.settings.downloads = list;
        }

        function downloadsChanged() {
            hasActiveDownloads = ListUtils.filteredCount(downloadsModel, function(download) {
                return download.state === WebEngineDownloadItem.DownloadInProgress
            }) > 0

            saveHistory()
        }

        function progressChanged() {
            var activeDownloads = ListUtils.filter(downloadsModel, function(download) {
                return download.state === WebEngineDownloadItem.DownloadInProgress
            })

            var receivedBytes = ListUtils.sum(activeDownloads, "receivedBytes")
            var totalBytes = ListUtils.sum(activeDownloads, "totalBytes")

            overallProgress = receivedBytes/totalBytes
        }

        function clearFinished() {
            for (var i = 0; i < downloadsModel.count;) {
                var download = downloadsModel.get(i).modelData

                if (download.state !== WebEngineDownloadItem.DownloadInProgress) {
                    remove(i)
                } else {
                    i++
                }
            }

            saveHistory()
        }
    }

    function createWindow() {
        var newWindow = browserWindowComponent.createObject(application)
        return newWindow
    }

    function createDialog(request) {
        var newDialog = browserWindowComponent.createObject(application)
        var tab = newDialog.addTab("about:blank")
        request.openIn(tab.view.item.view)
        return newDialog
    }

    function load() {
        var browserWindow = createWindow()
    }

    Component.onCompleted: {
        downloadsModel.loadHistory()
    }

    Component.onDestruction: {
        downloadsModel.saveHistory(true);
    }
}
