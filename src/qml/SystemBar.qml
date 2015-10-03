import Material 0.1
import QtQuick 2.2

Rectangle {

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.visibility == 4
        onDoubleClicked: root.showNormal();
        hoverEnabled: true
        property var target : mouseArea
        property point oPoint
        property string rFlag
        property size minSize : Qt.size(50,50)
        property int dragHeight: 0
        property rect oGeometry
        state: "normal"
        onPressed: {
            if(Qt.LeftButton === mouse.button){
                oPoint = G_Cursor.pos()
                oGeometry = Qt.rect(target.x,target.y,target.width,target.height)
            }
        }
        onReleased:{
            if(!(pressedButtons&Qt.LeftButton)){
                state = "normal";
            }
        }

        onPositionChanged: {
            if(Qt.LeftButton & pressedButtons){
                if("active" === state){
                    var yChange =  G_Cursor.pos().y - oPoint.y;
                    var geometry = Qt.rect(target.x,target.y,target.width,target.height)
                    geometry.y = oGeometry.y + yChange;
                    if(yChange > 20) {
                        root.visibility = 2;
                    }
                    target.y = geometry.y;
                }else{
                    if(Math.abs(mouse.x-oPoint.x)>3 || Math.abs(mouse.y-oPoint.y)>3){
                        state = "active"
                }
            }
            }
        }


    }

    anchors {
        top: parent.top;
        left: parent.left;
        right: parent.right;
        margins: 0
        bottomMargin: 0
    }

    height: tabsModel.count > 1 || root.app.integratedAddressbars ? Units.dp(50) : Units.dp(30);
    color:  root.app.darkTheme ? shadeColor(root.app.darkThemeColor, -0.1) : activeTab.customColor ? shadeColor(activeTab.customColor, -0.1) : "#EFEFEF"

    SystemButtons {
        id: sysbuttons
        onShowMinimized: __window.showMinimized();
        onShowMaximized: __window.showMaximized();
        onShowNormal: __window.showNormal();
        onClose: __window.close();
    }
}
