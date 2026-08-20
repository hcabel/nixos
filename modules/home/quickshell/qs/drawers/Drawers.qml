pragma Singleton

// The drawer registry: one DrawerState per screen, plus the ways to reach them.
//
// State is per screen rather than global so a drawer opened on one monitor does
// not close it on another — and, less obviously, so the frame on an idle monitor
// does not take keyboard focus because something opened somewhere else.
//
// Callers name a drawer and nothing else. Whether that name lands in the overlay
// slot or the panel slot is the drawer's own business — it already carries a
// `reserves` flag — so `toggle("controls")` reads the same from a keybind, an IPC
// call, and a click on the bar. That is what `registry` below is for: the state
// objects alone cannot answer "does this name reserve space".

import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Every live Drawer, across every screen, each one having put itself here
    // from its own Component.onCompleted.
    //
    // Deliberately not on DrawerState: that is PersistentProperties, which
    // survives QML hot reload, and object references that outlive their objects
    // are stale handles. This list is torn down and rebuilt with the drawers.
    property var registry: []

    function register(drawer) {
        if (!root.registry.includes(drawer))
            root.registry.push(drawer);
    }

    function unregister(drawer) {
        const i = root.registry.indexOf(drawer);
        if (i !== -1)
            root.registry.splice(i, 1);
    }

    function forScreen(screen) {
        for (const s of states.instances)
            if (s.modelData === screen)
                return s;
        return null;
    }

    // The monitor Hyprland considers focused. Only needed by the remote entry
    // points — a click already knows which screen it happened on.
    function forActive() {
        const monitor = Hyprland.focusedMonitor;
        for (const s of states.instances)
            if (Hyprland.monitorFor(s.modelData) === monitor)
                return s;
        return null;
    }

    function drawerFor(screen, name) {
        for (const d of root.registry)
            if (d.screen === screen && d.name === name)
                return d;
        return null;
    }

    // `screen` defaults to whichever monitor is focused, which is what a keybind
    // wants. The bar passes its own screen, because a click on one monitor has no
    // business opening a drawer on another.
    function set(name, screen, wanted) {
        const target = screen ?? undefined;
        const state = target === undefined ? forActive() : forScreen(target);
        if (!state)
            return false;

        const drawer = drawerFor(state.modelData, name);
        if (!drawer)
            return false;

        const slot = drawer.reserves ? "panel" : "overlay";
        const isOpen = state[slot] === name;
        const next = wanted === undefined ? !isOpen : wanted;

        if (next)
            state[slot] = name;
        else if (isOpen)
            state[slot] = "";

        return true;
    }

    function toggle(name, screen) {
        return set(name, screen, undefined);
    }

    // Notifications and the like need to open without the toggle semantics.
    function open(name, screen) {
        return set(name, screen, true);
    }

    function dismiss(name, screen) {
        return set(name, screen, false);
    }

    function closeAll(screen) {
        const state = screen === undefined ? forActive() : forScreen(screen);
        if (!state)
            return false;

        state.overlay = "";
        state.panel = "";
        return true;
    }

    Variants {
        id: states

        model: Quickshell.screens

        DrawerState {}
    }
}
