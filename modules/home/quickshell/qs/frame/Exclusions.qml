pragma ComponentBehavior: Bound

// Four 1x1 windows whose only job is to tell the compositor how much space the
// frame occupies. They are never seen and never clicked: an empty mask makes
// them fully click-through, and nothing is drawn into them.
//
// Each one takes a single anchor because exclusiveZone is ignored on a surface
// anchored to 2 or 4 edges — which is also why a reserving drawer reserves
// across its whole edge regardless of how wide it is on screen. A zone is one
// number per edge; it cannot describe a bump.

import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    required property ShellScreen screen

    // Snapped, not animated. See Frame.qml.
    required property var insets

    Zone {
        anchors.top: true
        exclusiveZone: root.insets.top
    }

    Zone {
        anchors.bottom: true
        exclusiveZone: root.insets.bottom
    }

    Zone {
        anchors.left: true
        exclusiveZone: root.insets.left
    }

    Zone {
        anchors.right: true
        exclusiveZone: root.insets.right
    }

    component Zone: PanelWindow {
        screen: root.screen
        color: "transparent"

        // Its own namespace, so hyprland/rules.nix can tell the frame (which
        // wants blur) apart from these four invisible 1x1 surfaces (which do not
        // want anything).
        WlrLayershell.namespace: "quickshell:exclusion"

        implicitWidth: 1
        implicitHeight: 1

        mask: Region {}
    }
}
