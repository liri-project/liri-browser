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

    height: tabsModel.count > 1 || root.app.integratedAddressbars ? Units.dp(50) : Units.dp(30);
    color:  root.app.darkTheme ? shadeColor(root.app.darkThemeColor, -0.1) : activeTab.customColor ? shadeColor(activeTab.customColor, -0.1) : "#EFEFEF"
}
