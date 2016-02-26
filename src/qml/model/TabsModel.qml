import QtQuick 2.4
import Material.Extras 0.1

ListModel {
    id: tabs

    property int selectedIndex

    property Tab activeTab: count > 0 ? tabs.get(selectedIndex).tab : null

    function addTab(url) {
        if (!url)
            url = defaultTabUrl

        var tab = Utils.newObject(Qt.resolvedUrl("Tab.qml"), {}, tabs)
        tab.view = browserViewComponent.createObject(browserPage.tabContainer, {tab: tab})
        tab.load(url)
        tabs.append({tab: tab})
    }

    function removeTab(t) {
        // t is uid
        if (typeof(t) === "number") {

            // Remove all uid references from activeTabHistory:
            while (activeTabHistory.indexOf(t) > -1) {
                activeTabHistory.splice(activeTabHistory.indexOf(t), 1);
            }

            // Set last active tab:
            if (activeTab.uid === t) {
                setLastActiveTabActive(function(){
                    var modelData = getTabModelDataByUID(t);
                    modelData.view.visible = false;
                    modelData.view.destroy();
                    tabsModel.remove(getTabModelIndexByUID(t));
                    // Was the last tab closed?
                    if (tabsModel.count === 0) {
                        addTab();
                    }
                });
            }
            else {
                var modelData = getTabModelDataByUID(t);
                modelData.view.visible = false;
                modelData.view.destroy();
                tabsModel.remove(getTabModelIndexByUID(t));
            }
        }
    }
}
