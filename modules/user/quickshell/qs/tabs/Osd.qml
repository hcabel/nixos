import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

// The transient readout for volume and brightness. A Tab rather than its own
// window, so RailPath carves it out of the same translucent plate as the rail
// it grows from, joins and all.
Tab {
    id: root

    name: "Osd"
    edge: "left"

    length: 216
    depth: 31

    // Tab pads uniformly; this one wants air at the ends only.
    padding: 0

    open: OsdState.showing
    masked: false

    readonly property real inset: 12

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: root.inset
        anchors.bottomMargin: root.inset

        spacing: 9

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: Math.round((OsdState.muted ? 0 : OsdState.value) * 100)

            color: Style.text
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeLabel
            font.bold: true
        }

        Meter {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true

            implicitWidth: 6

            vertical: true
            value: OsdState.muted ? 0 : OsdState.value
            fill: Style.accent
            fillEnd: Style.danger
            glow: 14
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: OsdState.kind === "brightness" ? "" : OsdState.muted ? "" : OsdState.value < 0.5 ? "" : ""

            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.85)
            font.family: Style.fontFamily
            font.pixelSize: 13
        }
    }
}
