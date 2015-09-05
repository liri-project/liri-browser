import QtQuick 2.0
import Material 0.1


Item {
    id: colorChooser
    property color color
    property string title
    property Item colorPicker

    width: Units.dp(300)
    height: Units.dp(196)

    Label {
        id: lblTitle
        style: "dialog"
        font.family: root.fontFamily
        text: title || qsTr("Choose a color")
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Units.dp(24)

    }

    Grid {
        columns: 7
        spacing: Units.dp(8)
        id: grid
        anchors.top: lblTitle.bottom
        anchors.topMargin: Units.dp(24)
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: [
                "red", "pink", "purple", "deepPurple", "indigo",
                "blue", "lightBlue", "cyan", "teal", "green",
                "lightGreen", "lime", "yellow", "amber", "orange",
                "deepOrange", "grey", "blueGrey", "brown", "black",
                "white"
            ]

            Rectangle {
                width: Units.dp(30)
                height: Units.dp(30)
                radius: Units.dp(2)
                color: Palette.colors[modelData]["500"]
                border.width: if (color === colorChooser.color) { Units.dp(2) } else { 0 }
                border.color: Theme.alpha("#000", 0.26)

                Ink {
                    anchors.fill: parent

                    onPressed: {
                        colorChooser.color = parent.color;
                        if (colorPicker) colorPicker.close();
                    }
                }
            }
        }
    }
}
