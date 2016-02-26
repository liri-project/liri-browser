import QtQuick 2.4
import QtQuick.Layouts 1.0
import Material 0.1
import "../components"

Item {
    property bool hasFavIcon: icon.status == Image.Ready
    property bool iconIsImage: typeof(tab.view.icon) !== 'string'
    property bool canCloseTab: true

    height: parent.height
    width: row.width + Units.dp(16)

    RowLayout {
        id: row
        anchors.centerIn: parent

        spacing: Units.dp(8)

        Image {
            id: icon
            visible: hasFavIcon && !tab.view.loading && iconIsImage
            width: view.loading ?  0 : Units.dp(20)
            height: Units.dp(20)
            source: tab.view.icon
        }

        Icon {
            id: iconNoFavicon
            color: tab.iconColor
            name: "social/public"
            visible: !hasFavIcon && !tab.view.loading && iconIsImage

            Behavior on color { ColorAnimation { duration : 500 }}
        }

        Icon {
            color: tab.iconColor
            visible: !iconIsImage && !tab.view.loading
            name: modelData.view.icon

            Behavior on color { ColorAnimation { duration : 500 }}
        }

        LoadingIndicator {
            id: prgLoading
            visible: tab.view.loading
            width: visible ? Units.dp(24) : 0
            height: Units.dp(24)
        }

        Text {
            id: title

            Layout.fillWidth: true

            text: styles.uppercaseTabTitle ? modelData.view.title.toUpperCase()
                                           : modelData.view.title
            color: tab.textColor
            elide: Text.ElideRight
            smooth: true
            font.family: root.fontFamily
            visible: !styles.reduceTabsSizes

            Behavior on color { ColorAnimation { duration : 500 }}
        }

        IconButton {
            id: closeButton

            color: tab.iconColor
            Behavior on color { ColorAnimation { duration : 500 }}
            anchors.verticalCenter: parent.verticalCenter
            visible: canCloseTab
                    ? styles.reduceTabsSizes ? isTabActive :  true
                    : false

            iconName: "navigation/close"
            onClicked: {
                tabsModel.removeTab(tab);
            }
        }
    }

    Rectangle {
        id: rectIndicator
        color: tab.highlightColor
        visible: tab == activeTab
        height: Units.dp(2)
        width: parent.width
        anchors.bottom: parent.bottom
    }
}
