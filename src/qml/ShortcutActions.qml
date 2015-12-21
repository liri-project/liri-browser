import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls


Item {
    Controls.Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloadsDrawer.open();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+H"
        onTriggered: {
            historyDrawer.open();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+B"
        onTriggered: {
            bookmarksDrawer.open();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+Alt+S"
        onTriggered: {
            addTab("liri://settings");
        }
    }
    Controls.Action {
        shortcut: "Ctrl+F"
        onTriggered: {
            if (root.activeTab.view.isWebView)
                root.showSearchOverlay()
        }
    }
    Controls.Action {
        id: focus
        shortcut: "Ctrl+L"
        onTriggered: {
            if (root.app.integratedAddressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                toolbar.omnibox.txtUrl.forceActiveFocus();
                toolbar.omnibox.txtUrl.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "Ctrl+K"
        onTriggered: {
            if (root.app.integratedAddressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                toolbar.omnibox.txtUrl.forceActiveFocus();
                toolbar.omnibox.txtUrl.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "Ctrl+R"
        onTriggered: {
            root.activeTab.view.reload();
        }
    }
    Controls.Action {
        shortcut: 19
        onTriggered: {
            root.addTab()
            toolbar.omnibox.txtUrl.forceActiveFocus();
            toolbar.omnibox.txtUrl.selectAll();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+SHIFT+T"
        onTriggered: {
            root.reopenLastClosedTab()
        }
    }
    Controls.Action {
        shortcut: "Ctrl+W"
        onTriggered: {
            root.removeTab(activeTab.uid);
        }
    }
    Controls.Action {
        shortcut: "Escape"
        onTriggered: {
            if (root.app.integratedAddressbars && root.activeTabInEditMode){
                root.activeTabItem.editModeActive = false;
            }
            else if (root.txtSearch.visible){
                root.hideSearchOverlay();
            }
            else if (root.fullscreen){
                root.endFullscreenMode();
            }
        }
    }
    Controls.Action {
        shortcut: "Ctrl+0"
        onTriggered: root.activeTab.view.zoomReset();
    }
    Controls.Action {
        shortcut: 17
        onTriggered: root.activeTab.view.zoomOut();
    }
    Controls.Action {
        shortcut: 16
        onTriggered: root.activeTab.view.zoomIn();
    }
    Controls.Action {
        shortcut: "Ctrl+Tab"
        onTriggered: {
            var currentIndex = root.getTabModelIndexByUID(root.activeTab.uid);
            if (currentIndex === root.tabsModel.count-1)
                root.activeTab = tabsModel.get(0);
            else
                root.activeTab = tabsModel.get(currentIndex+1);
        }
    }
    Controls.Action {
        shortcut: "Ctrl+SHIFT+Tab"
        onTriggered: {
            var currentIndex = root.getTabModelIndexByUID(root.activeTab.uid);
            if (currentIndex === 0)
                root.activeTab = tabsModel.get(root.tabsModel.count-1);
            else
                root.activeTab = tabsModel.get(currentIndex-1);
        }
    }
    Controls.Action {
        shortcut: "F5"
        onTriggered: {
            root.activeTab.view.reload()
        }
    }
    Controls.Action {
        shortcut: "F6"
        onTriggered: {
            if (root.app.integratedAddressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                toolbar.omnibox.txtUrl.forceActiveFocus();
                toolbar.omnibox.txtUrl.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "F11"
        onTriggered: {
            if (!root.fullscreen){
                root.startFullscreenMode();
            }
            else {
                root.endFullscreenMode();
            }
        }
    }
    Controls.Action {
        shortcut: "SHIFT+Backspace"
        onTriggered: {
            if (root.activeTab.view.canGoForward)
                root.activeTab.view.goForward();
        }
    }
    Controls.Action {
        shortcut: "Backspace"
        onTriggered: {
            //if (root.activeTab.view.canGoBack)
            //    root.activeTab.view.goBack();
        }
    }
}
