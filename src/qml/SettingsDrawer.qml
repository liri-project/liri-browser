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
                id: txt_home_url
                width: parent.width * 0.9
                text: root.app.home_url
                placeholderText: qsTr("Start page")
                floatingLabel: true
                anchors.centerIn: parent
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
                    id: chb_dashboard
                    checked: root.app.new_tab_page
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    text: qsTr("Enable dashboard")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Units.dp(16)
                }
            }
            onClicked: {
                chb_dashboard.checked = !chb_dashboard.checked
            }
        }

        ListItem.Standard {
            Row {
                anchors.fill: parent
                spacing: Units.dp(12)
                CheckBox {
                    id: chb_integrated_addressbars
                    checked: root.app.integrated_addressbars
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    text: qsTr("Integrated addressbars")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Units.dp(16)
                }
            }
            onClicked: {
                chb_integrated_addressbars.checked = !chb_integrated_addressbars.checked
            }
        }

        ListItem.Standard {
            Row {
                anchors.fill: parent
                spacing: Units.dp(12)
                CheckBox {
                    id: chb_tabs_entirely_colorized
                    checked: root.app.tabs_entirely_colorized
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    text: qsTr("Colorize the entire tab and toolbar")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Units.dp(16)
                }
            }
            onClicked: {
                chb_tabs_entirely_colorized.checked = !chb_tabs_entirely_colorized.checked
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
            id:primary_chooser
            text: qsTr('Primary Color')
            Rectangle {
                id: primarycolor_sample
                width:30
                height:30
                radius: width*0.5
                color: primary_color_picker.color
                anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin:20
                        topMargin:5
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: primary_color_picker.open(primarycolor_sample, Units.dp(4), Units.dp(-4))
                }
            }
        }

        ListItem.Standard  {
            id:accent_chooser
            text: qsTr('Accent Color')
            Rectangle {
                id: accentcolor_sample
                width:30
                height:30
                radius: width*0.5
                color: accent_color_picker.color
                anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin:20
                        topMargin:5
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: accent_color_picker.open(accentcolor_sample, Units.dp(4), Units.dp(-4))
                }
            }
        }

        ColorPicker {
            id: primary_color_picker
            color: theme.primaryColor
        }

        ColorPicker {
            id: accent_color_picker
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
                    theme.primaryColor = primary_color_picker.color;
                    theme.accentColor = accent_color_picker.color;
                    root.app.home_url = txt_home_url.text;
                    root.app.integrated_addressbars = chb_integrated_addressbars.checked;
                    root.app.tabs_entirely_colorized = chb_tabs_entirely_colorized.checked;
                    root.app.new_tab_page = chb_dashboard.checked;
                    var tabs = root.get_tab_manager().open_tabs;
                    for (var i=0; i<tabs.length; i++) {
                        var tab = tabs[i];
                        tab.update_colors();
                    }
                    drawer.close();
                }
            }
            Button {
                text: qsTr("Abort")
                elevation: 1
                onClicked: {
                    accent_color_picker.color = theme.accentColor;
                    primary_color_picker.color = theme.primaryColor;
                    txt_home_url.text = root.app.home_url;
                    chb_dashboard.checked = root.app.new_tab_page;
                    chb_integrated_addressbars.checked = root.app.integrated_addressbars;
                    chb_tabs_entirely_colorized.checked = root.app.tabs_entirely_colorized;
                    drawer.close();
                }
            }
        }
    }
}
