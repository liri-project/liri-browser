import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.2 as Controls

RowLayout {
    spacing: Units.dp(10)
    anchors {
        right: parent.right
        rightMargin:spacing
        verticalCenter: parent.verticalCenter
    }

    signal showMinimized;
    signal showMaximized;
    signal showFullScreen;
    signal showNormal;
    signal close;

    IconButton {
        iconName: "navigation/expand_more"
        width: Units.dp(20)
        height: width
        color: Theme.lightDark(colorLuminance(activeTab.customColor,-0.1), Theme.light.iconColor, Theme.dark.iconColor)
        onClicked: showMinimized()
    }

    IconButton {
        iconName: root.visibility == 4 ? "navigation/fullscreen_exit" : "navigation/fullscreen"
        width: Units.dp(20)
        id: sysbtn_max
        height: width
        color: Theme.lightDark(colorLuminance(activeTab.customColor,-0.1), Theme.light.iconColor, Theme.dark.iconColor)
        onClicked: {
            if(root.visibility == 2)
                showMaximized();
            else
                showNormal();
        }
    }

    IconButton {
        iconName: "navigation/close"
        width: Units.dp(20)
        height: width
        color: Theme.lightDark(colorLuminance(activeTab.customColor,-0.1), Theme.light.iconColor, Theme.dark.iconColor)
        onClicked: close()
    }

    function colorLuminance(hex, lum) {
    	hex = String(hex).replace(/[^0-9a-f]/gi, '');
    	if (hex.length < 6) {
    	       hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    	}
    	lum = lum || 0;
    	var rgb = "#", c, i;
    	for (i = 0; i < 3; i++) {
    		c = parseInt(hex.substr(i*2,2), 16);
    		c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);
    		rgb += ("00"+c).substr(c.length);
    	}

    	return rgb;
    }
}
