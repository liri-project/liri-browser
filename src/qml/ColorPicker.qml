import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem


Dropdown {
    id: colorPicker
    property alias color: colorChooser.color
    property alias titel: colorChooser.title
    property alias dark: colorChooser.dark
    property alias light: colorChooser.light

    width: Units.dp(300)
    height: Units.dp(250)

    Column {
        id: column
        width: parent.width

        ColorChooser {
            id: colorChooser
            colorPicker: colorPicker
            width: parent.width
            height: Units.dp(196)
        }

        ListItem.Standard {
            width: parent.width
            TextField {
                placeholderText: qsTr("Custom color: (hit enter when finished)")
                id: customColor
                floatingLabel: true
                text: "#F0F0F0"
                width: parent.width - 30
                anchors {
                  verticalCenter: parent.verticalCenter
                  left: parent.left
                  leftMargin: 15
                }
                font.pixelSize: Units.dp(16)
                enabled: chbCustomColor.checked
                onAccepted: {
                    colorChooser.color = text
                    colorPicker.close()
                }
            }
        }
   }
}
