import QtQuick 2.4
import Material 0.1

ProgressCircle {
    id: indicator

    color: root._icon_color

    // Uncomment to enable color animation:
    /*
    SequentialAnimation {
        running: true
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
    }*/
}
