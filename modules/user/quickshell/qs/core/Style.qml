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
    readonly property real cornerChip: 5

    readonly property real padding: 18
    readonly property real gap: 8

    readonly property int fontSizeTitle: 18
    readonly property int fontSizeDetail: 11
    readonly property int fontSizeLabel: 10

    readonly property real chipHeight: 20

    readonly property int workspaceCount: 9

    readonly property var workspaceNames: ({
        4: "web",
        5: "code",
        7: "chat"
    })

    readonly property var insets: ({
        top: 42,
        bottom: 10,
        left: 10,
        right: 10
    })

    // --- Saturn stage identity -------------------------------------------
    // Shared by the greeter (qs.greeter) and, baked into pixels at build time,
    // by the Plymouth theme in modules/sys/plymouth. The two stages have to
    // agree on these numbers, or the lockup jumps as the splash hands over.

    // Far stop of the accent gradient. Named for its role rather than its hue,
    // to match accent/danger/neutral above. Build gradients where they are
    // used: a Gradient is a QObject, and sharing one across windows reparents
    // it out from under the first.
    readonly property color accentAlt: "#f28fad"

    // The scrim that darkens the wallpaper under the content column: three
    // stops along a 100 degree vector, near edge to far.
    readonly property color scrim: "#05070a"
    readonly property real scrimNear: 0.90
    readonly property real scrimMid: 0.60
    readonly property real scrimFar: 0.05

    // Stage surfaces are authored at this size and scale uniformly from it, so
    // every coordinate below is in design pixels.
    readonly property real designWidth: 1920
    readonly property real designHeight: 1080

    readonly property var lockup: ({
        x: 130,
        y: 286,
        contentY: 380,
        markSize: 44,
        gap: 14
    })

    readonly property int fontSizeClock: 96
    readonly property int fontSizeHero: 34
}
