import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

RowLayout {
    spacing: Units.dp(10)
    anchors {
        right: parent.right
        rightMargin:spacing
        verticalCenter: parent.verticalCenter
    }
    property string iconsColor: root.app.darkTheme ? shadeColor(root.app.darkThemeColor, 0.5) : Theme.lightDark(parent.color, Theme.light.iconColor, Theme.dark.iconColor)
    signal showMinimized;
    signal showMaximized;
    signal showFullScreen;
    signal showNormal;
    signal close;

    IconButton {
        iconName: "navigation/expand_more"
        width: Units.dp(20)
        height: width
        color: parent.iconsColor
        onClicked: showMinimized()
    }

    IconButton {
        iconName: root.visibility == 4 ? "navigation/fullscreen_exit" : "navigation/fullscreen"
        width: Units.dp(20)
        id: sysbtn_max
        height: width
        color: parent.iconsColor
        onClicked: {
            if(root.visibility == 2)
                showMaximized();
            else
                showNormal();
        }
    }

    IconButton {
        iconName: "navigation/close"
        width: Units.dp(20)
        height: width
        color: parent.iconsColor
        onClicked: close()
    }
}
