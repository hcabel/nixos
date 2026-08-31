pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color surface: "#18162C"

    readonly property real surfaceOpacity: 0.25
    readonly property color surfaceTranslucent: Qt.rgba(surface.r, surface.g, surface.b, surfaceOpacity)
    readonly property color surfaceCard: Qt.rgba(surface.r, surface.g, surface.b, 0.58)

    readonly property color text: "#faf3e6"
    readonly property color textMuted: Qt.rgba(text.r, text.g, text.b, 0.6)
    readonly property color accent: "#7aa2f7"
    readonly property color danger: "#f7768e"
    readonly property color neutral: "#8b8a99"
    readonly property string fontFamily: "SpaceMono Nerd Font"

    readonly property int duration: 250
    readonly property real corner: 18
    readonly property real cornerSmall: 13

    readonly property real padding: 18
    readonly property real gap: 8

    readonly property int fontSizeTitle: 18
    readonly property int fontSizeDetail: 11
    readonly property int fontSizeLabel: 10

    readonly property int workspaceCount: 9

    readonly property var workspaceNames: ({
        4: "web",
        5: "code",
        7: "chat"
    })

    readonly property var insets: ({
        top: 30,
        bottom: 10,
        left: 10,
        right: 10
    })
}
