import QtQuick
import qs.core

Rectangle {
    id: root

    signal clicked

    readonly property bool hovered: hover.hovered
    readonly property bool pressed: tap.pressed

    default property alias content: pad.data

    radius: Style.cornerSmall
    color: root.pressed ? Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.22) : root.hovered ? Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.16) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.08)

    Behavior on color {
        ColorAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hover
    }

    TapHandler {
        id: tap

        onTapped: root.clicked()
    }

    Item {
        id: pad

        anchors.fill: parent
    }
}
