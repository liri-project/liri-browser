
import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles.Material 0.1

Item {
    id: item
    property string color
    property string textColor
    Rectangle {
        id: flickable
        color: item.color
        anchors.fill: parent
        Row {
            spacing: 10
            Column {
                width: flickable.width / 2 - 20
                Item {
                  height: Units.dp(60)
                  width: parent.width
                  Label {
                      style: "title"
                      text: qsTr("Presets")
                      anchors.verticalCenter: parent.verticalCenter
                      anchors.left: parent.left
                      anchors.margins: Units.dp(16)
                      color: item.textColor
                  }
                }
                ListView {
                    id: listViewQPresets
                    width: parent.width
                    height: flickable.height - Units.dp(60)
                    model: root.app.presetQuickSearchesModel
                    anchors.left:parent.left
                    anchors.margins: Units.dp(16)
                    delegate: ListItem.Standard {

                        Row {
                            spacing: Units.dp(10)
                            anchors{
                                margins: Units.dp(10)
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                text: listViewQPresets.model.get(index).name
                                placeholderText: qsTr("Title")
                                floatingLabel: true
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                 }
                                 onTextChanged: listViewQPresets.model.set(index, {"name": text})
                                 style: TextFieldThemed {
                                     helperNotFocusedColor: quickSearchesRoot.linesColor
                                     textColor: quickSearchesRoot.textColor
                                 }
                            }

                            TextField {
                                text: listViewQPresets.model.get(index).key
                                onTextChanged: listViewQPresets.model.set(index, {"key": text})
                                placeholderText: qsTr("Key")
                                floatingLabel: true
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: quickSearchesRoot.linesColor
                                    textColor: quickSearchesRoot.textColor
                                }
                            }

                            TextField {
                                text: listViewQPresets.model.get(index).url
                                onTextChanged: listViewQPresets.model.set(index, {"url": text})
                                placeholderText: qsTr("URL")
                                floatingLabel: true
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: quickSearchesRoot.linesColor
                                    textColor: quickSearchesRoot.textColor
                                }
                            }
                        }
                    }
                }

            }

            Column {
                width: flickable.width / 2 - 20
                Item {
                  height: Units.dp(60)
                  width: parent.width
                  Label {
                      style: "title"
                      text: qsTr("Custom (can overwrite presets)")
                      anchors.verticalCenter: parent.verticalCenter
                      anchors.margins: Units.dp(16)
                      anchors.left: parent.left
                      color: item.textColor
                  }
                }
                ListView {
                    id: listView
                    width: parent.width
                    height: flickable.height - Units.dp(60)
                    anchors.margins: Units.dp(16)
                    anchors.left: parent.left
                    model: root.app.customQuickSearchesModel
                    delegate: ListItem.Standard {

                        Row {
                            spacing: Units.dp(10)
                            anchors{
                                margins: Units.dp(10)
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                text: listView.model.get(index).name
                                placeholderText: qsTr("Name")
                                floatingLabel: true
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                 }
                                 onTextChanged: listView.model.set(index, {"name": text})
                                 style: TextFieldThemed {
                                     helperNotFocusedColor: quickSearchesRoot.linesColor
                                     textColor: quickSearchesRoot.textColor
                                 }
                            }

                            TextField {
                                text: listView.model.get(index).key
                                placeholderText: qsTr("Key")
                                floatingLabel: true
                                onTextChanged: listView.model.set(index, {"key": text})
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: quickSearchesRoot.linesColor
                                    textColor: quickSearchesRoot.textColor
                                }
                            }

                            TextField {
                                text: listView.model.get(index).url
                                onTextChanged: listView.model.set(index, {"url": text})
                                placeholderText: qsTr("URL")
                                floatingLabel: true
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: quickSearchesRoot.linesColor
                                    textColor: quickSearchesRoot.textColor
                                }
                            }

                            IconButton {
                                iconName: "action/delete"
                                color: item.textColor
                                size: Units.dp(15)
                                onClicked: listView.model.remove(index)
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

            }

        }

        }
        ActionButton {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Units.dp( 48 )
            iconName: "content/add"
            text: qsTr("Add new color")
            onClicked: root.app.customQuickSearchesModel.append({"name":"", "key": "", "url": ""})
        }

}
