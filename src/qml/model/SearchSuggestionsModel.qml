import QtQuick 2.4
import Material.Extras 0.1

ListModel {
    id: searchSuggestionsModel

    objectName: "searchSuggestionsModel"
    dynamicRoles: true

    property int selectedIndex
    property string selectedSuggestion: count > 0 ? get(selectedIndex).suggestion : ""

    function appendSuggestion(suggestion, icon, insertMode) {
        if (insertMode === "start")
            insert(0, {"suggestion": suggestion, "icon": icon})
        else
            append({"suggestion": suggestion, "icon": icon});
    }
}
