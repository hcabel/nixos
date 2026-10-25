import QtQuick
import Quickshell
import Quickshell.Hyprland

// Whether the workspace showing on `screen` has a fullscreen window on it.
// Worth knowing because that is the one case where Hyprland draws a client
// above the top layer: the whole Frame, rail and bar included, disappears
// under it, and chrome that still needs to be seen has to come from an
// overlay-layer window anchored to the bare screen edge.
Scope {
    id: root

    required property var screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
    readonly property HyprlandWorkspace workspace: root.monitor ? root.monitor.activeWorkspace : null

    readonly property bool active: {
        const o = root.workspace ? root.workspace.lastIpcObject : null;
        return o ? (o.hasfullscreen ?? false) : false;
    }

    // hasfullscreen only ever arrives with a workspace dump, and Hyprland does
    // not push one when a window goes fullscreen — or when the last fullscreen
    // window closes, which is why the list below is wider than "fullscreen".
    readonly property var watched: ["fullscreen", "openwindow", "closewindow", "workspace", "workspacev2", "focusedmon", "focusedmonv2", "movewindow", "movewindowv2"]

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (root.watched.includes(event.name))
                Hyprland.refreshWorkspaces();
        }
    }
}
