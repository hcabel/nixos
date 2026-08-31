import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property var insets

    property var tabs: []

    property real reach: 18
    property color tint: "#000000"
    property real strength: 0.38
    property real power: 3

    property int lod: 16

    Repeater {
        model: root.lod

        Shape {
            id: ring

            required property int index

            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            readonly property real k0: root.reach * (1 - Math.pow((root.lod - ring.index) / root.lod, 1 / root.power))
            readonly property real k1: root.reach * (1 - Math.pow((root.lod - ring.index - 1) / root.lod, 1 / root.power))

            ShapePath {
                fillColor: "transparent"

                strokeWidth: ring.k1 - ring.k0
                strokeColor: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, root.strength * (root.lod - ring.index - 0.5) / root.lod)

                joinStyle: ShapePath.RoundJoin

                PathSvg {
                    path: RailPath.hole(root.width, root.height, root.insets, Style.corner, root.tabs, (ring.k0 + ring.k1) / 2)
                }
            }
        }
    }
}
