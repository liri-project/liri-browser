import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtWebEngine 1.1
import QtQuick.Layouts 1.1

NavigationDrawer {
    id: drawer
    z: 25
    mode: "right"
    width: Units.dp(350)
    visible: anchors.rightMargin != -width - Units.dp(10)
    View {
        id: downloadsTitle
        height: Units.dp(56)
        width: parent.width
        elevation: listView.contentY > 0 ? 1 : 0
        backgroundColor: "white"
        z: 1

        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Units.dp(16)
                rightMargin: Units.dp(16)
                verticalCenter: parent.verticalCenter
            }

            spacing: Units.dp(8)

            Label {
                Layout.fillWidth: true
                text: qsTr("Downloads")
                style: "title"
                elide: Text.ElideRight
            }

            Button {
                text: qsTr("Clear")
                onClicked: {
                    downloadsModel.clearFinished()
                    if (downloadsModel.count == 0)
                        downloadsDrawer.close()
                }
            }
        }
    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            top: downloadsTitle.bottom
            bottom: parent.bottom
        }

        // NOTE: Now empty state placeholder is necessary because the drawer can't be opened
        // unless there is at least one download
        ListView {
            id: listView

            bottomMargin: Units.dp(8)
            interactive: count > 0
            model: downloadsModel
            delegate: ListItem.Subtitled {
                id: listItem

                interactive: download.state === WebEngineDownloadItem.DownloadCompleted

                property var download: downloadsModel.get(index).modelData

                text: {
                    var index = download.path.lastIndexOf("/")
                    return download.path.substring(index + 1)
                }
                subText: {
                    if (listItem.download.state === WebEngineDownloadItem.DownloadRequested) {
                        return qsTr("Awaiting confirmation")
                    } else if (listItem.download.state === WebEngineDownloadItem.DownloadInProgress) {
                        return qsTr("Downloading...")
                    } else if (listItem.download.state === WebEngineDownloadItem.DownloadCompleted) {
                        return qsTr("Completed")
                    } else if (listItem.download.state === WebEngineDownloadItem.DownloadCancelled) {
                        return qsTr("Cancelled")
                    } else if (listItem.download.state === WebEngineDownloadItem.DownloadInterrupted) {
                        return qsTr("Download failed")
                    } else {
                        return qsTr("Unknown state!")
                    }
                }

                content: ProgressBar {
                    id: progressBar

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width

                    property bool completed: value == maximumValue

                    value: listItem.download.receivedBytes
                    maximumValue: listItem.download.totalBytes
                    visible: listItem.download.state === WebEngineDownloadItem.DownloadInProgress
                }
                secondaryItem: IconButton {
                    anchors.centerIn: parent
                    iconName: "navigation/cancel"
                    visible: listItem.download.state === WebEngineDownloadItem.DownloadInProgress
                    onClicked: {
                        listItem.download.cancel();
                    }
                }

                onClicked: {
                    Qt.openUrlExternally("file://" + download.path)
                }
            }
        }
    }
}
