import QtQuick 2.4
import Material 0.1
import QtQuick.Window 2.0

import ".."

BrowserWindow {
    id: root
    app: UbuntuApplication {

    }

    function fixDensity() {
        var bq45 =
                (Screen.width == 540) &&
                (Screen.height == 960) &&
                (Screen.pixelDensity.toFixed(2) == 3.94) &&
                (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        console.log("BQ?", bq45)
        if (bq45) {
            Units.multiplier = 2;
        }
    }

    Component.onCompleted: fixDensity();

}
