import QtQuick

Item {
    id: root

    required property var insets

    property real reach: 18
    property color tint: "#000000"
    property real strength: 0.38
    property real power: 3

    property int lod: 8

    Repeater {
        model: root.lod

        Rectangle {
            id: ring

            required property int index

            readonly property real k0: root.reach * (1 - Math.pow((root.lod - ring.index) / root.lod, 1 / root.power))
            readonly property real k1: root.reach * (1 - Math.pow((root.lod - ring.index - 1) / root.lod, 1 / root.power))

            x: root.insets.left - ring.k1
            y: root.insets.top - ring.k1
            width: root.width - root.insets.left - root.insets.right + ring.k1 * 2
            height: root.height - root.insets.top - root.insets.bottom + ring.k1 * 2

            radius: Style.corner + ring.k1
            border.width: ring.k1 - ring.k0
            border.color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, root.strength * (root.lod - ring.index - 0.5) / root.lod)

            color: "transparent"
            antialiasing: true
        }
    }
}
