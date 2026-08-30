pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var edges: ["right", "bottom", "left"]
    property var state: ({
        right: "",
        bottom: "",
        left: ""
    })

    function edgeOf(name) {
        if (name === "")
            return "";

        for (let i = 0; i < root.edges.length; i++) {
            if (root.state[root.edges[i]] === name)
                return root.edges[i];
        }

        return "";
    }

    function open(edge, name) {
        if (root.edges.indexOf(edge) === -1) {
            console.warn("Cannot open panel on edge:", edge);
            return;
        }

        const next = {};

        for (let i = 0; i < root.edges.length; i++) {
            const at = root.state[root.edges[i]];
            next[root.edges[i]] = at === name ? "" : at;
        }

        next[edge] = name;
        root.state = next;
    }

    function close(edge) {
        root.open(edge, "");
    }

    function toggle(edge, name) {
        const at = root.edgeOf(name);

        if (at !== "")
            root.close(at);
        else
            root.open(edge, name);
    }
}
