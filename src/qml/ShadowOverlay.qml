import QtQuick 2.0

Rectangle {
      id: shadow
      signal clicked
      color: Qt.rgba(0,0,0,0.1)
      anchors.fill: parent
      z:19
      visible: false
      MouseArea {
          anchors.fill: parent
          onClicked: {
              shadow.clicked()
          }
      }
}
