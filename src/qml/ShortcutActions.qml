import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls
import Material.Extras 0.1


Item {
    property var txtUrl: Utils.findChild(root,"txtUrl")
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
                txtUrl.forceActiveFocus();
                txtUrl.selectAll();
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
                txtUrl.forceActiveFocus();
                txtUrl.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "Ctrl+R"
        onTriggered: {
            root.activeTab.webview.reload();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+T"
        onTriggered: {
            root.addTab()
            txtUrl.forceActiveFocus();
            txtUrl.selectAll();
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
        onTriggered: root.activeTab.webview.zoomFactor = 1.0;
    }
    Controls.Action {
        shortcut: "Ctrl+-"
        onTriggered: root.activeTab.webview.zoomFactor -= 0.1;
    }
    Controls.Action {
        shortcut: "Ctrl+="
        onTriggered: root.activeTab.webview.zoomFactor += 0.1;
    }
    Controls.Action {
        shortcut: "Ctrl+Tab"
        onTriggered: {console.log("nextChild")} // TODO: implement tab switching per Ctrl+Tab
    }
    Controls.Action {
        shortcut: "F5"
        onTriggered: {
            root.activeTab.webview.reload()
        }
    }
    Controls.Action {
        shortcut: "F6"
        onTriggered: {
            if (root.app.integratedAddressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                txtUrl.forceActiveFocus();
                txtUrl.selectAll();
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


}
