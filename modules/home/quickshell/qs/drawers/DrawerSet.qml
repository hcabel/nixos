pragma ComponentBehavior: Bound

import Quickshell

Scope {
    id: root

    required property ShellScreen screen

    readonly property list<Drawer> all: [dashboard, controls]

    Dashboard { // Top bar overlay
        id: dashboard
        screen: root.screen
    }

    Controls { // Side panel
        id: controls
        screen: root.screen
    }
}
