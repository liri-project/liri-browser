import QtQuick 2.0
import Material 0.1


Dropdown {
    id: color_picker
    property color color

    width: Units.dp(300)
    height: Units.dp(196)

    Label {
        id: lbl_title
        style: "dialog"
        font.family: root.font_family
        text: qsTr("Choose a color")
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Units.dp(24)

    }

    Grid {
        columns: 7
        spacing: Units.dp(8)
        id: grid
        anchors.top: lbl_title.bottom
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
                border.width: modelData === "white" ? Units.dp(2) : 0
                border.color: Theme.alpha("#000", 0.26)

                Ink {
                    anchors.fill: parent

                    onPressed: {
                        color_picker.color = parent.color;
                        color_picker.close();
                    }
                }
            }
        }
    }
}
