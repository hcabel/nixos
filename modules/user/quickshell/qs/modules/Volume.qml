import QtQuick
import qs.core
import qs.components

BarChip {
    id: root

    Text {
        text: Audio.muted ? "" : Audio.volume < 0.5 ? "" : ""

        color: Style.textMuted
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeDetail
    }

    Meter {
        value: Audio.muted ? 0 : Audio.volume
        fill: Style.accent
    }
}
