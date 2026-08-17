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

    readonly property int inset: 3

    implicitWidth: row.implicitWidth + inset * 2
    implicitHeight: row.implicitHeight + inset * 2

    radius: 10
    color: Qt.alpha(Style.text, Style.chromeFill)
    border.width: 1
    border.color: Qt.alpha(Style.text, Style.chromeBorder)

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

                implicitWidth: content.implicitWidth + Style.padding * 2
                implicitHeight: Style.barHeight - Style.padding * 2
                radius: 8

                color: focused ? Style.accentMid : urgent ? Qt.alpha(Style.red, 0.2) : occupied ? Qt.alpha(Style.text, Style.chromeFillStrong) : "transparent"

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
                        border.color: Qt.alpha(Style.accentMid, 0.28 * Math.pow(1 - index / 4, 2))

                        opacity: pill.focused ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Style.animFast
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
                            color: pill.focused ? Qt.alpha(Style.base, 0.8) : pill.urgent ? Style.red : pill.occupied ? Style.accent : Style.muted

                            Behavior on color {
                                ColorAnimation {
                                    duration: Style.animFast
                                }
                            }
                        }

                        // Show name if any otherwise show a dot
                        StyledText {
                            id: label

                            anchors.centerIn: parent

                            visible: pill.wsName
                            text: pill.wsName

                            font.weight: pill.focused ? Font.Bold : Font.Medium
                            color: pill.focused ? Style.accentInk : pill.urgent ? Style.red : pill.occupied ? Qt.alpha(Style.text, Style.chromeLabel) : Style.muted

                            Behavior on color {
                                ColorAnimation {
                                    duration: Style.animFast
                                }
                            }
                        }
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Style.animFast
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Style.animFast
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -(Style.barHeight - parent.height) / 2
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
