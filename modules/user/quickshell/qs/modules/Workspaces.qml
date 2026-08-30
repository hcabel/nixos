import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.components

Item {
    id: root

    required property ShellScreen screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
    readonly property int activeId: root.monitor?.activeWorkspace?.id ?? -1

    // Null until Hyprland has actually created the workspace, which it only
    // does on first use — every slot is drawn regardless.
    function workspaceFor(id) {
        return Hyprland.workspaces.values.find(w => w.id === id) ?? null;
    }

    readonly property real beadSize: 8
    readonly property real pillWidth: 26
    readonly property real glowBlur: 10
    readonly property real glowOpacity: 0.6

    // Text needs more alpha than a dot to stay legible at the same weight.
    readonly property real dotEmpty: 0.15
    readonly property real dotOccupied: 0.75
    readonly property real nameEmpty: 0.15
    readonly property real nameOccupied: 0.75

    implicitWidth: row.implicitWidth
    implicitHeight: Style.insets.top

    RowLayout {
        id: row

        anchors.fill: parent

        // The slots pad themselves so their hit areas tile edge to edge.
        spacing: 0

        Repeater {
            model: Style.workspaceCount

            delegate: Item {
                id: slot

                required property int index

                readonly property int number: slot.index + 1
                readonly property var ws: root.workspaceFor(slot.number)
                readonly property bool active: slot.number === root.activeId
                readonly property bool occupied: (slot.ws?.toplevels?.values?.length ?? 0) > 0

                readonly property string label: Style.workspaceNames[slot.number] ?? ""
                readonly property bool named: slot.label !== ""

                function shade(empty, full) {
                    return Qt.rgba(Style.text.r, Style.text.g, Style.text.b, slot.occupied ? full : empty);
                }

                // Full strip height, so a 7px bead is still comfortably clickable.
                Layout.fillHeight: true

                implicitWidth: (slot.named ? nameForm.width : beadForm.width) + Style.gap

                Item {
                    id: beadForm

                    anchors.centerIn: parent

                    visible: !slot.named

                    width: slot.active ? root.pillWidth : root.beadSize
                    height: root.beadSize

                    Behavior on width {
                        NumberAnimation {
                            duration: Style.duration
                            easing.type: Easing.OutCubic
                        }
                    }

                    RectangularShadow {
                        anchors.fill: bead

                        radius: bead.radius
                        blur: root.glowBlur
                        spread: 0
                        offset: Qt.vector2d(0, 0)
                        color: Style.accent

                        opacity: slot.active ? root.glowOpacity : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Style.duration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Rectangle {
                        id: bead

                        anchors.fill: parent

                        radius: 4
                        color: slot.active ? Style.accent : slot.shade(root.dotEmpty, root.dotOccupied)

                        Behavior on color {
                            ColorAnimation {
                                duration: Style.duration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Item {
                    id: nameForm

                    anchors.centerIn: parent

                    visible: slot.named

                    width: name.implicitWidth
                    height: name.implicitHeight

                    Text {
                        id: name

                        anchors.fill: parent

                        text: slot.label
                        color: slot.active ? Style.accent : slot.shade(root.nameEmpty, root.nameOccupied)

                        visible: false

                        Behavior on color {
                            ColorAnimation {
                                duration: Style.duration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MultiEffect {
                        anchors.fill: name

                        source: name
                        autoPaddingEnabled: true

                        shadowEnabled: true
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                        shadowBlur: 1.0
                        blurMax: 24
                        shadowColor: Style.accent
                        shadowOpacity: slot.active ? root.glowOpacity : 0

                        Behavior on shadowOpacity {
                            NumberAnimation {
                                duration: Style.duration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                // dispatch rather than ws.activate(): a workspace Hyprland has
                // not created yet has no object to activate.
                TapHandler {
                    onTapped: Hyprland.dispatch("workspace " + slot.number)
                }
            }
        }
    }
}
