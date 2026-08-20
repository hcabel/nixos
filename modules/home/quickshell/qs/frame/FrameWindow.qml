pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.bar
import qs
import qs.drawers
import "Geometry.js" as Geometry

PanelWindow {
    id: root

    // Animated by the parent
    required property var insets
    required property var drawers
    required property real fsAnimation

    readonly property DrawerState state: Drawers.forScreen(screen)

    // Draw 1 overlay
    readonly property var overlayRect: {
        for (let i = 0; i < drawers.length; i++) {
            const d = drawers[i];
            if (!d.fullEdge && d.progress > 0)
                return Geometry.bodyRect(width, height, insets, d);
        }
        return Geometry.rect(0, 0, 0, 0);
    }

    visible: fsAnimation < 1

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:bar"
    WlrLayershell.keyboardFocus: state?.overlay ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    color: "transparent"

    // Prevents fullscreen click capture. The mask is rectangular, so corner rounding is ignored
    mask: Region {
        width: root.width
        height: root.height

        Region {
            x: root.insets.left
            y: root.insets.top
            width: root.width - root.insets.left - root.insets.right
            height: root.height - root.insets.top - root.insets.bottom
            intersection: Intersection.Subtract
        }

        // Click on overlay are not ignored
        Region {
            x: root.overlayRect.x
            y: root.overlayRect.y
            width: root.overlayRect.width
            height: root.overlayRect.height
        }
    }

    // Clicking outside dismisses an overlay (do not include panels)
    HyprlandFocusGrab {
        windows: [root]
        active: root.state?.overlay ?? false

        onCleared: {
            if (root.state)
                root.state.overlay = "";
        }
    }

    // Corner radius of the hole. Collapses along with the frame on fullscreen.
    readonly property real corner: Style.r.window * (1 - fsAnimation)

    // The inner boundary pushed `k` px out into the chrome. Everything that
    // traces the edge — the shadow bands, the hairline — is this at some k, so
    // they all follow the drawers for free.
    function ringPath(k) {
        const off = Geometry.offsetBoundary(insets, Geometry.detours(width, height, insets, drawers), corner, k);

        return Geometry.boundaryPath(width, height, off.insets, off.detours, off.corner);
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: Style.c.bg.glass
            strokeWidth: -1

            PathSvg {
                path: Geometry.framePath(
                    root.width,
                    root.height,
                    root.insets,
                    Geometry.detours(
                        root.width,
                        root.height,
                        root.insets,
                        root.drawers
                    ),
                    root.corner
                )
            }
        }
    }

    // The shadow the inset casts onto the chrome, as concentric bands walking
    // outward from the boundary with a quadratic falloff. Band i is stroked at
    // k = step * (i + 0.5) with width `step`, so the innermost one's inner lip
    // lands exactly on the boundary and nothing bleeds into the window area.
    //
    // A blur would need an offscreen pass over a full-screen surface; this is
    // the same falloff for the cost of a few stroked paths. It has no direction,
    // so it reads as ambient rather than cast from above.
    Repeater {
        model: Style.s.shadowBands

        Shape {
            id: band

            required property int index

            // Bands are spaced `step` apart but drawn twice that wide, so they
            // overlap instead of butting up: butt joints leave antialiasing
            // seams, and seams in a gradient are exactly the contour lines this
            // is trying to avoid. The alpha is divided back out by the same
            // factor so the overlap doesn't double the shadow.
            readonly property real overlap: 2
            readonly property real step: Style.e.e2.blur / Style.s.shadowBands
            // Gaussian, and halved: a blurred edge only ever shows half its
            // nominal alpha on the outside, because the other half falls inside
            // the shape. Skipping that is what makes hand-rolled shadows read
            // as a black outline instead of a shadow.
            readonly property real falloff: 0.5 * Math.exp(-Math.pow(2 * (index + 0.5) / Style.s.shadowBands, 2)) / overlap

            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.alpha(Style.e.e2.color, Style.e.e2.color.a * band.falloff)
                strokeWidth: band.step * band.overlap

                PathSvg {
                    path: root.ringPath(band.step * (band.index + 0.5))
                }
            }
        }
    }

    // The hairline that terminates the inset. Half a pixel out, so all of it
    // sits on the chrome rather than straddling the window.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Style.c.hairline.base
            strokeWidth: 1

            PathSvg {
                path: root.ringPath(0.5)
            }
        }
    }

    // The chrome is lit from above: the same hairline along the very top of the
    // screen, which is what stops the rail reading as a flat block.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 1
        color: Style.c.hairline.base
    }

    TopBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        screen: root.screen
        insets: root.insets
    }

    Repeater {
        model: root.drawers

        Item {
            id: body

            required property Drawer modelData

            readonly property bool horizontal: modelData.edge === "top" || modelData.edge === "bottom"
            readonly property var rect: Geometry.bodyRect(root.width, root.height, root.insets, modelData)

            x: rect.x
            y: rect.y
            width: rect.width
            height: rect.height

            visible: modelData.progress > 0 || modelData.open
            opacity: modelData.progress
            clip: true

            Loader {
                id: loader

                active: body.modelData.open || body.modelData.progress > 0
                sourceComponent: body.modelData.content

                anchors.top: body.modelData.edge === "top" ? parent.top : undefined
                anchors.bottom: body.modelData.edge === "bottom" ? parent.bottom : undefined
                anchors.left: body.modelData.edge === "left" ? parent.left : undefined
                anchors.right: body.modelData.edge === "right" ? parent.right : undefined
                anchors.horizontalCenter: body.horizontal ? parent.horizontalCenter : undefined
                anchors.verticalCenter: body.horizontal ? undefined : parent.verticalCenter
                anchors.margins: body.modelData.padding
            }

            Binding {
                target: body.modelData
                property: "measuredDepth"
                value: (body.horizontal ? loader.implicitHeight : loader.implicitWidth) + body.modelData.padding * 2
                when: loader.active
            }

            Binding {
                target: body.modelData
                property: "measuredBreadth"
                value: (body.horizontal ? loader.implicitWidth : loader.implicitHeight) + body.modelData.padding * 2
                when: loader.active
            }
        }
    }
}
