import QtQuick 2.1
import Qt.labs.settings 1.0
import ".."

BaseApplication {
    id: application

    property string webEngine: "oxide"
    property string platform: "converged/ubuntu"
    property bool enableShortCuts: false
    property bool enableNewWindowAction: false
}
