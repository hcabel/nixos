pragma Singleton

import Quickshell
import Quickshell.Io
import qs.drawers

Singleton {
    id: root

    // The list of shortcuts the shell registrers (can be listed with: `hyprctl globalshortcuts`)
    readonly property var shortcuts: [
        "notifications",
        "closeAll",
        "applauncher"
    ]

    readonly property var actions: ({
        "notifications" : () => Drawers.toggle("controls"),
        "closeAll" : () => Drawers.closeAll(),
        "applauncher": () => Drawers.toggle("applauncher")
    })

    function invoke(name: string): bool {
        const action = root.actions[name];
        if (action)
            return action() !== false;

        console.warn("Shortcut not found: ", name);
        return false;
    }

    // Reachable from: `qs -c hcabel ipc call shell action <name>`
    IpcHandler {
        target: "shell"

        function action(name: string): bool {
            return root.invoke(name);
        }
    }
}
