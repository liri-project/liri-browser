import Material 0.1
import QtQuick 2.2

Rectangle {

    anchors {
        top: parent.top;
        left: parent.left;
        right: parent.right;
        margins: 0
        bottomMargin: 0
    }

    height: tabsModel.count > 1 || root.app.integratedAddressbars ? root.tabHeight : Units.dp(30)
    property color chosenColor: root.activeTab.view.customColor ? root.activeTab.view.customColor : root.app.lightThemeColor
    color: root.app.elevatedToolbar ? shadeColor(chosenColor,-0.1) : "transparent"
}
