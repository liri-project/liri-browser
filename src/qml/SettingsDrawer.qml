import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem


NavigationDrawer {
    id:drawer
    z:25
    mode: "right"
    width:Units.dp(350)
    dismissOnTap: true

    Column {
        width: parent.width
        spacing: Units.dp(0)
        View {
            id: view
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
                text:  qsTr("Settings")
                style: "title"
                font.pixelSize: Units.dp(30)
            }
        }

        Item {
                height: Units.dp(48)
                width: parent.width
                Label {
                    style: "title"
                    text: qsTr("General")
                    anchors.centerIn: parent
                }
            }

        ListItem.Standard {
            text: ""
            height:60
            TextField {
                id: txtHomeUrl
                width: parent.width * 0.9
                text: root.app.homeUrl
                placeholderText: qsTr("Start page")
                floatingLabel: true
                anchors.centerIn: parent
            }
        }

    	ListItem.Standard {
            text: ""
            height:60
      	    MenuField {
                id: menuSearchEngine
                property string selectedEngine: model[selectedIndex].toLowerCase();
                width: parent.width * 0.9
                model: getListedSearchEngines()
                helperText: "Search Engine"
                anchors.centerIn: parent

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
            height: Units.dp(48)
            width: parent.width
            Label {
                style: "title"
                text: qsTr("Appearance")
                anchors.centerIn: parent
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

        Item {
            height: Units.dp(48)
            width: parent.width
            Label {
                style: "title"
                text: qsTr("Theme")
                anchors.centerIn: parent
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
                        rightMargin:20
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
                        rightMargin:20
                        topMargin:5
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: accentColorPicker.open(accentcolorSample, Units.dp(4), Units.dp(-4))
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

    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Units.dp(16)
        }
        height: Units.dp(50)
        Row {
            spacing:10
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
