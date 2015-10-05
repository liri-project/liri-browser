import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id:_back
    width:_row.implicitWidth
    height: tabsModel.count == 1 ? _row.implicitHeight: Units.dp(38)
    signal showMinimized;
    signal showMaximized;
    signal showFullScreen;
    signal showNormal;
    signal close;

    RowLayout {
        id: _row
        anchors{
            right: parent.right
            top: parent.top
            rightMargin: Units.dp(5)
            topMargin: tabsModel.count == 1 ? Units.dp(4) : Units.dp(8)
        }

        spacing: Units.dp(10)
        property string iconsColor: root.iconColorOnCurrentTabDarken

        Rectangle {
            width:1
            color: "transparent"
        }
        IconButton {
            iconName: "navigation/expand_more"
            width: Units.dp(20)
            height: width
            color: parent.iconsColor
            onClicked: _back.showMinimized()
        }

        IconButton {
            iconName: root.visibility == 4 ? "navigation/fullscreen_exit" : "navigation/fullscreen"
            width: Units.dp(20)
            id: sysbtn_max
            height: width
            color: parent.iconsColor
            onClicked: {
                if(root.visibility == 2)
                    _back.showMaximized();
                else
                    _back.showNormal();
            }
        }

        IconButton {
            iconName: "navigation/close"
            width: Units.dp(20)
            height: width
            color: parent.iconsColor
            onClicked: _back.close()
        }
    }
}
