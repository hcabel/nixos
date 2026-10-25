pragma Singleton

import Quickshell
import Quickshell.Bluetooth as Bluez

// The default adapter, and the one place that writes to it. The bar chip and
// the panel read from here rather than each tracking the adapter themselves,
// and the Bluez enums stay behind this file so the views never import them.
//
// The import is qualified because this singleton is itself called Bluetooth:
// an unqualified `Bluetooth` would be ambiguous between the two.
Singleton {
    id: root

    readonly property var adapter: Bluez.Bluetooth.defaultAdapter

    readonly property bool present: root.adapter !== null

    readonly property bool enabled: root.adapter?.enabled ?? false
    readonly property int state: root.adapter?.state ?? Bluez.BluetoothAdapterState.Disabled

    // An rfkill soft block survives reboots, and BlueZ refuses Powered=true
    // while the kill switch is down, so the switch has to clear it first.
    readonly property bool blocked: root.state === Bluez.BluetoothAdapterState.Blocked

    readonly property bool busy: root.state === Bluez.BluetoothAdapterState.Enabling || root.state === Bluez.BluetoothAdapterState.Disabling

    // The panel's status line. Named for the adapter when it is up, because
    // that is the only time the hardware's own name tells you anything.
    readonly property string label: root.blocked ? "blocked" : root.state === Bluez.BluetoothAdapterState.Enabling ? "turning on" : root.state === Bluez.BluetoothAdapterState.Disabling ? "turning off" : !root.present ? "no adapter" : root.enabled ? (root.adapter?.name ?? "on") : "off"

    readonly property var devices: root.adapter?.devices?.values ?? []

    readonly property var connected: root.devices.filter(d => d.connected)
    readonly property var paired: root.devices.filter(d => d.paired && !d.connected)

    // Nameless entries are passing beacons and advertising fobs: BlueZ reports
    // them the moment a scan hears one, and they would bury the real devices.
    readonly property var available: root.devices.filter(d => !d.paired && !d.connected && (d.deviceName ?? "") !== "")

    readonly property int connectedCount: root.connected.length

    // Built here rather than in the panel so the chip's badge and the list can
    // never disagree about what counts as connected. Empty sections drop out,
    // which is also how the panel knows to show its empty state.
    readonly property var sections: [
        {
            title: "connected",
            items: root.connected
        },
        {
            title: "paired",
            items: root.paired
        },
        {
            title: "available",
            items: root.available
        }
    ].filter(s => s.items.length > 0)

    // Cleared by the state change the unblock causes: `rfkill unblock` returns
    // long before the adapter leaves Blocked, so the Powered write has to wait
    // for it rather than fire straight after.
    property bool wantsEnable: false

    onBlockedChanged: {
        if (root.blocked || !root.wantsEnable)
            return;

        root.wantsEnable = false;

        if (root.adapter)
            root.adapter.enabled = true;
    }

    function setEnabled(on) {
        if (!root.adapter)
            return;

        // A soft block is a kernel kill switch, not a BlueZ property: Powered
        // against it just fails. /dev/rfkill carries a logind ACL for the
        // active session, so clearing it needs no privilege.
        if (on && root.blocked) {
            root.wantsEnable = true;
            Quickshell.execDetached(["rfkill", "unblock", "bluetooth"]);
            return;
        }

        root.wantsEnable = false;
        root.adapter.enabled = on;
    }

    function toggle() {
        root.setEnabled(!root.enabled);
    }

    // Discovery runs only while something asks for it — the panel sets this
    // when it opens — and only while the radio is on. Routed through
    // shouldScan because a powered-off adapter drops Discovering silently, so
    // a scan asked for too early has to be re-asserted on power-up.
    property bool wantScan: false

    readonly property bool shouldScan: root.wantScan && root.enabled

    onShouldScanChanged: {
        if (root.adapter)
            root.adapter.discovering = root.shouldScan;
    }

    // One entry point for a row's primary tap: what a device needs next is
    // always a function of the state it is already in.
    function activate(device) {
        if (!device)
            return;

        if (device.pairing)
            device.cancelPair();
        else if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    function forget(device) {
        if (device)
            device.forget();
    }

    // 0..1, for the row's Meter. Quickshell normalises battery the way it
    // normalises UPower's percentage, but a reading above 1 would mean whole
    // percent and would peg the gauge, so fold that case in.
    function batteryOf(device) {
        const raw = device?.battery ?? 0;

        return raw > 1 ? raw / 100 : raw;
    }

    function statusOf(device) {
        if (!device)
            return "";

        if (device.pairing)
            return "pairing";

        switch (device.state) {
        case Bluez.BluetoothDeviceState.Connecting:
            return "connecting";
        case Bluez.BluetoothDeviceState.Disconnecting:
            return "disconnecting";
        case Bluez.BluetoothDeviceState.Connected:
            return "connected";
        }

        // An unpaired device has no name worth repeating, so it gets its
        // address as the one thing that distinguishes it from its neighbours.
        return device.paired ? "paired" : device.address;
    }
}
