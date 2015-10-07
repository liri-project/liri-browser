
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
                    id: listViewPresets
                    width: parent.width
                    height: flickable.height - Units.dp(60)
                    model: root.app.presetSitesColorsModel
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
                                text: listViewPresets.model.get(index).domain
                                placeholderText: qsTr("Domain")
                                floatingLabel: true
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                 }
                                 onTextChanged: listViewPresets.model.set(index, {"domain": text})
                                 style: TextFieldThemed {
                                     helperNotFocusedColor: sitesColorsRoot.linesColor
                                     textColor: sitesColorsRoot.textColor
                                 }
                            }

                            TextField {
                                text: listViewPresets.model.get(index).color
                                onTextChanged: listViewPresets.model.set(index, {"color": text})
                                placeholderText: qsTr("Color")
                                floatingLabel: true
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: sitesColorsRoot.linesColor
                                    textColor: sitesColorsRoot.textColor
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
                    model: root.app.customSitesColorsModel
                    anchors.margins: Units.dp(16)
                    anchors.left: parent.left

                    delegate: ListItem.Standard {

                        Row {
                            spacing: Units.dp(10)
                            anchors{
                                margins: Units.dp(10)
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                text: listView.model.get(index).domain
                                placeholderText: qsTr("Domain")
                                floatingLabel: true
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                 }
                                 onTextChanged: listView.model.set(index, {"domain": text})
                                 style: TextFieldThemed {
                                     helperNotFocusedColor: sitesColorsRoot.linesColor
                                     textColor: sitesColorsRoot.textColor
                                 }
                            }

                            TextField {
                                text: listView.model.get(index).color
                                placeholderText: qsTr("Color")
                                floatingLabel: true
                                onTextChanged: listView.model.set(index, {"color": text})
                                anchors{
                                   verticalCenter: parent.verticalCenter
                                }
                                style: TextFieldThemed {
                                    helperNotFocusedColor: sitesColorsRoot.linesColor
                                    textColor: sitesColorsRoot.textColor
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
            onClicked: root.app.customSitesColorsModel.append({"domain":"", "color": ""})
        }

}
