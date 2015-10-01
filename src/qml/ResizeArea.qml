import QtQuick 2.5
import QtQuick.Window 2.2

MouseArea{
    id: mouseArea
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

    onDoubleClicked:{
        if(root.visibility == 2)
            root.showMaximized();
        else
            root.showNormal();
    }

    onPositionChanged: {
        if(Qt.LeftButton & pressedButtons){
            if("active" === state){
                var xChange =  G_Cursor.pos().x - oPoint.x;
                var yChange =  G_Cursor.pos().y - oPoint.y;
                var geometry = Qt.rect(target.x,target.y,target.width,target.height)
                switch(rFlag[0]){
                case "l":
                    xChange = Math.min(oGeometry.width-minSize.width,xChange)
                    geometry.x = oGeometry.x + xChange
                    geometry.width = oGeometry.width - xChange
                    break;
                case "r":
                    xChange = Math.max(minSize.width-oGeometry.width,xChange)
                    geometry.width = oGeometry.width + xChange
                    break;
                default: break;
                }
                switch(rFlag[1]){
                case "t":
                    yChange = Math.min(oGeometry.height-minSize.height,yChange)
                    geometry.y = oGeometry.y + yChange
                    geometry.height = oGeometry.height - yChange
                    break;
                case "b":
                    yChange = Math.max(minSize.height-oGeometry.height,yChange)
                    geometry.height = oGeometry.height + yChange;
                    break;
                default: break;
                }
                if("md" == rFlag){
                    geometry.x = oGeometry.x + xChange;
                    geometry.y = oGeometry.y + yChange;
                    root.snappedRight = false;
                    root.snappedLeft = false;
                    if(geometry.y < (-3*systemBar.height/4)) {
                        root.visibility = 4;
                    }
                    if(geometry.x < -100) {
                        geometry.width = Screen.desktopAvailableWidth / 2;
                        geometry.height = Screen.desktopAvailableHeight;
                        root.snappedLeft = true;
                    }
                    if(geometry.x > Screen.desktopAvailableWidth - geometry.width + 100) {
                        geometry.width = Screen.desktopAvailableWidth / 2;
                        geometry.height = Screen.desktopAvailableHeight;
                        root.snappedRight = true;
                    }
                }

                target.x = geometry.x;
                target.y = geometry.y;
                target.width = geometry.width;
                target.height = geometry.height;
            }else{
                if(Math.abs(mouse.x-oPoint.x)>3 || Math.abs(mouse.y-oPoint.y)>3){
                    state = "active"
                }
            }
        }else if(!pressedButtons){
            if(mouse.x < 8) rFlag = "l"
            else if(mouse.x > width-8) rFlag = "r"
            else rFlag = "m"
            if(mouse.y < 8) rFlag += "t"
            else if(mouse.y > height-8) rFlag += "b"
            else if(mouse.y < dragHeight) rFlag += "d"
            else rFlag += "m"

            switch(rFlag){
                case "lt":
                case "rb": cursorShape = Qt.SizeFDiagCursor; break;
                case "lb":
                case "rt": cursorShape = Qt.SizeBDiagCursor; break;
                case "ld":
                case "rd":
                case "lm":
                case "rm": cursorShape = Qt.SizeHorCursor; break;
                case "mt":
                case "mb": cursorShape = Qt.SizeVerCursor; break;
                default: cursorShape = Qt.ArrowCursor; break;
            }
        }
    }
}
