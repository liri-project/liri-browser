import QtQuick 2.4
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls
import "../js/utils.js" as Utils

View {
    id: omnibox

    radius: Units.dp(2)
    backgroundColor: "white"
    elevation: 1
    opacity: 1

    property alias urlField: urlField
    property bool isSearchQuery: Utils.isSearchQuery(urlField.text)

    /*
     * Loading progress indicator
     *
     * The outer item provides the actual shape for the progress bar. It is clipped,
     * and has a child rectangle that is slightly bigger. This is so the progress bar
     * is curved where it intersects the corners of the omnibox.
     */
    Item {
        id: progressBar

        property bool loading: activeTab.view.loading
        property bool enableBehavior

        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        clip: true
        height: omnibox.radius
        width: 0
        opacity: loading ? 1 : 0

        // When loading, we first disable the behavior and reset the width to 0
        // So the progress bar resets and doesn't animate backwards
        onLoadingChanged: {
            if (loading) {
                enableBehavior = false
                width = 0
                enableBehavior = true
                width = Qt.binding(function () {
                    return omnibox.width * activeTab.view.loadProgress
                })
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
             * Make this wider than the clip rect, so the left edge is rounded to match
             * the ominbox, but the right edge is squared off. We limit the width to
             * the ominbox width, though, so as the progress bar gets to the edge, the
             * clip moves off and the progress bar stops, so we see the right end of the
             * progress bar match the corner of the omnibox
             */
            width: Math.min(parent.width + radius, omnibox.width)
            height: radius * 2
            color: Theme.accentColor
        }
    }

    Icon {
        id: connectionTypeIcon

        name: isSearchQuery ? "action/search" : privateBrowsing ? "action/visibility_off" : activeTab.view.secureConnection ? "action/lock" : "social/public"

        color:  name == "action/lock" ? Palette.colors["green"]["500"] : name == "action/visibility_off" ? Palette.colors["purple"]["500"] : Theme.light.iconColor

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Units.dp(16)
        }
    }

    Label {
        id: quickSearchIndicator

        anchors {
            left: connectionTypeIcon.right
            leftMargin: urlField.quickSearch != "" ? Units.dp(16) : 0
            verticalCenter: parent.verticalCenter
        }

        text: urlField.quickSearch
        visible: urlField.quickSearch != ""
    }

    TextField {
        id: urlField
        objectName: "urlField"

        property string quickSearch: ""
        property string quickSearchURL: ""
        property var searchesText
        property bool addingSearch: false

        anchors {
            left: quickSearchIndicator.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: Units.dp(16)
            rightMargin: Units.dp(16)
        }

        showBorder: false
        visible: quickSearch == ""
        text: addingSearch ? searchesText : activeTab.view.url
        placeholderText: isMobile ? qsTr("Search") : qsTr("Search or enter website name")
        textColor: activeTab.textColor

        onTextChanged: {
            // FIXME
            searchSuggestionsModel.clear();
            if(isSearchQuery) {
                // Trigger omniplet plugins
                PluginsEngine.trigger("omnibox.search", text);
            }
        }

        onAccepted: {
            if(isSearchQuery) {
                activeTab.load(searchSuggestionsModel.selectedSuggestion)
            } else {
                activeTab.load(text)
            }

            searchSuggestionsModel.clear()
            searchSuggestionsModel.selectedIndex = 0
            quickSearch = ""
            quickSearchURL = ""
            addingSearch = false
        }

        Keys.onTabPressed: {
            if(text.length == 3) {
                var item = getInfosOfQuickSearch(text)
                quickSearch = item.name + ""
                quickSearchURL = item.url + ""
                urlFieldQuickSearches.forceActiveFocus()
            }
            if(isSearchQuery) {
                // FIXME
                addingSearch = true
                searchesText = searchSuggestionsModel.selectedSuggestion
                searchSuggestionsModel.selectedIndex = 0
            }
        }
        Keys.onBacktabPressed:  {
            quickSearch = "";
            // FIXME
            placeholderText = qsTr("Search or enter website name")
        }
        Keys.onDownPressed: {
            if(searchSuggestionsModel.selectedIndex < searchSuggestionsModel.count - 1)
                searchSuggestionsModel.selectedIndex += 1
        }
        Keys.onUpPressed: {
            if(searchSuggestionsModel.selectedIndex > 0)
                searchSuggestionsModel.selectedIndex -= 1
        }
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onPressed: {
                if (app.platform !== "converged/ubuntu" || !isMobile)
                    mouse.accepted = false;
            }

            onClicked: {
                if (app.platform === "converged/ubuntu" && isMobile)
                    ubuntuOmniboxOverlay.show();
            }
        }
    }

    TextField {
        id: quickSearchesField

        anchors {
            left: quickSearchIndicator.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: Units.dp(16)
            rightMargin: Units.dp(16)
        }

        visible: urlField.quickSearch != ""
        showBorder: false
        placeholderText: qsTr("Search...")
        textColor: root.tabTextColorActive

        onTextChanged: {
            if (isASearchQuery(text))
                connectionTypeIcon.searchIcon = true
            else
                connectionTypeIcon.searchIcon = false
        }

        onAccepted: {
            // FIXME
            if(urlField.quickSearch == "" && root.app.quickSearches)
                console.log(1)
            else
                setActiveTabURL(urlField.quickSearchURL + text)
            urlField.quickSearch = ""
            urlField.quickSearchURL = ""
        }

        Keys.onTabPressed:{
            if(text.length == 3) {
                var item = getInfosOfQuickSearch(text)
                urlField.quickSearch = item.name + ""
                urlField.quickSearchURL = item.url + ""
                urlField.placeholderText = qsTr("Search...")
            }
        }
        Keys.onEscapePressed: {
            Keys.onBacktabPressed(event)
        }
        Keys.onBacktabPressed:  {
            urlField.quickSearch = "";
            // FIXME: Use property binding
            urlField.placeholderText = qsTr("Search or enter website name")
        }
        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) {
                urlField.quickSearch = "";
                // FIXME: Use property binding
                urlField.placeholderText = qsTr("Search or enter website name")
            }
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
