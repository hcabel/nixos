import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components

// The fullscreen stand-in for the Osd tab. Same gauge, but on the overlay
// layer so a fullscreen client cannot cover it, and carried in from the bare
// screen edge rather than out of a rail that is not there.
PanelWindow {
    id: root

    // Set by whoever knows: true while a fullscreen window owns this screen.
    property bool fullscreen: false

    readonly property bool shown: root.fullscreen && OsdState.showing

    readonly property real depth: 31
    readonly property real length: 216

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
    }

    implicitWidth: root.depth

    color: "transparent"

    // Unmapped while idle rather than merely transparent: an overlay surface
    // sitting over a fullscreen window for no reason is exactly what stops
    // Hyprland handing that window direct scanout. The surface is held open
    // for one animation past `shown` so the plate has somewhere to slide back
    // out to — on a timer rather than on the plate's own x, which lands on its
    // resting value too imprecisely to test against.
    property bool lingering: false

    onShownChanged: {
        if (root.shown)
            root.lingering = true;
        else
            retire.restart();
    }

    visible: root.shown || root.lingering

    Timer {
        id: retire

        interval: Style.duration + 50

        onTriggered: root.lingering = false
    }

    // Chrome, not a surface to click: masking it would swallow clicks meant
    // for the fullscreen window underneath.
    mask: Region {}

    Rectangle {
        id: plate

        width: root.depth
        height: root.length

        x: root.shown ? 0 : -width
        y: (root.height - height) / 2

        color: Style.surfaceCard

        topRightRadius: Style.cornerSmall
        bottomRightRadius: Style.cornerSmall

        Behavior on x {
            NumberAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }

        OsdGauge {
            anchors.fill: parent
        }
    }
}
