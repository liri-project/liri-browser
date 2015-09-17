import Material 0.1
import QtQuick 2.2

Rectangle {

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

    anchors {
        top: parent.top;
        left: parent.left;
        right: parent.right;
        margins: 0
        bottomMargin: 0
    }

    height: tabsModel.count > 1 || root.app.integratedAddressbars ? Units.dp(50) : Units.dp(30);
    color: activeTab.customColor ? colorLuminance(activeTab.customColor, -0.1) : "#EFEFEF"

    SystemButtons {
        id: sysbuttons
        onShowMinimized: __window.showMinimized();
        onShowMaximized: __window.showMaximized();
        onShowNormal: __window.showNormal();
        onClose: __window.close();
    }
}
