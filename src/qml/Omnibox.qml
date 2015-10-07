import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

Rectangle {
    id: omnibox

    radius: Units.dp(2)
    color: root.addressBarColor
    opacity: 0.5

    /*
     * Loading progress indicator
     *
     * The outer item provides the actual shape for the progress bar. It is clipped, and has a child rectangle that
     * is slightly bigger. This is so the progress bar is curved where it intersects the corners of the omnibox.
     */
    Item {
        id: progressBar
        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        clip: true
        height: omnibox.radius
        width: 0
        opacity: loading ? 1 : 0

        property bool loading: activeTab.webview.loading
        property bool enableBehavior

        // When loading, we first disable the behavior and reset the width to 0
        // So the progress bar resets and doesn't animate backwards
        onLoadingChanged: {
            if (loading) {
                enableBehavior = false
                width = 0
                enableBehavior = true
                width = Qt.binding(function () { return omnibox.width * activeTab.webview.progress })
            }
        }

        Behavior on width {
            enabled: progressBar.enableBehavior
            SmoothedAnimation {
                reversingMode: SmoothedAnimation.Sync
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Rectangle {
            radius: omnibox.radius

            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            /*
             * Make this wider than the clip rect, so the left edge is rounded to match the ominbox, but the right
             * edge is squared off. We limit the width to the ominbox width, though, so as the progress bar gets to
             * the edge, the clip moves off and the progress bar stops, so we see the right end of the progress bar
             * match the corner of the omnibox
             */
            width: Math.min(parent.width + radius, omnibox.width)
            height: radius * 2
            color: Theme.lightDark(toolbar.color, Theme.accentColor, "white")
        }
    }

    Icon {
        id: connectionTypeIcon

        property bool searchIcon: false
        name: searchIcon ? "action/search" : root.activeTab.webview.secureConnection ? "action/lock" : "social/public"
        color: root.activeTab.webview.secureConnection ? "green" : root.currentIconColor
        onColorChanged: {

        }

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Units.dp(16)
        }
    }

    Label {
        id: quickSearchIndicator
        anchors{
            left: connectionTypeIcon.right
            leftMargin: txtUrl.quickSearch != "" ? Units.dp(16) : 0
            verticalCenter: parent.verticalCenter
        }

        text: txtUrl.quickSearch
        visible: txtUrl.quickSearch != ""
    }

    TextField {
        id: txtUrl
        objectName: "txtUrl"
        anchors {
            left: quickSearchIndicator.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: Units.dp(16)
            rightMargin: Units.dp(16)
        }
        property string quickSearch: ""
        property string quickSearchURL: ""
        showBorder: false
        visible: quickSearch == ""
        text: root.activeTab.webview.url
        placeholderText: mobile ? qsTr("Search") : qsTr("Search or enter website name")
        opacity: 1
        textColor: root.tabTextColorActive
        onTextChanged: isASearchQuery(text) ? connectionTypeIcon.searchIcon = true : connectionTypeIcon.searchIcon = false;
        onAccepted: {
            setActiveTabURL(text)
            quickSearch = ""
            quickSearchURL = ""
        }

        Keys.onTabPressed:{
            if(text.length == 3) {
                var item = getInfosOfQuickSearch(text)
                quickSearch = item.name + ""
                quickSearchURL = item.url + ""
                txtUrlQuickSearches.forceActiveFocus()
            }
        }
        Keys.onBacktabPressed:  {
                quickSearch = "";
                placeholderText = qsTr("Search or enter website name")
        }
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

    TextField {
        id: txtUrlQuickSearches
        anchors {
            left: quickSearchIndicator.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: Units.dp(16)
            rightMargin: Units.dp(16)
        }
        visible: txtUrl.quickSearch != ""
        showBorder: false
        text: ""
        placeholderText: qsTr("Search...")
        opacity: 1
        textColor: root.tabTextColorActive
        onTextChanged: isASearchQuery(text) ? connectionTypeIcon.searchIcon = true : connectionTypeIcon.searchIcon = false;
        onAccepted: {
            if(txtUrl.quickSearch == "" && root.app.quickSearches)
                console.log(1)
            else
                setActiveTabURL(txtUrl.quickSearchURL + text)
            txtUrl.quickSearch = ""
            txtUrl.quickSearchURL = ""
        }

        Keys.onTabPressed:{
            if(text.length == 3) {
                var item = getInfosOfQuickSearch(text)
                txtUrl.quickSearch = item.name + ""
                txtUrl.quickSearchURL = item.url + ""
                txtUrl.placeholderText = qsTr("Search...")
            }
        }
        Keys.onBacktabPressed:  {
                txtUrl.quickSearch = "";
                txtUrl.placeholderText = qsTr("Search or enter website name")
        }

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
