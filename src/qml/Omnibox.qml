import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    radius: Units.dp(2)
    color: root.addressBarColor
    opacity: 0.5

    Icon {
        id: connectionTypeIcon

        property bool searchIcon: false
        name: searchIcon ? "action/search" : root.activeTab.webview.secureConnection ? "action/lock" : "social/public"
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
        placeholderText: mobile ? qsTr("Search") : qsTr("Search or enter website name")
        opacity: 1
        textColor: root.tabTextColorActive
        onTextChanged: isASearchQuery(text) ? connectionTypeIcon.searchIcon = true : connectionTypeIcon.searchIcon = false;
        onAccepted: setActiveTabURL(text)


        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onPressed: {
                if (root.app.platform !== "converged/ubuntu" || !root.mobile)
                    mouse.accepted = false;
            }

            onClicked: {
                if (root.app.platform === "converged/ubuntu" && root.mobile)
                    ubuntuOmniboxOverlay.show();
            }
        }

    }

}
