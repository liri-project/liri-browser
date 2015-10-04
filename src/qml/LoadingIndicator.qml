import QtQuick 2.4
import Material 0.1

ProgressCircle {
    id: indicator
    color: "white"

    SequentialAnimation {
        running: !root.app.darkTheme
        loops: Animation.Infinite

        ColorAnimation {
            from: "red"
            to: "blue"
            target: indicator
            properties: "color"
            easing.type: Easing.InOutQuad
            duration: 2400
        }

        ColorAnimation {
            from: "blue"
            to: "green"
            target: indicator
            properties: "color"
            easing.type: Easing.InOutQuad
            duration: 1560
        }

        ColorAnimation {
            from: "green"
            to: "#FFCC00"
            target: indicator
            properties: "color"
            easing.type: Easing.InOutQuad
            duration:  840
        }

        ColorAnimation {
            from: "#FFCC00"
            to: "red"
            target: indicator
            properties: "color"
            easing.type: Easing.InOutQuad
            duration:  1200
        }
    }
}
