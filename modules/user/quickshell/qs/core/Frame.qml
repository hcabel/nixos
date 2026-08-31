import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property alias panels: panelHost.data
    property alias tabs: tabHost.data

    property alias barLeft: bar.leftContent
    property alias barCenter: bar.centerContent
    property alias barRight: bar.rightContent

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

    function panelOn(edge) {
        const cs = panelHost.children;

        for (let i = 0; i < cs.length; i++) {
            if (cs[i].edge === edge && cs[i].open)
                return cs[i];
        }

        return null;
    }

    // The open tabs, in declaration order. The mask below needs them by index
    // because a Region is a plain QObject, so no Repeater can populate it.
    function openTabs() {
        const cs = tabHost.children;
        const out = [];

        for (let i = 0; i < cs.length; i++) {
            if (cs[i].open)
                out.push(cs[i]);
        }

        return out;
    }

    function tabAt(slot) {
        const on = root.openTabs();

        return slot < on.length ? on[slot] : null;
    }

    // Keyboard focus is requested from the compositor only while a panel
    // that needs it (eg. AppLauncher's search box) is actually open, so the
    // chrome surface never steals input from the rest of the desktop. It is
    // taken exclusively: OnDemand would wait for a click on the surface, which
    // means a launcher opened from a keybind would never receive the keystrokes
    // it was opened to collect.
    function keyboardWanted() {
        const hosts = [panelHost.children, tabHost.children];

        for (let h = 0; h < hosts.length; h++) {
            for (let i = 0; i < hosts[h].length; i++) {
                if (hosts[h][i].open && hosts[h][i].wantsFocus)
                    return true;
            }
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

        BarMask {
            slot: bar.slots[0]
        }

        BarMask {
            slot: bar.slots[1]
        }

        BarMask {
            slot: bar.slots[2]
        }

        TabMask {
            slot: 0
        }

        TabMask {
            slot: 1
        }

        TabMask {
            slot: 2
        }

        TabMask {
            slot: 3
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Style.surfaceTranslucent
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill

            PathSvg {
                path: RailPath.plate(root.width, root.height, root.insets, Style.corner, tabHost.children)
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

    // Tabs sit alongside panels and get the same treatment, but deliberately
    // outside panelHost: grow() sums every child it finds there, so a tab in
    // that host would reserve edge depth it is not supposed to have.
    Item {
        id: tabHost

        anchors.fill: parent

        readonly property var insets: root.insets
    }

    RailShadow {
        anchors.fill: parent

        insets: root.insets
        tabs: tabHost.children
    }

    // Last so the rail shadow does not wash over the bar's contents
    Bar {
        id: bar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: root.insets.top
    }

    component PanelMask: Region {
        required property string edge

        readonly property Item panel: root.panelOn(edge)

        x: panel ? panel.x : 0
        y: panel ? panel.y : 0
        width: panel ? panel.width : 0
        height: panel ? panel.height : 0
    }

    // Fixed slots rather than one per tab: Region is a plain QObject, so it
    // cannot be produced by a Repeater. A slot with no tab collapses to zero.
    component TabMask: Region {
        required property int slot

        readonly property Item tab: root.tabAt(slot)

        x: tab ? tab.x : 0
        y: tab ? tab.y : 0
        width: tab ? tab.width : 0
        height: tab ? tab.height : 0
    }

    // Sound without mapToItem only because the bar sits at the window origin,
    // which makes a slot's own coordinates window coordinates already.
    component BarMask: Region {
        required property Item slot

        x: bar.x + slot.x
        y: bar.y + slot.y
        width: slot.width
        height: slot.height
    }
}
