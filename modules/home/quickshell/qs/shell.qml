//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.frame

ShellRoot {
    settings.watchFiles: true

    Shortcuts {}

    Variants {
        model: Quickshell.screens // Reload UI when the screens change

        Frame {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (event.name === "fullscreen")
                Hyprland.refreshToplevels();
        }
    }
}
