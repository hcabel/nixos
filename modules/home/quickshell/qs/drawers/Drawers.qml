pragma Singleton

// The drawer registry: one DrawerState per screen, plus the ways to reach them.
//
// State is per screen rather than global so a drawer opened on one monitor does
// not close it on another — and, less obviously, so the frame on an idle monitor
// does not take keyboard focus because something opened somewhere else.

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    function forScreen(screen) {
        for (const s of states.instances)
            if (s.modelData === screen)
                return s;
        return null;
    }

    // The monitor Hyprland considers focused. Only needed by the IPC entry
    // points — a click already knows which screen it happened on.
    function forActive() {
        const monitor = Hyprland.focusedMonitor;
        for (const s of states.instances)
            if (Hyprland.monitorFor(s.modelData) === monitor)
                return s;
        return null;
    }

    function toggle(state, name, reserves) {
        if (!state)
            return;

        const slot = reserves ? "panel" : "overlay";
        state[slot] = state[slot] === name ? "" : name;
    }

    function close(state) {
        if (!state)
            return;

        state.overlay = "";
        state.panel = "";
    }

    Variants {
        id: states

        model: Quickshell.screens

        DrawerState {}
    }

    // Remote control, so drawers can be bound to keys without the shell having
    // to know what a key is:
    //
    //   qs ipc call drawers toggleOverlay dashboard
    //   qs ipc call drawers togglePanel controls
    //
    // The two slots are the API. A caller does not have to know whether a given
    // drawer reserves space, only which slot it wants to occupy.
    IpcHandler {
        target: "drawers"

        function toggleOverlay(name: string): void {
            root.toggle(root.forActive(), name, false);
        }

        function togglePanel(name: string): void {
            root.toggle(root.forActive(), name, true);
        }

        function closeAll(): void {
            root.close(root.forActive());
        }
    }
}
