import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    required property ShellScreen screen

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

        WlrLayershell.namespace: "quickshell:exclusion"

        implicitWidth: 1
        implicitHeight: 1

        mask: Region {}
    }
}

