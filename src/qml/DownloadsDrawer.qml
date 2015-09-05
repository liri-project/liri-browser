import QtQuick 2.0
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem


NavigationDrawer {
    id: drawer
    z: 25
    mode: "right"
    width: Units.dp(350)    

    property bool activeDownloads:listView.count

    function append(download) {
        downloadModel.append(download)
        downloadModel.downloads.push(download)
    }

    Column {
        anchors.fill: parent
        anchors.margins: Units.dp(24)
        spacing: Units.dp(5)

        View {
            id: downloadTitle
            height: label.height + Units.dp(30)
            width: parent.width
            Label {
                id: label
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Units.dp(16)
                    rightMargin: Units.dp(16)
                    centerIn:parent
                }
                text: qsTr("Downloads")
                style: "title"
                font.pixelSize: Units.dp(24)
            }
        }

        Item {
            width: parent.width
            height: parent.height - downloadTitle.height

            ListModel {
                id: downloadModel
                property var downloads: []
            }

            function append(download) {
                downloadModel.append(download)
                downloadModel.downloads.push(download)
            }

            Component {
                id: downloadItemDelegate

                Rectangle {
                    width: listView.width
                    height: childrenRect.height
                    anchors.margins: 10
                    radius: Units.dp(3)
                    color: "transparent"
                    Rectangle {
                        id: pogressBar

                        property real progress: downloadModel.downloads[index]
                                               ? downloadModel.downloads[index].receivedBytes / downloadModel.downloads[index].totalBytes : 0

                        radius: 3
                        color: width === listView.width ? "#4CAF50" : "#448AFF"
                        width: listView.width * progress
                        height: Units.dp(48)

                        Behavior on width {
                            SmoothedAnimation { duration: 100 }
                        }


                    }

                    Text {
                        id: label
                        text: path
                        color: if (pogressBar.width === listView.width) { "white" } else { "black" }
                        font.family: root.fontFamily
                        font.pixelSize: Units.dp(14)
                        elide: Text.ElideLeft
                        clip: true
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: btnCancel.left
                            leftMargin: Units.dp(5)
                            rightMargin: Units.dp(5)
                        }
                    }

                    IconButton {
                        id: btnCancel
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Units.dp(12)
                        iconName: "navigation/cancel"
                        color: if (pogressBar.width === listView.width) { "white" } else { "black" }
                        onClicked: {
                            var download = downloadModel.downloads[index]

                            download.cancel();

                            downloadModel.downloads = downloadModel.downloads.filter(function (el) {
                                return el.id !== download.id;
                            });
                            downloadModel.remove(index)
                        }
                    }

                }

            }

            ScrollView {
                anchors.fill: parent
                ListView {
                    id: listView
                    anchors.fill: parent

                    spacing: 5

                    model: downloadModel
                    delegate: downloadItemDelegate

                    Text {
                        visible: !listView.count
                        font.family: root.fontFamily
                        text: qsTr("No active downloads")
                        anchors.top: downloadTitle.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

            }


        }

    }




}
