import QtQuick 2.0
import Material 0.1


Dropdown {
    id: color_picker
    property alias color: color_chooser.color
    property alias titel: color_chooser.title

    width: Units.dp(300)
    height: Units.dp(196)

    ColorChooser {
        id: color_chooser
        color_picker: color_picker
        anchors.fill: parent
    }
}
