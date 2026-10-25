import QtQuick
import qs.core
import qs.components

BarChip {
    id: root

    // Tighter than the default: the glyph is the whole chip.
    padH: 7

    interactive: true
    active: PanelState.edgeOf("powermode") !== ""

    onClicked: PanelState.toggle("right", "powermode")

    Text {
        text: PowerMode.icon

        // Degradation outranks the profile: performance the firmware is
        // throttling is the one case where the chip has bad news to carry, and
        // it should not read as the healthy accent while that is true.
        color: PowerMode.degraded ? Style.danger : PowerMode.performing ? Style.accent : Style.textMuted
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
