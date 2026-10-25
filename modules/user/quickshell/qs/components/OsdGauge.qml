import QtQuick
import QtQuick.Layouts
import qs.core

// The readout itself — value, meter, icon — with no opinion about what holds
// it. The rail grows one out of its own plate; in fullscreen the rail is gone
// and OsdOverlay carries the same gauge in from the screen edge instead.
Item {
    id: root

    // Air at the ends only; the holder decides the cross-axis padding.
    property real inset: 12

    implicitWidth: 31
    implicitHeight: 216

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

            text: OsdState.kind === "brightness" ? "" : OsdState.muted ? "" : OsdState.value < 0.5 ? "" : ""

            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.85)
            font.family: Style.fontFamily
            font.pixelSize: 13
        }
    }
}
