// A drawer declaration. It draws nothing and it is not an Item — the frame reads
// these properties and folds them into its own boundary, so a drawer is a
// described change to the frame rather than something sitting on top of it. That
// is what lets the chrome stay a single filled path, which in turn is what makes
// a drawer look extruded out of the rail instead of stacked on it.
//
// Three axes, deliberately independent:
//
//   reserves  Does the compositor hear about it? true takes an exclusive zone
//             and pushes tiled windows aside; false floats over them.
//   fullEdge  Does it span its whole edge (the edge simply gets thicker), or is
//             it a local bump with rounded corners of its own and concave joins
//             back into the rail?
//   size      A positive depth/breadth pins that dimension. Zero means measure it
//             from the content, which is what anything with a variable amount to
//             show — notifications, search results, a calendar — actually needs.
//
// "Overlay" and "side panel" are two useful corners of that space. No part of the
// geometry treats them as different cases.

import QtQuick
import Quickshell
import qs.components
import qs

QtObject {
    id: root

    // `id` belongs to QML, so the slot key is `name`.
    required property string name

    // "top" | "right" | "bottom" | "left" — the same keys the inset objects use.
    property string edge: "top"

    property bool reserves: false
    property bool fullEdge: false

    // Position along the edge, 0..1, read left-to-right and top-to-bottom.
    property real align: 0.5

    // 0 means "measure from the content". Breathing room around that content.
    property int depth: 0
    property int breadth: 0
    property int padding: Style.s.panelPad

    // Written back by the frame once the content has been loaded and has a size.
    property int measuredDepth
    property int measuredBreadth

    readonly property int effectiveDepth: depth > 0 ? depth : measuredDepth
    readonly property int effectiveBreadth: breadth > 0 ? breadth : measuredBreadth

    property int rounding: Style.r.panel
    property int fillet: Style.s.fillet

    property ShellScreen screen
    property Component content

    Component.onCompleted: Drawers.register(root)
    Component.onDestruction: Drawers.unregister(root)

    readonly property DrawerState state: Drawers.forScreen(screen)
    readonly property bool open: state ? (reserves ? state.panel : state.overlay) === name : false

    // Everything visible is driven by this, never by `open` directly, so the
    // frame slides instead of snapping. The exclusive zone is the deliberate
    // exception — see Frame.qml.
    property real progress: open ? 1 : 0

    Behavior on progress {
        NumberAnimation {
            duration: Style.m.dur.open
            easing.type: Easing.OutCubic
        }
    }
}
