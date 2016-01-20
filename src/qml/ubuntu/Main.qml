import QtQuick 2.4
import Material 0.2
import QtQuick.Window 2.0
import QtSystemInfo 5.0

import ".."

BrowserWindow {
    id: root

    ScreenSaver {
        screenSaverEnabled: !Qt.application.active
    }

    app: UbuntuApplication {

    }

    function fixDensity() {
        // BQ Devices
        var bqAquarisE45 =
                (Screen.width == 540) &&
                (Screen.height == 960) &&
                (Screen.pixelDensity.toFixed(2) == 3.94) &&
                (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (bqAquarisE45) {
            Units.multiplier = 2;
        }

        var bqAquarisE5 =
            (Screen.width == 720) &&
            (Screen.height == 1280) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (bqAquarisE5) {
            Units.multiplier = 3.03
        }

        // Meizu Devices
        var meizuMX4 =
            (Screen.width == 1152) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (meizuMX4) {
            Units.multiplier = 4.11
        }

        // Google Nexus Devices
        var googleNexus4 =
            (Screen.width == 768) &&
            (Screen.height == 1280) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus4) {
            Units.multiplier = 3.23
        }

        var googleNexus5 =
            (Screen.width == 1080) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus5) {
            Units.multiplier = 4.11
        }

        var googleNexus7 =
            (Screen.width == 1200) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus7) {
            Units.multiplier = 3.23
        }

    }

    Component.onCompleted: {
        fixDensity();
    }

}
