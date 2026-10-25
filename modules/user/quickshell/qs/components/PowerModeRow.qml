import QtQuick
import QtQuick.Layouts
import qs.core

// One power profile. The whole row is the control — tapping it asks for that
// profile — and the dot on the right says which one the daemon is actually on,
// which is not always the one last asked for.
Rectangle {
    id: root

    required property int profile
    required property string name
    required property string icon

    readonly property bool selected: PowerMode.profile === root.profile

    readonly property bool hovered: hover.hovered

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
        onTapped: PowerMode.set(root.profile)
    }

    RowLayout {
        id: pad

        anchors.fill: parent
        anchors.margins: 10

        spacing: Style.gap + 1

        // Lit for the profile in force, the same way BluetoothRow's rail reads
        // for a device that is actually up.
        Rectangle {
            Layout.fillHeight: true

            implicitWidth: 2

            radius: 1
            color: root.selected ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.14)

            Behavior on color {
                ColorAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter

            text: root.icon

            color: root.selected ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.45)
            font.family: Style.fontFamily
            font.pixelSize: 13

            Behavior on color {
                ColorAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Takes the slack, so the dot below stays pinned to the right edge.
        Text {
            Layout.fillWidth: true

            text: root.name

            color: Style.text
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeDetail
            font.bold: root.selected
            elide: Text.ElideRight
        }

        // A ring always, filled only for the profile in force. The ring holds
        // its slot either way, so the name beside it never shifts.
        Rectangle {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth: 14
            implicitHeight: 14

            radius: width / 2
            color: "transparent"

            border.width: 1
            border.color: root.selected ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.25)

            Behavior on border.color {
                ColorAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.centerIn: parent

                implicitWidth: 8
                implicitHeight: 8

                radius: width / 2
                color: Style.accent

                opacity: root.selected ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.duration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
