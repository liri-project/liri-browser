import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1

Rectangle {
    id: settingsRoot
    anchors.fill: parent
    property bool mobileMode: width < Units.dp(640)
    property string textColor: root.app.darkTheme ? Theme.dark.textColor : Theme.light.textColor
    color: root.app.darkTheme ? root.app.darkThemeColor : "white"

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: grid.childrenRect.height + Units.dp(48) + viewBottom.height + view.height

        View {
            id: view
            height: label.height + Units.dp(30)
            width: parent.width
            Label {
                id: label
                anchors {
                    left: parent.left
                    leftMargin: 30
                    right: parent.right
                    bottom: parent.bottom
                }
                text:  qsTr("Settings")
                style: "title"
                color: settingsRoot.textColor
                font.pixelSize: Units.dp(30)
            }
        }

        Grid {
          id: grid
          columns: mobileMode ? 1 : 2

          width: parent.width
          anchors {
            left: parent.left
            top: parent.top
            topMargin: view.height + 10
            leftMargin: 30
          }
          spacing:30


          Column {
            id: colSettings
            width: !mobileMode ? parent.width/2 - Units.dp(60) : parent.width - Units.dp(60)
            spacing: Units.dp(0)

            Item {
              height: Units.dp(60)
              width: parent.width
              Label {
                  style: "title"
                  color: settingsRoot.textColor
                  text: qsTr("General")
                  anchors.verticalCenter: parent.verticalCenter
              }
            }

            ListItem.Standard {
                text: ""
                height: Units.dp(60)
                TextField {
                    id: txtHomeUrl
                    width: parent.width - 30
                    height: Units.dp(36)
                    color: settingsRoot.textColor
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
                height: Units.dp(60)
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
                          return ["DuckDuckGo", "Google", "Yahoo", "Bing"]
                      else if(root.app.searchEngine == "bing")
                          return ["Bing", "Google", "Yahoo", "DuckDuckGo"]
                      else if(root.app.searchEngine == "yahoo")
                          return ["Yahoo", "Google", "DuckDuckGo", "Bing"]
                      else
                          return ["Google", "DuckDuckGo", "Yahoo", "Bing"]
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
                    color: settingsRoot.textColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItem.Standard {
                visible: !root.mobile
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
                        color: settingsRoot.textColor
                    }
                }
                onClicked: {
                    chbDashboard.checked = !chbDashboard.checked
                }
            }

            ListItem.Standard {
                visible: !root.mobile
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
                        color: settingsRoot.textColor
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
                        color: settingsRoot.textColor
                    }
                }
                onClicked: {
                    chbTabsEntirelyColorized.checked = !chbTabsEntirelyColorized.checked
                }
            }

            ListItem.Standard {
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbCustomFrame
                        checked: root.app.customFrame
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Material window frame (EXPERIMENTAL)")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                        color: settingsRoot.textColor
                    }
                }
                onClicked: {
                    chbCustomFrame.checked = !chbCustomFrame.checked
                }
            }

          }

          Column {
            id: colTheme
            width: !mobileMode ? parent.width/2 - Units.dp(60) : parent.width - Units.dp(60)
            spacing: Units.dp(0)
            Item {
                height: Units.dp(60)
                width: parent.width
                Label {
                    style: "title"
                    text: qsTr("Theme")
                    color: settingsRoot.textColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItem.Standard  {
                id:darkToogle
                text: qsTr('Dark theme')
                textColor: settingsRoot.textColor
                Switch {
                    id: swDarkTheme
                    checked: root.app.darkTheme
                    darkBackground: root.app.darkTheme
                    anchors {
                            top: parent.top
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                    }
                }
            }
            ListItem.Standard {
                id: darkThemeOptions
                visible: swDarkTheme.checked
                height: 80
                anchors{
                    left: parent.left
                    margins: 20
                }
                ExclusiveGroup { id: optionGroup }
                Column {
                    spacing: 0
                    RadioButton {
                        id: rdDarkThemeAlwaysOn
                        checked: true
                        text: "Always on"
                        darkBackground: root.app.darkTheme
                        canToggle: true
                        exclusiveGroup: optionGroup
                    }

                    RadioButton {
                        id: rdDarkThemeOnAtNight
                        text: "Only on between 7pm and 7am"
                        darkBackground: root.app.darkTheme
                        canToggle: true
                        exclusiveGroup: optionGroup
                    }
                }
            }

            ListItem.Standard  {
                id:primaryChooser
                text: qsTr('Primary Color')
                textColor: settingsRoot.textColor
                Rectangle {
                    id: primarycolorSample
                    width: Units.dp(30)
                    height: width
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
                textColor: settingsRoot.textColor
                Rectangle {
                    id: accentcolorSample
                    width: Units.dp(30)
                    height: width
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
                  id: srcListItem
                  text: ""
                  height: Units.dp(60)
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

              ListItem.Standard  {
                  id: buttonSitesColor
                  height: Units.dp(60)
                  Button {
                      text: "Sites Color chooser"
                      elevation: 1
                      anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 15
                      }
                      onClicked: pageStack.push(sitesColorPage)
                  }
              }

            ColorPicker {
                id: primaryColorPicker
                color: theme.primaryColor
            }

            ColorPicker {
                id: accentColorPicker
                color: theme.accentColor
            }

            Item {
                height: Units.dp(60)
                width: parent.width
                Label {
                    style: "title"
                    text: qsTr("About")
                    anchors.verticalCenter: parent.verticalCenter
                    color: settingsRoot.textColor
                }
            }

            ListItem.Subheader {
                Label {
                    z: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Current Browser Version: 0.3")
                    color: settingsRoot.textColor
                }
            }
          }
       }
    }

    View {
        id: viewBottom
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        elevation: 2
        height: Units.dp(60)
        backgroundColor: root.app.darkTheme ? shadeColor(root.app.darkThemeColor, 0.05) : "white"
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
                    root.app.customFrame = chbCustomFrame.checked;
                    root.app.darkTheme = rdDarkThemeAlwaysOn.checked ? swDarkTheme.checked : root.app.isNight
                    drawer.close();
                }
            }
            Button {
                text: qsTr("Reset")
                elevation: 1
                onClicked: {
                    accentColorPicker.color = theme.accentColor;
                    primaryColorPicker.color = theme.primaryColor;
                    txtHomeUrl.text = root.app.homeUrl;
                    chbDashboard.checked = root.app.newTabPage;
                    chbIntegratedAddressbars.checked = root.app.integratedAddressbars;
                    chbTabsEntirelyColorized.checked = root.app.tabsEntirelyColorized;
                    chbCustomFrame.checked = root.app.customFrame;
                    drawer.close();
                }
            }
        }
    }

}
