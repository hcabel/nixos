import qs.core
import qs.components

// The transient readout for volume and brightness. A Tab rather than its own
// window, so RailPath carves it out of the same translucent plate as the rail
// it grows from, joins and all.
//
// The gauge itself is OsdGauge, shared with the overlay that stands in for this
// tab while a fullscreen window is covering the rail.
Tab {
    id: root

    name: "Osd"
    edge: "left"

    length: 216
    depth: 31

    // Tab pads uniformly; the gauge wants air at the ends only, and keeps that
    // inset itself.
    padding: 0

    open: OsdState.showing
    masked: false

    OsdGauge {
        anchors.fill: parent
    }
}
