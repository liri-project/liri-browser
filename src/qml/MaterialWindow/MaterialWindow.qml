import QtQuick 2.0
import Material 0.1
import QtGraphicalEffects 1.0

ApplicationWindow {
    title: "Application Name"
    color: "transparent"
    flags:   Qt.FramelessWindowHint
    id: __window
    width: 1000
    height: 640
    theme {
        id: theme
        primaryColor: "#F44336"
        primaryDarkColor: "#D32F2F"
        accentColor: "#FF5722"
        backgroundColor: "transparent"
    }
    visible: true
    property var initialPageFrameLess
    default property alias content : frame.children
    property alias minSize: resizeArea.minSize

    ResizeArea{
        id:resizeArea
        anchors.fill: parent
        dragHeight: systemBar.height
        anchors.margins: 8
        target: __window
        minSize: Qt.size(600,400)
        enabled: true

        RectangularGlow {
            id: outGlow
            anchors.fill: frame
            anchors.margins: 5
            anchors.bottomMargin: 0   /*底部阴影没有缩进因此底部阴影颜色最浓*/
            glowRadius: 10
            spread: 0.1
            color: "#A0000000"
            cornerRadius: frame.radius + glowRadius
        }

        Rectangle{
            id: frame
            border{width: 0; color: activeTab.customColor ? colorLuminance(activeTab.customColor, -0.1) : "#EFEFEF"}
            anchors.fill: parent
            anchors.margins: 9
            color: "white"
            smooth: true
            radius: 3

            SystemBar {
                id: systemBar
            }

            Toolbar {
                id: __toolbar
                anchors.margins: 1
                anchors.topMargin: 0
                anchors.top: systemBar.bottom
            }

            PageStack {
                id: __pageStack
                initialItem: __window.initialPageFrameLess
                anchors {
                left: parent.left
                right: parent.right
                top: __toolbar.bottom
                bottom: parent.bottom
            }

            onPushed: __toolbar.push(page)
            onPopped: __toolbar.pop()
            onReplaced: __toolbar.replace(page)
            }

        }
    }

    Item{
        state:__window.visibility
        states: [
            State {
                name: "2"   /*Windowed*/
                PropertyChanges { target: resizeArea; anchors.margins: 8; enabled: true }
                PropertyChanges { target: outGlow; visible: true }
                PropertyChanges { target: frame; anchors.margins: 4; border.width: 0;  }
            },
            State {
                name: "4"   /*FullScreen*/
                PropertyChanges { target: resizeArea; anchors.margins: 0; enabled: false }
                PropertyChanges { target: outGlow; visible: false }
                PropertyChanges { target: frame; anchors.margins: 0; border.width: 0; }
            }
        ]
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
