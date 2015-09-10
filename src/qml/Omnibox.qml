import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    radius: Units.dp(2)
    color: root.addressBarColor
    opacity: 0.5

    property alias iconConnectionType: connectionTypeIcon

    Icon {
        id: connectionTypeIcon

        name: root.activeTab.webview.secureConnection ? "action/lock" : "social/public"
        color: root.activeTab.webview.secureConnection ? "green" : root.currentIconColor

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Units.dp(16)
        }
    }

    TextField {
        id: txtUrl

        anchors {
            left: connectionTypeIcon.right
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Units.dp(16)
            rightMargin: Units.dp(16)
        }

        showBorder: false
        text: root.activeTab.webview.url
        placeholderText: qsTr("Search or enter website name")
        opacity: 1
        textColor: root.tabTextColorActive
        onTextChanged: isASearchQuery(text) ? connectionTypeIcon.name = "action/search" : connectionTypeIcon.name = "social/public"
        onAccepted: setActiveTabURL(text)
    }
}
