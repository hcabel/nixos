pragma Singleton

import Quickshell
import Quickshell.Io

// The panel backlight, read from sysfs and written through logind.
Singleton {
    id: root

    // One laptop, one panel. A different machine changes this line.
    readonly property string device: "intel_backlight"
    readonly property string dir: "/sys/class/backlight/" + root.device

    property real max: 0
    property real raw: 0

    readonly property real value: root.max > 0 ? root.raw / root.max : 0

    readonly property real step: 0.05

    // A keypress should never be able to black the panel out entirely.
    readonly property real floor: 0.01

    // sysfs is root-owned, but logind lets the active session set its own
    // backlight: no udev rule, no video group, no setuid helper.
    function setValue(v) {
        if (root.max <= 0)
            return;

        const clamped = Math.max(root.floor, Math.min(1, v));

        Quickshell.execDetached(["busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", root.device, String(Math.round(clamped * root.max))]);
    }

    function nudge(delta) {
        root.setValue(root.value + delta * root.step);
    }

    FileView {
        id: ceiling

        path: root.dir + "/max_brightness"

        onLoaded: root.max = Number(ceiling.text().trim())
    }

    // Watched rather than polled, which also means brightness moved by anything
    // else lands here — including our own write, which is how `raw` catches up.
    FileView {
        id: current

        path: root.dir + "/brightness"
        watchChanges: true

        onFileChanged: current.reload()
        onLoaded: root.raw = Number(current.text().trim())
    }
}
