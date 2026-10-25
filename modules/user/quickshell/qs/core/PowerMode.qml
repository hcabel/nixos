pragma Singleton

import Quickshell
import Quickshell.Services.UPower

// The active power profile, and the one place that writes it. The bar chip and
// the panel read from here rather than each reaching for the daemon, and the
// UPower enums stay behind this file so the views never import them.
//
// PowerProfiles.profile notifies, so a profile changed from anywhere else —
// powerprofilesctl, GNOME, a thermal event — lands here without a poll.
Singleton {
    id: root

    readonly property int profile: PowerProfiles.profile

    // A machine whose firmware offers no turbo has no performance profile to
    // give. The daemon still accepts the write; it just has nowhere to put it,
    // so the row comes off the list instead.
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile

    // Authored here rather than taken from PowerProfile.toString(), the same
    // way Bluetooth.label and Bluetooth.statusOf are written: these strings are
    // the panel's copy, and they should not shift under us if the binding's
    // own formatting changes.
    readonly property var all: [
        {
            profile: PowerProfile.PowerSaver,
            name: "power saver",
            icon: "󰌪"
        },
        {
            profile: PowerProfile.Balanced,
            name: "balanced",
            icon: "󰾅"
        },
        {
            profile: PowerProfile.Performance,
            name: "performance",
            icon: "󰓅"
        }
    ]

    // Built here rather than in the panel so the chip's glyph and the list's
    // selected row can never disagree about which profile is in force.
    readonly property var profiles: root.hasPerformance ? root.all : root.all.filter(e => e.profile !== PowerProfile.Performance)

    // The two bindings below track root.profile because they read it in the
    // argument — the call itself is not a dependency.
    function entryOf(p) {
        const found = root.all.filter(e => e.profile === p);

        return found.length > 0 ? found[0] : null;
    }

    readonly property string label: root.entryOf(root.profile)?.name ?? "unknown"
    readonly property string icon: root.entryOf(root.profile)?.icon ?? "󰾅"

    // Firmware is holding performance back. Worth surfacing because the profile
    // still reads as performance while the machine is not delivering it, which
    // otherwise looks like the setting did nothing.
    readonly property string degradation: PowerProfiles.degradationReason === PerformanceDegradationReason.LapDetected ? "lap detected" : PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature ? "high temperature" : ""

    readonly property bool degraded: root.degradation !== ""

    // Here so the chip can tint itself without importing PowerProfile.
    readonly property bool performing: root.profile === PowerProfile.Performance

    function set(p) {
        PowerProfiles.profile = p;
    }
}
