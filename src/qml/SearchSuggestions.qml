import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls
import Material.Extras 0.1


View {
    visible: searchSuggestionsView.count > 0
    width: toolbar.omnibox.width
    height: Units.dp(300)
    anchors {
        topMargin: bookmarksBar.visible ? -bookmarksBar.height : 0
        top: titlebar.bottom
        left: parent.left
        leftMargin: Units.dp(24) * (4.5+3)
    }
    backgroundColor: "white"
    elevation: 2
    z:23

    ListView {
        id: searchSuggestionsView
        width: parent.width
        height: parent.height
        boundsBehavior: Flickable.StopAtBounds
        model: root.app.searchSuggestionsModel
        delegate: ListItem.Standard {
            text: suggestion
            onClicked: {
                setActiveTabURL(suggestion)
                root.app.searchSuggestionsModel.clear()
            }
        }
    }
    ScrollbarThemed {
        flickableItem: searchSuggestionsView
        color: Qt.rgba(0,0,0,0.5)
        hideTime: 1000
    }

}
