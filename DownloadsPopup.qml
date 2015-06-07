import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1


Dropdown {
    id: popup
    width: Units.dp(400)
    height: Units.dp(250)

    property bool active_downloads:list_view.count

    function append(download) {
        download_model.append(download)
        download_model.downloads.push(download)
    }

    Column {
        anchors.fill: parent
        anchors.margins: Units.dp(24)
        spacing: Units.dp(5)

        Item {
            id: download_title
            width: parent.width
            height: Units.dp(24)
            Text {
                font.family: root.font_family
                text: "Downloads"
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                iconName: "navigation/close"
                onClicked: popup.close()
            }

        }

        Item {
            width: parent.width
            height: parent.height - download_title.height

            ListModel {
                id: download_model
                property var downloads: []
            }

            function append(download) {
                download_model.append(download)
                download_model.downloads.push(download)
            }

            Component {
                id: download_item_delegate

                Rectangle {
                    width: list_view.width
                    height: childrenRect.height
                    anchors.margins: 10
                    radius: Units.dp(3)
                    color: "transparent"
                    Rectangle {
                        id: pogress_bar

                        property real progress: download_model.downloads[index]
                                               ? download_model.downloads[index].receivedBytes / download_model.downloads[index].totalBytes : 0

                        radius: 3
                        color: width === list_view.width ? "#4CAF50" : "#448AFF"
                        width: list_view.width * progress
                        height: Units.dp(48)

                        Behavior on width {
                            SmoothedAnimation { duration: 100 }
                        }


                    }

                    Text {
                        id: label
                        text: path
                        color: if (pogress_bar.width === list_view.width) { "white" } else { "black" }
                        font.family: root.font_family
                        font.pixelSize: Units.dp(14)
                        elide: Text.ElideLeft
                        clip: true
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: btn_cancel.left
                            leftMargin: Units.dp(5)
                            rightMargin: Units.dp(5)
                        }
                    }

                    IconButton {
                        id: btn_cancel
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Units.dp(12)
                        iconName: "navigation/cancel"
                        color: if (pogress_bar.width === list_view.width) { "white" } else { "black" }
                        onClicked: {
                            var download = download_model.downloads[index]

                            download.cancel()

                            download_model.downloads = download_model.downloads.filter(function (el) {
                                return el.id !== download.id;
                            });
                            download_model.remove(index)
                        }
                    }

                }

            }

            ScrollView {
                anchors.fill: parent
                ListView {
                    id: list_view
                    anchors.fill: parent

                    spacing: 5

                    model: download_model
                    delegate: download_item_delegate

                    Text {
                        visible: !list_view.count
                        font.family: root.font_family
                        text: "No active downloads"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

            }


        }

    }
}
