import QtQuick
import qs.components
import qs

// A bar chip. 26px is the top-bar control height; the ladder assigns 22 inside
// a panel and 20 inside a row.
//
// Active is a 24% tint plus a 42% hairline, not a solid fill — accents are
// never solid behind text. Hover adds white, never accent, because accent
// already means "selected" and one signal cannot mean two things.
Item {
    id: root

    property alias text: label.text
    property bool active: false

    signal clicked

    implicitWidth: label.implicitWidth + Style.s.gap[3] * 2
    implicitHeight: Style.s.height.bar

    Rectangle {
        anchors.centerIn: parent

        width: parent.width
        height: Style.s.height.barControl
        radius: Style.r.chip

        color: root.active ? Style.c.accent.primary.active : mouse.containsMouse ? Style.c.bg.hover : "transparent"

        border.width: Style.s.strokeHair
        border.color: root.active ? Style.c.accent.primary.line : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Style.m.dur.state
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Style.m.dur.state
            }
        }

        StyledText {
            id: label

            anchors.centerIn: parent

            color: root.active ? Style.c.accent.primary.text : Style.c.text.body
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
