import QtQuick 2.0
import Material 0.1


Rectangle {
    id: quickSearchesRoot
    anchors.fill: parent
    property bool mobileMode: width < Units.dp(640)
    property color textColor: root.app.darkTheme ? Theme.dark.textColor : Theme.alpha(Theme.light.textColor,1)
    property color linesColor: Theme.alpha(textColor, 0.6)
    color: root.app.darkTheme ? root.app.darkThemeColor : "white"
    z: -20
    View {
        id: view
        height: label.height + Units.dp(30)
        width: parent.width
        Label {
            id: label
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                bottom: parent.bottom
            }
            text:  qsTr("Customize sites colors (if no theme-color)")
            style: "title"
            color: quickSearchesRoot.textColor
            font.pixelSize: Units.dp(30)
        }
    }
    QuickSearchesList {
        anchors.fill: parent
        anchors.topMargin: view.height + Units.dp(10)
        textColor: parent.textColor
        color: parent.color
    }

}
