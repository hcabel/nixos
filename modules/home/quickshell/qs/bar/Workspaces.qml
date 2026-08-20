pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs

RowLayout {
    id: root

    required property ShellScreen screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    // Most common workspace are always present (4-7), then we show all the worspace in between the common and the used ones
    readonly property var slots: {
        const used = Hyprland.workspaces.values
            .filter(w => w.monitor === monitor && w.id > 0 && (w.toplevels.values.length > 0 || w.focused || w.urgent))
            .map(w => w.id);

        // Always show 4-7, even if they are not used
        const lo = Math.min(4, ...used);
        const hi = Math.max(7, ...used);

        const out = [];
        for (let i = lo; i <= hi; i++)
            out.push(i);

        return out;
    }

    implicitWidth: row.implicitWidth + inset * 2
    implicitHeight: Style.s.height.barControl
    spacing: Style.s.gap[3]

    Repeater {
      model: root.slots

      Rectangle {
        id: pill

        required property int modelData

        readonly property HyprlandWorkspace ws: Hyprland.workspaces.values.find(w => w.id === pill.modelData && w.monitor === root.monitor) ?? null

        readonly property string wsName: ["", "", "", "", "web", "code", "", "chat"][modelData] ?? ""
        readonly property bool focused: ws?.focused ?? false
        readonly property bool urgent: (ws?.urgent ?? false) && !focused
        readonly property bool occupied: (ws?.toplevels.values.length ?? 0) > 0

        implicitWidth: content.implicitWidth
        implicitHeight: Style.s.height.rowAction

        color: "transparent"

          Item {
            id: content
            clip: true
            anchors.fill: parent

            implicitWidth: pill.wsName ? label.implicitWidth : dot.implicitWidth
            implicitHeight: pill.wsName ? label.implicitHeight : dot.implicitHeight

            Rectangle {
              id: dot

              anchors.centerIn: parent

              implicitWidth: pill.focused ? 26 : 8
              implicitHeight: 8

              bottomLeftRadius: Style.r.signatureCompact.bottomLeft
              bottomRightRadius: 0
              topLeftRadius: 0
              topRightRadius: Style.r.signatureCompact.topRight

              visible: !pill.wsName
              color: pill.focused ? Style.c.accent.secondary.text : pill.urgent ? Style.c.status.critical : pill.occupied ? Style.c.text.secondary : Style.c.text.absent

              Behavior on color {
                ColorAnimation {
                  duration: Style.m.dur.state
                }
              }

              // Lozenge stretch — the one 220ms case.
              Behavior on implicitWidth {
                NumberAnimation {
                  duration: Style.m.dur.open
                  easing.bezierCurve: Style.m.ease
                }
              }

            }

            // Show name if any otherwise show a dot
            StyledText {
              id: label

              anchors.centerIn: parent

              visible: pill.wsName
              text: pill.wsName

              font.weight: pill.focused ? Style.font.weight.bold : Style.font.weight.regular
              color: pill.focused ? Style.c.accent.secondary.text : pill.urgent ? Style.c.status.critical : pill.occupied ? Style.c.text.body : Style.c.text.absent

              Behavior on color {
                ColorAnimation {
                  duration: Style.m.dur.state
                }
              }
            }
        }

        // MouseArea {
        //   anchors.fill: parent
        //   anchors.topMargin: -(Style.s.height.bar - parent.height) / 2
        //   anchors.bottomMargin: anchors.topMargin

        //   cursorShape: Qt.PointingHandCursor
        //   // Dispatching to a slot that does not exist yet is exactly
        //   // right — Hyprland creates it.
        //   onClicked: Hyprland.dispatch(`workspace ${pill.modelData}`)
        // }
      }
    }
}
