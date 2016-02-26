import QtQuick 2.4
import Material.Extras 0.1

ListModel {
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

    // TODO: What does the teardown argument do?
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

    function downloadRequested(download) {
        downloadsModel.insert(0, { modelData: download })
        // TODO: Should we confirm the download and location first?
        download.accept()
        download.stateChanged.connect(downloadsModel.downloadsChanged)
        download.receivedBytesChanged.connect(downloadsModel.progressChanged)

        downloadsModel.downloadsChanged()

        console.log("Starting download to " + download.path)
    }
}
