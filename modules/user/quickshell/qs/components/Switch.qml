import QtQuick
import qs.core

// The toggle the component set was missing. Button sits underneath so the
// hover ramp, the pointing cursor and the tap all come from one place; only
// the track colour and the knob are this file's own.
Button {
    id: root

    property bool checked: false

    // The hardware is mid-transition. The switch still reads its target state,
    // dimmed, so a slow radio does not look like a dropped click.
    property bool busy: false

    signal toggled

    implicitWidth: 38
    implicitHeight: 20

    radius: root.height / 2

    opacity: root.busy ? 0.5 : 1

    Behavior on opacity {
        NumberAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    // Replaces Button's three-state fill rather than extending it: on, the
    // track carries the accent, and the hover and press lifts ride on that
    // instead of the neutral text tint.
    color: root.checked ? Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, root.pressed ? 0.85 : root.hovered ? 0.7 : 0.55) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, root.pressed ? 0.22 : root.hovered ? 0.16 : 0.08)

    onClicked: root.toggled()

    Rectangle {
        id: knob

        y: (root.height - height) / 2
        x: root.checked ? root.width - width - 3 : 3

        implicitWidth: 14
        implicitHeight: 14

        radius: height / 2

        // Dark on the lit track, so the knob reads as a hole in the accent
        // rather than a second lit thing sitting on top of it.
        color: root.checked ? Style.surface : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.55)

        Behavior on x {
            NumberAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }
    }
}
