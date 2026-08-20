pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs

Rectangle {
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

    readonly property int inset: Style.s.gap[0]

    implicitWidth: row.implicitWidth + inset * 2
    implicitHeight: Style.s.height.barControl

    radius: Style.r.chip
    color: Style.c.bg.rest
    border.width: Style.s.strokeHair
    border.color: Style.c.hairline.chip

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: root.inset + 1

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

                implicitWidth: content.implicitWidth + Style.s.gap[3] * 2
                implicitHeight: Style.s.height.rowAction
                radius: Style.r.chip

                // `occupied` borrows the 8% neutral rung rather than naming a
                // hover state: the pill sits on the 6% container and needs to
                // separate from it. 8% is the only neutral fill above rest.
                color: focused ? Style.c.accent.secondary.active : urgent ? Style.c.accent.primary.active : occupied ? Style.c.bg.hover : "transparent"

                border.width: Style.s.strokeHair
                border.color: focused ? Style.c.accent.secondary.line : urgent ? Style.c.accent.primary.line : "transparent"

                // Glow behind the current workspace
                Repeater {
                    model: 4

                    Rectangle {
                        required property int index

                        anchors.centerIn: parent

                        width: pill.width + (index + 1) * 4
                        height: pill.height + (index + 1) * 4
                        radius: pill.radius + (index + 1) * 2
                        z: -1

                        color: "transparent"
                        border.width: 2
                        border.color: Qt.alpha(Style.c.accent.secondary.fill, 0.28 * Math.pow(1 - index / 4, 2))

                        opacity: pill.focused ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Style.m.dur.state
                            }
                        }
                    }
                }

                Item {
                    anchors.fill: parent
                    clip: true

                    Item {
                        id: content

                        anchors.centerIn: parent

                        implicitWidth: pill.wsName ? label.implicitWidth : dot.implicitWidth
                        implicitHeight: pill.wsName ? label.implicitHeight : dot.implicitHeight

                        Rectangle {
                            id: dot

                            anchors.centerIn: parent

                            implicitWidth: 5
                            implicitHeight: 5
                            radius: 2.5

                            visible: !pill.wsName
                            color: pill.focused ? Style.c.accent.secondary.text : pill.urgent ? Style.c.status.critical : pill.occupied ? Style.c.text.secondary : Style.c.text.absent

                            Behavior on color {
                                ColorAnimation {
                                    duration: Style.m.dur.state
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
                }

                // Lozenge stretch — the one 220ms case.
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Style.m.dur.open
                        easing.bezierCurve: Style.m.ease
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Style.m.dur.state
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -(Style.s.height.bar - parent.height) / 2
                    anchors.bottomMargin: anchors.topMargin

                    cursorShape: Qt.PointingHandCursor
                    // Dispatching to a slot that does not exist yet is exactly
                    // right — Hyprland creates it.
                    onClicked: Hyprland.dispatch(`workspace ${pill.modelData}`)
                }
            }
        }
    }
}
