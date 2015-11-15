import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import QtQuick.Controls.Styles.Material 0.1

Rectangle {
    id: settingsRoot
    anchors.fill: parent
    property bool singleColumnMode: width < Units.dp(640)
    property color textColor: root.app.darkTheme ? Theme.dark.textColor : Theme.alpha(Theme.light.textColor,1)
    property color linesColor: Theme.alpha(textColor, 0.6)
    property int subHeaderLeftMargin: Units.dp(20)
    color: root.app.darkTheme ? root.app.darkThemeColor : "white"
    z: -20
    clip: true


    Flickable {
        id: flickable
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent
        contentHeight: grid.childrenRect.height + Units.dp(48) + viewBottom.height + view.height

        View {
            id: view
            height: label.height + Units.dp(35)
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
          columns: singleColumnMode ? 1 : 2

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
            width: !singleColumnMode ? parent.width/2 - Units.dp(60) : parent.width - Units.dp(60)
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
                    anchors {
                      verticalCenter: parent.verticalCenter
                      left: parent.left
                      leftMargin: 15
                    }
                    text: root.app.homeUrl
                    placeholderText: qsTr("Start page")
                    floatingLabel: true
                    style: TextFieldThemed {
                        helperNotFocusedColor: settingsRoot.linesColor
                        textColor: settingsRoot.textColor
                    }
                }
            }

            ListItem.Standard {
                text: ""
                height: Units.dp(60)
                MenuFieldThemed {
                    id: menuSearchEngine
                    textColor: settingsRoot.textColor
                    helperColor: Theme.accentColor
                    linesColor: settingsRoot.linesColor
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

            ListItem.SectionHeader {
                text: qsTr("Window")
                id: winHead
                expanded: false
            }

            ListItem.Standard {
                visible: winHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbCustomFrame
                        darkBackground: root.app.darkTheme
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

            ListItem.SectionHeader {
                text: qsTr("Dash")
                id: dashHead
                expanded: false
            }

            ListItem.Standard {
                visible: !root.mobile && dashHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbDashboard
                        darkBackground: root.app.darkTheme
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

            ListItem.SectionHeader {
                text: qsTr("Toolbar")
                id: toolHead
                expanded: false
            }

            ListItem.Standard {
                visible: !root.mobile && toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbIntegratedAddressbars
                        darkBackground: root.app.darkTheme
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
                visible: toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbUppercaseTabTitle
                        darkBackground: root.app.darkTheme
                        checked: root.app.uppercaseTabTitle
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Uppercase tabs titles")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                        color: settingsRoot.textColor
                    }
                }
                onClicked: {
                    chbUppercaseTabTitle.checked = !chbUppercaseTabTitle.checked
                }
            }

            ListItem.Standard {
                visible: !root.mobile && toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbAllowReducingTabsSizes
                        darkBackground: root.app.darkTheme
                        checked: root.app.allowReducingTabsSizes
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Responsive tabs (EXPERIMENTAL)")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                        color: settingsRoot.textColor
                    }
                }
                onClicked: {
                    chbAllowReducingTabsSizes.checked = !chbAllowReducingTabsSizes.checked
                }
            }

            ListItem.Standard {
                visible: toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbTabsEntirelyColorized
                        darkBackground: root.app.darkTheme
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
                visible: toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)

                    CheckBox {
                        id: chbCustomSitesColors
                        darkBackground: root.app.darkTheme
                        checked: root.app.customSitesColors
                        anchors.verticalCenter: parent.verticalCenter

                    }
                    Label {
                        text: qsTr("Use custom sites colors")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                        color: settingsRoot.textColor
                    }
                    Button {
                        text: "Sites Color chooser"
                        elevation: 1
                        anchors {
                          verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            addTab("liri://settings/sites-colors")
                        }
                    }

                }
                onClicked: {
                    chbCustomSitesColors.checked = !chbCustomSitesColors.checked
                }
            }

            ListItem.Standard {
                visible: toolHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Row {
                    anchors.fill: parent
                    spacing: Units.dp(12)
                    CheckBox {
                        id: chbQuickSearches
                        darkBackground: root.app.darkTheme
                        checked: root.app.customSitesColors
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Use Quick Searches in Omnibox")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Units.dp(16)
                        color: settingsRoot.textColor
                    }
                    Button {
                        text: "Quick Searches Editor"
                        elevation: 1
                        anchors {
                          verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            addTab("liri://settings/quick-searches")
                        }
                    }

                }
                onClicked: {
                    chbQuickSearches.checked = !chbQuickSearches.checked
                }
            }

            ListItem.Standard  {
                id:bookmarksBarToogle
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                visible: toolHead.expanded
                text: qsTr('Bookmarks bar')
                textColor: settingsRoot.textColor
                Switch {
                    id: swBookmarksBar
                    checked: root.app.bookmarksBar
                    darkBackground: root.app.darkTheme
                    anchors {
                            top: parent.top
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                    }
                }
                onClicked: {
                    swBookmarksBar.checked = !swBookmarksBar.checked
                }
            }
            ListItem.Standard {
                id: bookmarksBarOptions
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                visible: swBookmarksBar.checked && toolHead.expanded
                height: 120
                anchors{
                    left: parent.left
                    margins: 20
                }
                ExclusiveGroup { id: bookmarksOptionGroup }
                Column {
                    spacing: -Units.dp(10)
                    RadioButton {
                        id: rdBookmarksBarAlwaysOn
                        checked: root.app.bookmarksBarAlwaysOn
                        text: "Always on"
                        canToggle: true
                        anchors{
                            left: -Units.dp(4)
                        }

                        darkBackground: root.app.darkTheme
                        exclusiveGroup: bookmarksOptionGroup
                        style: RadioButtonStyle {
                            label: Label {
                                    text: control.text
                                    style: "button"
                                    color: rdBookmarksBarAlwaysOn.checked ? settingsRoot.textColor : settingsRoot.linesColor
                                 }
                        }
                    }

                    RadioButton {
                        id: rdBookmarksBarOnlyOnDash
                        text: "Only on dashboard"
                        checked: root.app.bookmarksBarOnlyOnDash
                        canToggle: true
                        exclusiveGroup: bookmarksOptionGroup
                        style: RadioButtonStyle {
                            label: Label {
                                    text: control.text
                                    style: "button"
                                    color: rdBookmarksBarOnlyOnDash.checked ? settingsRoot.textColor : settingsRoot.linesColor
                                   }
                        }
                        darkBackground: root.app.darkTheme
                    }

                    RadioButton {
                        id: rdBookmarksBarNotOnDash
                        text: "Everywhere except on dashboard"
                        checked: !root.app.bookmarksBarOnlyOnDash && !root.app.bookmarksBarAlwaysOn
                        canToggle: true
                        exclusiveGroup: bookmarksOptionGroup
                        style: RadioButtonStyle {
                            label: Label {
                                    text: control.text
                                    style: "button"
                                    color:  rdBookmarksBarNotOnDash.checked ? settingsRoot.textColor : settingsRoot.linesColor

                            }
                        }
                        darkBackground: root.app.darkTheme
                    }
                }
            }

          }

          Column {
            id: colTheme
            width: !singleColumnMode ? parent.width/2 - Units.dp(60) : parent.width - Units.dp(60)
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

            ListItem.SectionHeader {
                text: qsTr("Colors")
                id: colorsHead
                expanded: false
            }

            ListItem.Standard {
                id:darkToogle
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                visible: colorsHead.expanded
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
                onClicked: {
                    swDarkTheme.checked = !swDarkTheme.checked
                }
            }
            ListItem.Standard {
                id: darkThemeOptions
                visible: swDarkTheme.checked && colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                height: 80
                anchors{
                    left: parent.left
                    margins: 20
                }
                ExclusiveGroup { id: optionGroup }
                Column {
                    spacing: -Units.dp(10)
                    RadioButton {
                        id: rdDarkThemeAlwaysOn
                        checked: true
                        text: "Always on"
                        darkBackground: root.app.darkTheme
                        canToggle: true
                        exclusiveGroup: optionGroup
                        style: RadioButtonStyle {
                            label: Label {
                                    text: control.text
                                    style: "button"
                                    color: rdDarkThemeAlwaysOn.checked ? settingsRoot.textColor : settingsRoot.linesColor
                            }
                        }
                    }

                    RadioButton {
                        id: rdDarkThemeOnAtNight
                        text: "Only on between 7pm and 7am"
                        darkBackground: root.app.darkTheme
                        canToggle: true
                        exclusiveGroup: optionGroup
                        style: RadioButtonStyle {
                            label: Label {
                                    text: control.text
                                    style: "button"
                                    color: rdDarkThemeOnAtNight.checked ? settingsRoot.textColor : settingsRoot.linesColor
                             }
                        }
                    }
                }
            }

            ListItem.Standard  {
                id:primaryChooser
                text: qsTr('Primary Color')
                textColor: settingsRoot.textColor
                visible:  colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
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
                visible:  colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
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

            ListItem.Standard  {
                id:lightChooser
                text: qsTr('Light Theme Color')
                textColor: settingsRoot.textColor
                visible:  colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Rectangle {
                    id: lightColorSample
                    width: Units.dp(30)
                    height: width
                    radius: width*0.5
                    color: lightColorPicker.color
                    anchors {
                            top: parent.top
                            right: parent.right
                            topMargin:5
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: lightColorPicker.open(lightColorSample, Units.dp(4), Units.dp(-4))
                    }
                }
            }

            ListItem.Standard  {
                id: darkChooser
                text: qsTr('Dark Theme Color')
                textColor: settingsRoot.textColor
                visible:  colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Rectangle {
                    id: darkColorSample
                    width: Units.dp(30)
                    height: width
                    radius: width*0.5
                    color: darkColorPicker.color
                    anchors {
                            top: parent.top
                            right: parent.right
                            topMargin:5
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: darkColorPicker.open(darkColorSample, Units.dp(4), Units.dp(-4))
                    }
                }
            }

            ListItem.Standard  {
                id:privateChooser
                text: qsTr('Private Nav Color')
                textColor: settingsRoot.textColor
                visible:  colorsHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                Rectangle {
                    id: privateColorSample
                    width: Units.dp(30)
                    height: width
                    radius: width*0.5
                    color: privateColorPicker.color
                    anchors {
                            top: parent.top
                            right: parent.right
                            topMargin:5
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: privateColorPicker.open(privateColorSample, Units.dp(4), Units.dp(-4))
                    }
                }
            }

            ListItem.SectionHeader {
                text: qsTr("SourceViewer settings")
                id: srcHead
                expanded: false
            }

            ListItem.Standard {
                  id: srcListItem
                  visible: srcHead.expanded
                  width: parent.width - settingsRoot.subHeaderLeftMargin
                  anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                  text: ""
                  height: Units.dp(60)

                  MenuFieldThemed {
                      id: menuSourceHighlightTheme
                      textColor: settingsRoot.textColor
                      helperColor: Theme.accentColor
                      linesColor: settingsRoot.linesColor
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

            ListItem.Standard {
                  id: srcFontItem
                  visible: srcHead.expanded
                  width: parent.width - settingsRoot.subHeaderLeftMargin
                  anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                  text: ""
                  height: Units.dp(60)
                  MenuFieldThemed {
                      id: menuSourceHighlightFont
                      textColor: settingsRoot.textColor
                      helperColor: Theme.accentColor
                      linesColor: settingsRoot.linesColor
                      anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 15
                      }
                      property string selectedSourceHighlightFont: model[selectedIndex];
                      width: parent.width - 20
                      model: getListedSourceHighlightFonts()
                      helperText: "Font for source-code viewing"

                      function getListedSourceHighlightFonts() {
                        if(root.app.sourceHighlightFont == "Roboto Mono")
                            return ["Roboto Mono", "Hack"]
                        else
                            return ["Hack", "Roboto Mono"]
                      }
                  }
              }

            ListItem.Standard {
                text: "Source code font size : " + slSourceHighlightFontSizePixel.value + "px"
                height: Units.dp(60)
                visible: srcHead.expanded
                width: parent.width - settingsRoot.subHeaderLeftMargin
                anchors.leftMargin: settingsRoot.subHeaderLeftMargin
                textColor: settingsRoot.textColor
                Slider {
                    id: slSourceHighlightFontSizePixel
                    value: root.app.sourceHighlightFontPixelSize
                    tickmarksEnabled: true
                    stepSize: 1
                    minimumValue: 8
                    maximumValue: 18
                    darkBackground: root.app.darkTheme
                    anchors {
                        right: parent.right
                        top: parent.top
                        topMargin: 20
                        verticalCenter: parent.verticalCenter
                    }
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

            ColorPicker {
                id: lightColorPicker
                light: true
                color: root.app.lightThemeColor
            }

            ColorPicker {
                id: darkColorPicker
                dark: true
                color: root.app.darkThemeColor
            }

            ColorPicker {
                id: privateColorPicker
                dark: true
                color: root.app.privateNavColor
            }
          }
       }
    }
    ScrollbarThemed {
        flickableItem: flickable
        color: settingsRoot.textColor
        hideTime: 1000
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
                    root.app.lightThemeColor = lightColorPicker.color;
                    root.app.darkThemeColor = darkColorPicker.color;
                    root.app.privateNavColor = privateColorPicker.color;
                    root.app.homeUrl = txtHomeUrl.text;
                    root.app.searchEngine = menuSearchEngine.selectedEngine;
                    root.app.sourceHighlightTheme = menuSourceHighlightTheme.selectedSourceHighlightTheme;
                    root.app.sourceHighlightFont = menuSourceHighlightFont.selectedSourceHighlightFont;
                    root.app.sourceHighlightFontPixelSize = slSourceHighlightFontSizePixel.value
                    root.app.integratedAddressbars = chbIntegratedAddressbars.checked;
                    root.app.tabsEntirelyColorized = chbTabsEntirelyColorized.checked;
                    root.app.newTabPage = chbDashboard.checked;
                    root.app.customFrame = chbCustomFrame.checked;
                    root.app.darkTheme = rdDarkThemeAlwaysOn.checked ? swDarkTheme.checked : root.app.isNight
                    root.app.customSitesColors = chbCustomSitesColors.checked
                    root.app.bookmarksBar = swBookmarksBar.checked
                    root.app.bookmarksBarAlwaysOn = rdBookmarksBarAlwaysOn.checked
                    root.app.bookmarksBarOnlyOnDash = rdBookmarksBarOnlyOnDash.checked
                    root.app.allowReducingTabsSizes = chbAllowReducingTabsSizes.checked
                    root.app.quickSearches = chbQuickSearches.checked
                    root.app.uppercaseTabTitle = chbUppercaseTabTitle.checked
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
                    chbDashboard.checked = root.app.newTabPage
                    chbCustomFrame.checked = root.app.customFrame
                    rdBookmarksBarAlwaysOn.checked = rdBookmarksBarAlwaysOn.checked
                    swBookmarksBar.checked = root.app.bookmarksBar
                    rdBookmarksBarOnlyOnDash.checked = root.app.bookmarksBarOnlyOnDash
                    chbAllowReducingTabsSizes.checked = root.app.allowReducingTabsSizes
                    chbQuickSearches.checked = root.app.quickSearches
                    chbUppercaseTabTitle.checked = root.app.uppercaseTabTitle
                    chbCustomSitesColors.checked = root.app.customSitesColors
                    privateColorPicker.color = root.app.privateNavColor;
                    lightColorPicker.color = root.app.lightThemeColor;
                    darkColorPicker.color = root.app.darkThemeColor;
                }
            }
        }
        Label {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                margins: Units.dp(10)
            }
            text: qsTr("Version: 0.3")
            color: settingsRoot.textColor
        }
    }

}
