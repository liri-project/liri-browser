import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1

Rectangle {
    id: settingsRoot
    anchors.fill: parent

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: settings_col.height
        View {
            id: view
            height: label.height + Units.dp(30)
            width: parent.width
            Label {
                id: label
                anchors {
                    left: parent.left
                    leftMargin: 30
                    right: parent.right
                    bottom: parent.bottom
                }
                text:  qsTr("Settings")
                style: "title"
                font.pixelSize: Units.dp(30)
            }
        }
        Row {
          width: parent.width
          anchors {
            left: parent.left
            top: parent.top
            topMargin: view.height + 10
            leftMargin: 30
          }
          spacing:30
          Column {
            id: settings_col
            width: parent.width/2 - 60
            spacing: Units.dp(0)

            Item {
              height: Units.dp(60)
              width: parent.width
              Label {
                  style: "title"
                  text: qsTr("General")
                  anchors.verticalCenter: parent.verticalCenter
              }
            }

            ListItem.Standard {
                text: ""
                height:60
                TextField {
                    id: txtHomeUrl
                    width: parent.width - 30
                    anchors {
                      verticalCenter: parent.verticalCenter
                      left: parent.left
                      leftMargin: 15
                    }
                    text: root.app.homeUrl
                    placeholderText: qsTr("Start page")
                    floatingLabel: true
                }
            }

          ListItem.Standard {
                text: ""
                height:60
                MenuField {
                    id: menuSearchEngine
                    anchors {
                      verticalCenter: parent.verticalCenter
                      left: parent.left
                      leftMargin: 15
                    }
                    property string selectedEngine: model[selectedIndex].toLowerCase();
                    width: parent.width - 30
                    model: getListedSearchEngines()
                    helperText: "Search Engine"

            function getListedSearchEngines() {
              if(root.app.searchEngine == "duckduckgo")
                  return ["DuckDuckGo", "Google", "Yahoo"]
              else if(root.app.searchEngine == "yahoo")
                  return ["Yahoo", "Google", "DuckDuckGo"]
              else
                  return ["Google", "DuckDuckGo", "Yahoo"]
        }
                }
                anchors.bottomMargin: 30
            }

            Item {
                height: Units.dp(60)
                width: parent.width
                Label {
                    style: "title"
                    text: qsTr("Appearance")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItem.Standard {
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbDashboard
                        checked: root.app.newTabPage
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Enable dashboard")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                    }
                }
                onClicked: {
                    chbDashboard.checked = !chbDashboard.checked
                }
            }

            ListItem.Standard {
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbIntegratedAddressbars
                        checked: root.app.integratedAddressbars
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Integrated addressbars")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                    }
                }
                onClicked: {
                    chbIntegratedAddressbars.checked = !chbIntegratedAddressbars.checked
                }
            }

            ListItem.Standard {
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbTabsEntirelyColorized
                        checked: root.app.tabsEntirelyColorized
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Colorize the entire tab and toolbar")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                    }
                }
                onClicked: {
                    chbTabsEntirelyColorized.checked = !chbTabsEntirelyColorized.checked
                }
            }
          }
          Column {
            width: parent.width/2 - 60
            spacing: Units.dp(0)
            Item {
                height: Units.dp(60)
                width: parent.width
                Label {
                    style: "title"
                    text: qsTr("Theme")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItem.Standard  {
                id:primaryChooser
                text: qsTr('Primary Color')
                Rectangle {
                    id: primarycolorSample
                    width:30
                    height:30
                    radius: width*0.5
                    color: primaryColorPicker.color
                    anchors {
                            top: parent.top
                            right: parent.right
                            topMargin:5
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: primaryColorPicker.open(primarycolorSample, Units.dp(4), Units.dp(-4))
                    }
                }
            }

            ListItem.Standard  {
                id:accentChooser
                text: qsTr('Accent Color')
                Rectangle {
                    id: accentcolorSample
                    width:30
                    height:30
                    radius: width*0.5
                    color: accentColorPicker.color
                    anchors {
                            top: parent.top
                            right: parent.right
                            topMargin:5
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: accentColorPicker.open(accentcolorSample, Units.dp(4), Units.dp(-4))
                    }
                }
            }

            ListItem.Standard {
                  text: ""
                  height:60
                  MenuField {
                      id: menuSourceHighlightTheme
                      anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 15
                      }
                      property string selectedSourceHighlightTheme: model[selectedIndex].toLowerCase().replace(" ","_");
                      width: parent.width - 20
                      model: getListedSourceHighlightThemes()
                      helperText: "Syntax-highlighting theme for source-code viewing"

                      function getListedSourceHighlightThemes() {
                        if(root.app.sourceHighlightTheme == "zenburn")
                            return ["Zenburn", "Monokai Sublime", "Solarized Light"]
                        else if(root.sourceHighlightTheme == "solarized_light")
                            return ["Solarized Light", "Monokai Sublime", "Zenburn"]
                        else
                            return ["Monokai Sublime", "Zenburn", "Solarized Light"]
                      }
                  }
                  anchors.bottomMargin: 30
              }

            ColorPicker {
                id: primaryColorPicker
                color: theme.primaryColor
            }

            ColorPicker {
                id: accentColorPicker
                color: theme.accentColor
            }
          }
        }
  }
    View {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        elevation: 2
        height: Units.dp(60)
        Row {
            spacing:10
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: qsTr("Save")
                elevation: 1
                backgroundColor: Theme.accentColor
                onClicked: {
                    theme.primaryColor = primaryColorPicker.color;
                    theme.accentColor = accentColorPicker.color;
                    root.app.homeUrl = txtHomeUrl.text;
                    root.app.searchEngine = menuSearchEngine.selectedEngine;
                    root.app.sourceHighlightTheme = menuSourceHighlightTheme.selectedSourceHighlightTheme;
                    root.app.integratedAddressbars = chbIntegratedAddressbars.checked;
                    root.app.tabsEntirelyColorized = chbTabsEntirelyColorized.checked;
                    root.app.newTabPage = chbDashboard.checked;
                    drawer.close();
                }
            }
            Button {
                text: qsTr("Abort")
                elevation: 1
                onClicked: {
                    accentColorPicker.color = theme.accentColor;
                    primaryColorPicker.color = theme.primaryColor;
                    txtHomeUrl.text = root.app.homeUrl;
                    chbDashboard.checked = root.app.newTabPage;
                    chbIntegratedAddressbars.checked = root.app.integratedAddressbars;
                    chbTabsEntirelyColorized.checked = root.app.tabsEntirelyColorized;
                    drawer.close();
                }
            }
        }
    }

}
