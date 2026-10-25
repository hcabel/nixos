pragma Singleton

import QtQuick
import Quickshell

// Which of the two transient readouts the left rail is showing, and for how
// much longer. Named for PanelState and TabState, and to leave the plain name
// to the Osd tab that draws it.
Singleton {
    id: root

    property string kind: ""
    property bool showing: false

    readonly property real value: root.kind === "brightness" ? Backlight.value : Audio.volume
    readonly property bool muted: root.kind === "volume" && Audio.muted

    readonly property int linger: 1500

    function show(kind) {
        root.kind = kind;
        root.showing = true;
        timeout.restart();
    }

    // Watching the values rather than the keypress means the readout also
    // appears for a change made somewhere else entirely — a mixer, say.
    readonly property real volumeAt: Audio.volume
    readonly property bool mutedAt: Audio.muted
    readonly property real brightnessAt: Backlight.value

    onVolumeAtChanged: if (root.armed)
        root.show("volume")

    onMutedAtChanged: if (root.armed)
        root.show("volume")

    onBrightnessAtChanged: if (root.armed)
        root.show("brightness")

    // Pipewire and the backlight both resolve a moment after startup, and that
    // first settle is not a change worth announcing.
    property bool armed: false

    Timer {
        interval: 2000
        running: true

        onTriggered: root.armed = true
    }

    Timer {
        id: timeout

        interval: root.linger

        onTriggered: root.showing = false
    }
}
