import QtQuick 2.0
import Material 0.1


Dropdown {
    id: colorPicker
    property alias color: colorChooser.color
    property alias titel: colorChooser.title
    property alias dark: colorChooser.dark
    property alias light: colorChooser.light

    width: Units.dp(300)
    height: Units.dp(196)

    ColorChooser {
        id: colorChooser
        colorPicker: colorPicker
        anchors.fill: parent
    }
}
