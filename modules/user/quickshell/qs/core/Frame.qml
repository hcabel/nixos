import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property alias panels: panelHost.data

    // The resting insets, grown by every panel sitting on each edge.
    function grow(depthOf) {
        const out = {
            top: Style.insets.top,
            right: Style.insets.right,
            bottom: Style.insets.bottom,
            left: Style.insets.left
        };
        const cs = panelHost.children;

        for (let i = 0; i < cs.length; i++)
            out[cs[i].edge] += depthOf(cs[i]);

        return out;
    }

    // What gets painted, and what the compositor is told. They differ: the
    // exclusive zone snaps to full depth so Hyprland reflows immediately and
    // animates the windows itself, while the chrome slides.
    readonly property var insets: root.grow(p => p.liveDepth)
    readonly property var reserved: root.grow(p => p.targetDepth)

    // The screen rectangle, then the viewport walked clockwise. Both subpaths
    // come out of one string so they land in one OddEvenFill ShapePath: the
    // outer encloses, the inner cuts the hole.
    function viewportPath(w, h, ins, corner) {
        const screen = `M0,0 H${w} V${h} H0 Z`;

        const l = ins.left;
        const t = ins.top;
        const r = w - ins.right;
        const b = h - ins.bottom;

        if (r - l < 2 || b - t < 2)
            return screen;

        const c = Math.max(0, Math.min(corner, (r - l) / 2, (b - t) / 2));

        return `${screen} M${l + c},${t} H${r - c} A${c},${c} 0 0 1 ${r},${t + c} V${b - c} A${c},${c} 0 0 1 ${r - c},${b} H${l + c} A${c},${c} 0 0 1 ${l},${b - c} V${t + c} A${c},${c} 0 0 1 ${l + c},${t} Z`;
    }

    function panelOn(edge) {
        const cs = panelHost.children;

        for (let i = 0; i < cs.length; i++) {
            if (cs[i].edge === edge && cs[i].open)
                return cs[i];
        }

        return null;
    }

    // Keyboard focus is requested from the compositor only while a panel
    // that needs it (eg. AppLauncher's search box) is actually open, so the
    // chrome surface never steals input from the rest of the desktop. It is
    // taken exclusively: OnDemand would wait for a click on the surface, which
    // means a launcher opened from a keybind would never receive the keystrokes
    // it was opened to collect.
    function keyboardWanted() {
        const cs = panelHost.children;

        for (let i = 0; i < cs.length; i++) {
            if (cs[i].open && cs[i].wantsFocus)
                return true;
        }

        return false;
    }

    readonly property bool needsKeyboard: root.keyboardWanted()

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:frame"
    WlrLayershell.keyboardFocus: root.needsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Chrome takes no clicks; an open panel does. Three regions because one
    // panel per side is all there can ever be.
    mask: Region {
        PanelMask {
            edge: "right"
        }

        PanelMask {
            edge: "bottom"
        }

        PanelMask {
            edge: "left"
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Style.surface
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill

            PathSvg {
                path: root.viewportPath(root.width, root.height, root.insets, Style.corner)
            }
        }
    }

    // Above the chrome, below the shadow: a panel sits at rail level, under the
    // viewport plate, so the contact shadow falls across its inner edge.
    Item {
        id: panelHost

        anchors.fill: parent

        readonly property var insets: root.insets
    }

    RailShadow {
        anchors.fill: parent

        insets: root.insets
    }

    component PanelMask: Region {
        required property string edge

        readonly property Item panel: root.panelOn(edge)

        x: panel ? panel.x : 0
        y: panel ? panel.y : 0
        width: panel ? panel.width : 0
        height: panel ? panel.height : 0
    }
}
