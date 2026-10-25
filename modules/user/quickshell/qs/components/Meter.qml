import QtQuick
import QtQuick.Effects
import qs.core

// A hairline gauge: a dim track with a lit fill riding on top of its own glow.
// Horizontal by default, filling from the left; stood on end it fills from the
// bottom, which is the only thing the two axes disagree about.
Item {
    id: root

    // 0..1. Clamped here so callers can hand over a raw ratio.
    property real value: 0
    property color fill: Style.accent

    // The far end of the fill's ramp. Flat unless a caller asks for one.
    property color fillEnd: root.fill

    property bool vertical: false
    property real glow: 6

    implicitWidth: root.vertical ? 2 : 26
    implicitHeight: root.vertical ? 26 : 2

    readonly property real thickness: root.vertical ? root.width : root.height

    Rectangle {
        id: track

        anchors.fill: parent

        radius: root.thickness / 2
        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.14)
    }

    // Declared before the fill so it lands underneath it.
    RectangularShadow {
        anchors.fill: bar

        radius: bar.radius
        blur: root.glow
        spread: 0
        offset: Qt.vector2d(0, 0)
        color: root.fill

        // A fill of zero still has a rect to glow around, and the smudge it
        // leaves reads as a lit meter that is merely very dim.
        opacity: bar.ratio > 0.005 ? 0.9 : 0
    }

    Rectangle {
        id: bar

        // Pinned at the bottom left corner and sized outright, so neither axis
        // ends up with anchors and a width both trying to set it.
        anchors.left: track.left
        anchors.bottom: track.bottom

        readonly property real ratio: Math.max(0, Math.min(1, root.value))

        width: root.vertical ? track.width : track.width * bar.ratio
        height: root.vertical ? track.height * bar.ratio : track.height

        radius: root.thickness / 2

        // Position 0 is the leading edge in both cases: the left of a bar that
        // grows rightward, the top of one that grows upward.
        gradient: Gradient {
            orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal

            GradientStop {
                position: 0
                color: root.vertical ? root.fillEnd : root.fill
            }

            GradientStop {
                position: 1
                color: root.vertical ? root.fill : root.fillEnd
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }
    }
}
