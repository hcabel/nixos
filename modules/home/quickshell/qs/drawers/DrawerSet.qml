pragma ComponentBehavior: Bound

import Quickshell

Scope {
    id: root

    required property ShellScreen screen

    readonly property list<Drawer> all: [controls, applauncher]

    Controls {
        id: controls
        screen: root.screen
    }

    Applauncher {
        id: applauncher
        screen: root.screen
    }
}
