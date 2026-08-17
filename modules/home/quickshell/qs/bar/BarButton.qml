import QtQuick
import qs.components
import qs

Item {
    id: root

    property alias text: label.text
    property bool active: false

    signal clicked

    implicitWidth: label.implicitWidth + Style.padding * 2
    implicitHeight: Style.barHeight

    Rectangle {
        anchors.centerIn: parent

        width: parent.width
        height: label.implicitHeight + Style.gap / 2
        radius: height / 2

        color: root.active ? Style.accent : mouse.containsMouse ? Style.overlay : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Style.animFast
            }
        }

        StyledText {
            id: label

            anchors.centerIn: parent

            color: root.active ? Style.base : Style.text
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
