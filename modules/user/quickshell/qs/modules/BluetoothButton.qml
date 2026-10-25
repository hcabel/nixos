import QtQuick
import qs.core
import qs.components

BarChip {
    id: root

    // Tighter than the default: the glyph is the whole chip most of the time,
    // and the badge supplies its own room when it appears.
    padH: 7

    // Nothing to say on a machine with no radio.
    visible: Bluetooth.present

    interactive: true
    active: PanelState.edgeOf("bluetooth") !== ""

    onClicked: PanelState.toggle("right", "bluetooth")

    Text {
        text: !Bluetooth.enabled ? "󰂲" : Bluetooth.connectedCount > 0 ? "󰂱" : "󰂯"

        color: Bluetooth.connectedCount > 0 ? Style.accent : Style.textMuted
        font.family: Style.fontFamily
        font.pixelSize: 13

        Behavior on color {
            ColorAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }
    }

    // Only past the first: the glyph already says something is connected, so a
    // badge reading "1" next to it would be the same fact twice.
    Rectangle {
        visible: Bluetooth.connectedCount > 1

        implicitWidth: Math.max(14, badge.implicitWidth + 8)
        implicitHeight: 14

        radius: 5
        color: Style.accent

        Text {
            id: badge

            anchors.centerIn: parent

            text: Bluetooth.connectedCount
            color: Style.surface
            font.family: Style.fontFamily
            font.pixelSize: 9
            font.bold: true
        }
    }
}
