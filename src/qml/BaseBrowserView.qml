import QtQuick 2.0

Item {

    property var icon: Qt.resolvedUrl("")
    property string title: "New tab"
    property string url: ""
    property bool loading: false
    property real loadProgress: 1.0
    property bool reloadable: false

    property bool canGoBack: false
    property bool canGoForward: false
    property bool secureConnection: false

    property var customColor: false
    property var customColorLight: false
    property var customTextColor: false
    property bool hasCloseButton: true

}

