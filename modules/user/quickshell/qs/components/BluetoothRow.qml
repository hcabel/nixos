import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.core

// One device. The primary tap does whatever that device needs next, which
// Bluetooth.activate decides; the only separate control is forget, and it is
// hidden until the row is hovered.
Rectangle {
    id: root

    required property var device

    readonly property bool hovered: hover.hovered

    // Forget only means anything for a device BlueZ still remembers.
    readonly property bool known: root.device?.paired ?? false

    implicitHeight: pad.implicitHeight + 20

    radius: Style.cornerSmall
    color: root.hovered ? Qt.tint(Style.surfaceCard, Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.07)) : Style.surfaceCard

    Behavior on color {
        ColorAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: Bluetooth.activate(root.device)
    }

    RowLayout {
        id: pad

        anchors.fill: parent
        anchors.margins: 10

        spacing: Style.gap + 1

        // Lit only for a device that is actually up, the same way a
        // notification's urgency rail reads.
        Rectangle {
            Layout.fillHeight: true

            implicitWidth: 2

            radius: 1
            color: (root.device?.connected ?? false) ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.14)

            Behavior on color {
                ColorAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // BlueZ hands over a freedesktop icon name (audio-headset, input-mouse),
        // so this is the lookup the notification group header already does,
        // with a glyph standing in when the theme has nothing for it.
        Item {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth: 16
            implicitHeight: 16

            readonly property string path: Quickshell.iconPath(root.device?.icon ?? "", true)

            IconImage {
                anchors.fill: parent

                asynchronous: true

                visible: parent.path !== ""
                source: parent.path
            }

            Text {
                anchors.centerIn: parent

                visible: parent.path === ""

                text: "󰂯"
                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.45)
                font.family: Style.fontFamily
                font.pixelSize: 12
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 4

            Text {
                Layout.fillWidth: true

                text: root.device?.deviceName || root.device?.address || "unknown"

                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeDetail
                font.bold: true
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 7

                Text {
                    text: Bluetooth.statusOf(root.device)

                    color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeLabel
                    elide: Text.ElideRight
                }

                Meter {
                    Layout.alignment: Qt.AlignVCenter

                    visible: root.device?.batteryAvailable ?? false

                    value: Bluetooth.batteryOf(root.device)
                    fill: value <= 0.15 ? Style.danger : Style.accent
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        // Holds its slot whether or not the button is showing, so a hover does
        // not shift the name next to it.
        Item {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth: 18
            implicitHeight: 18

            visible: root.known

            Rectangle {
                anchors.fill: parent

                radius: 6
                opacity: root.hovered ? 1 : 0
                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.08)

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.duration
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: "✕"
                    color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
                    font.family: Style.fontFamily
                    font.pixelSize: 9
                }

                HoverHandler {
                    enabled: root.hovered

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    // A zero-opacity item still takes input.
                    enabled: root.hovered

                    onTapped: Bluetooth.forget(root.device)
                }
            }
        }
    }
}
