import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

BarChip {
    id: root

    spacing: 12

    Gauge {
        label: "CPU"
        value: SystemStats.cpu
        tone: Style.accent
    }

    Gauge {
        label: "RAM"
        value: SystemStats.ram
        tone: Style.neutral
    }

    component Gauge: RowLayout {
        id: gauge

        required property string label
        required property real value
        required property color tone

        spacing: 6

        Text {
            text: gauge.label

            color: Style.textMuted
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeDetail
            font.letterSpacing: 0.8
        }

        Meter {
            value: gauge.value
            fill: gauge.tone
        }

        Text {
            // The font is monospaced, so the number never shifts its neighbours
            // as it climbs through the tens.
            text: Math.round(gauge.value * 100)

            color: Style.text
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeDetail
            font.bold: true
        }
    }
}
