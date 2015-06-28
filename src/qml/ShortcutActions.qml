import QtQuick 2.0
import QtQuick.Controls 1.3 as Controls


Item {

    Controls.Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            // Show downloads
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
            txt_url.forceActiveFocus();
            txt_url.selectAll();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+R"
        onTriggered: {
            get_current_tab().reload()
        }
    }
    Controls.Action {
        shortcut: "Ctrl+T"
        onTriggered: {
            root.add_tab()
            txt_url.forceActiveFocus();
            txt_url.selectAll();
        }
    }
    Controls.Action {
        shortcut: "Ctrl+W"
        onTriggered: {
            get_current_tab().close()
        }
    }
    Controls.Action {
        shortcut: "Escape"
        onTriggered: {
            if (root.get_current_tab().tab.state === "active_edit"){
                root.get_current_tab().tab.state = "active"
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
        onTriggered: get_current_tab().webview.zoomFactor = 1.0;
    }
    Controls.Action {
        shortcut: "Ctrl+-"
        onTriggered: get_current_tab().webview.zoomFactor -= 0.1;
    }
    Controls.Action {
        shortcut: "Ctrl+="
        onTriggered: get_current_tab().webview.zoomFactor += 0.1;
    }
    Controls.Action {
        shortcut: "Ctrl+Tab"
        onTriggered: {console.log("nextChild")} // TODO: implement tab switching per Ctrl+Tab
    }
    Controls.Action {
        shortcut: "F5"
        onTriggered: {
            get_current_tab().reload()
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
