import QtQuick
import QtQuick.Effects
import Quickshell.Services.UPower
import qs.core
import qs.components

BarChip {
    id: root

    readonly property var device: UPower.displayDevice

    // 0..1, as UPower reports it.
    readonly property real level: root.device?.percentage ?? 0
    readonly property bool charging: root.device?.state === UPowerDeviceState.Charging
    readonly property bool low: root.level <= 0.15 && !root.charging

    readonly property color tone: root.low ? Style.danger : Style.accent

    // Nothing to say on a machine without a battery.
    visible: root.device?.isPresent ?? false

    Item {
        implicitWidth: 20
        implicitHeight: 10

        Rectangle {
            id: shell

            anchors.fill: parent

            radius: 3
            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.16)
        }

        // Before the fill so it lands underneath it.
        RectangularShadow {
            anchors.fill: fill

            radius: fill.radius
            blur: 7
            spread: 0
            offset: Qt.vector2d(0, 0)
            color: root.tone

            opacity: 0.8
        }

        Rectangle {
            id: fill

            anchors.left: shell.left
            anchors.top: shell.top
            anchors.bottom: shell.bottom
            anchors.margins: 1.5

            width: (shell.width - 3) * Math.max(0, Math.min(1, root.level))

            radius: 1.5

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: root.tone
                }

                GradientStop {
                    position: 1
                    color: Qt.lighter(root.tone, 1.35)
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Text {
        visible: root.charging

        text: ""

        color: root.tone
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeLabel
    }

    Text {
        text: Math.round(root.level * 100)

        color: root.low ? Style.danger : Style.textMuted
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeDetail

        Behavior on color {
            ColorAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }
    }
}
