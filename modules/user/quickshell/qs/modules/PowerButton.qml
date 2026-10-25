import QtQuick
import qs.core
import qs.components

BarChip {
    id: root

    // Square: the glyph carries it, so the row supplies no padding of its own.
    padH: 0

    implicitWidth: Style.chipHeight

    interactive: true
    active: TabState.isOpen("Power")

    onClicked: TabState.toggle("Power")

    Text {
        text: ""

        color: root.active ? Style.accent : Style.textMuted
        font.family: Style.fontFamily
        font.pixelSize: 13

        Behavior on color {
            ColorAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }
    }
}
