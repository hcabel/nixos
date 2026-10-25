pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// The default sink, and the one place that writes to it. Both the bar chip and
// the OSD read from here rather than each holding a tracker of their own.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted ?? false

    readonly property real step: 0.05

    // volume and muted are writable on the node, so none of this needs an
    // external mixer command.
    function setVolume(v) {
        if (!root.sink?.audio)
            return;

        root.sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function nudge(delta) {
        root.setVolume(root.volume + delta * root.step);
    }

    function toggleMute() {
        if (!root.sink?.audio)
            return;

        root.sink.audio.muted = !root.sink.audio.muted;
    }

    // Without this the node's audio properties are never bound and the volume
    // stays at whatever it read on startup.
    PwObjectTracker {
        objects: [root.sink]
    }
}
