pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs
import qs.drawers
import "Geometry.js" as Geometry

Scope {
    id: root

    required property ShellScreen screen

    readonly property var drawers: drawerSet.all

    // Mode 1 = maximised, above is "real" fullscreen
    readonly property bool hasFullscreen:
        Hyprland.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen > 1) ?? false

    property real fsAnimation: hasFullscreen ? 1 : 0

    readonly property var base: ({
            top: Style.barHeight,
            right: Style.rail,
            bottom: Style.rail,
            left: Style.rail
        })

    // Only animate visual, hyprland window handle it's own animation
    readonly property var visualBase: ({
            top: base.top * (1 - fsAnimation),
            right: base.right * (1 - fsAnimation),
            bottom: base.bottom * (1 - fsAnimation),
            left: base.left * (1 - fsAnimation)
        })
    readonly property var noInsets: ({ top: 0, right: 0, bottom: 0, left: 0 })

    readonly property var reservedInsets: hasFullscreen ? noInsets : Geometry.reservedInsets(base, drawers)
    readonly property var visualInsets: Geometry.visualInsets(visualBase, drawers)

    Behavior on fsAnimation {
        NumberAnimation {
            duration: Style.drawerDuration
            easing.type: Easing.OutCubic
        }
    }

    DrawerSet {
        id: drawerSet
        screen: root.screen
    }

    // Reserve the space for the compositor (no visual)
    Exclusions {
        screen: root.screen
        insets: root.reservedInsets
    }

    // Draw the visual widget
    FrameWindow {
        screen: root.screen
        insets: root.visualInsets
        drawers: root.drawers
        fsAnimation: root.fsAnimation
    }
}
