import QtQuick 2.0
import Material 0.1


Page {
    id: page
    title: qsTr("Sites color chooser")
    visible: false
    SitesColorList {
        anchors.fill: parent
    }

}
