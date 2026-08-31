pragma Singleton

import Quickshell

Singleton {
    id: root

    property var opened: ({})

    function isOpen(name) {
        return root.opened[name] === true;
    }

    function open(name) {
        if (root.isOpen(name))
            return;

        // Tabs are mutually exclusive: every one of them sits centred on the
        // same edge, so a second open tab would draw straight over the first.
        const next = {};

        next[name] = true;
        root.opened = next;
    }

    function close(name) {
        if (!root.isOpen(name))
            return;

        const next = Object.assign({}, root.opened);

        delete next[name];
        root.opened = next;
    }

    function toggle(name) {
        if (root.isOpen(name))
            root.close(name);
        else
            root.open(name);
    }
}
