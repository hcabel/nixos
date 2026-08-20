pragma Singleton

// The whole hcabel.style tree from Nix, by way of ~/.config/quickshell/style.json.
// Adding a value in style.nix makes it appear here with no edit to this file —
// nothing below names an individual key.
//
//   Style.c.*     palette     Style.c.accent.primary.fill, Style.c.text.body
//   Style.s.*     sizes       Style.s.panelPad, Style.s.height.row, Style.s.gap[3]
//   Style.r.*     radius      Style.r.card, Style.r.signature.topRight
//   Style.m.*     motion      Style.m.dur.open, Style.m.ease
//   Style.e.*     elevation   Style.e.e1.blur, Style.e.glow.pink.color
//   Style.type.*  typography  Style.type.chromeName.size
//   Style.font.*  font        Style.font.mono
//   Style.all     everything else, e.g. Style.all.terminal.ansi
//
// Nothing else in the QML tree should hardcode a colour or a pixel count.
//
// Note: style.json is a symlink into the nix store. QFileSystemWatcher watches the
// resolved target, so a rebuild that changes only theming may not fire fileChanged;
// restart quickshell.service if a colour edit doesn't show up. Editing the QML
// itself is unaffected — those are real files in the repo.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // file.text() reads __text, so this binding re-runs whenever the file reloads.
    readonly property var all: root.parse(file.text())

    readonly property var c: root.all.palette ?? ({})
    readonly property var s: root.all.sizes ?? ({})
    readonly property var r: root.all.radius ?? ({})
    readonly property var m: root.all.motion ?? ({})
    readonly property var e: root.all.elevation ?? ({})
    readonly property var type: root.all.type ?? ({})
    readonly property var font: root.all.font ?? ({})

    function parse(src: string): var {
        try {
            return root.colorize(JSON.parse(src || "{}"));
        } catch (e) {
            // Deliberately no fallback palette — a second copy of every value is
            // exactly what this file used to be. Fail loud instead.
            console.error("Style: cannot parse style.json —", e);
            return ({});
        }
    }

    // JSON gives us "#aarrggbb" strings; Qt.alpha and friends want a real color.
    function colorize(v: var): var {
        if (typeof v === "string")
            return v.startsWith("#") ? Qt.color(v) : v;

        // Before the object branch: `for (const k in [])` would turn an array
        // into a plain object with numeric keys, and easing.bezierCurve needs a
        // real array. Applies to motion.ease and terminal.ansi.
        if (Array.isArray(v))
            return v.map(x => root.colorize(x));

        if (v && typeof v === "object") {
            const out = {};
            for (const k in v)
                out[k] = root.colorize(v[k]);
            return out;
        }

        return v;
    }

    FileView {
        id: file

        path: `${Quickshell.env("XDG_CONFIG_HOME") ?? `${Quickshell.env("HOME")}/.config`}/quickshell/style.json`

        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
