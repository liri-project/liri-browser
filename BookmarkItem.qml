import QtQuick 2.0
import Material 0.1


Item {
    id: item
    property string title
    property string favicon_url
    property string url
    property int maximum_width: Units.dp(148)

    height: parent.height
    width: row.childrenRect.width

    property int maximum_text_width: maximum_width - favicon.width - Units.dp(16)

    Row {
        id: row
        spacing: Units.dp(5)
        anchors.fill: parent

        Image {
            id: favicon
            source: favicon_url
            width: Units.dp(18)
            height: Units.dp(18)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: title
            color: root.current_icon_color
            elide: Text.ElideRight
            smooth: true
            clip: true

            width: maximum_text_width
            anchors.verticalCenter: parent.verticalCenter

            Component.onCompleted:  {
                console.log(paintedWidth, maximum_text_width)
                if (paintedWidth > maximum_text_width) {
                    width= maximum_text_width
                }
                else{
                        width=paintedWidth
                }
            }
        }

    }

    MouseArea {
        id: mouse_area
        anchors.fill:  parent
        onClicked: bookmark_container.add_tab(item.url)
    }
}
