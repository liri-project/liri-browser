import QtQuick 2.0
import QtQuick.Controls 1.3 as Controls


Item {

    Controls.Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloads_drawer.open();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+F"
        onTriggered: {
            root.show_search_overlay()
        }
    }
    Controls.Action {
        id: focus
        shortcut: "Ctrl+L"
        onTriggered: {
            if (root.app.integrated_addressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                txt_url.forceActiveFocus();
                txt_url.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "Ctrl+K"
        onTriggered: {
            if (root.app.integrated_addressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                txt_url.forceActiveFocus();
                txt_url.selectAll();
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
            txt_url.forceActiveFocus();
            txt_url.selectAll();
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
            if (root.app.integrated_addressbars && root.activeTabInEditMode){
                root.activeTabItem.editModeActive = false;
            }
            else if (root.txt_search.visible){
                root.hide_search_overlay();
            }
            else if (root.fullscreen){
                root.end_fullscreen_mode();
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
            if (root.app.integrated_addressbars && !root.activeTabInEditMode){
                root.activeTabItem.editModeActive = true;
            }
            else {
                txt_url.forceActiveFocus();
                txt_url.selectAll();
            }
        }
    }
    Controls.Action {
        shortcut: "F11"
        onTriggered: {
            if (!root.fullscreen){
                root.start_fullscreen_mode();
            }
            else {
                root.end_fullscreen_mode();
            }
        }
    }


}
