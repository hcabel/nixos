import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components

Panel {
    id: root

    name: "notifications"
    depth: 420

    ColumnLayout {
        anchors.fill: parent

        spacing: Style.gap

        RowLayout {
            Layout.fillWidth: true

            spacing: 9

            TitleText {
                text: "notifications"
                font.pixelSize: 13
            }

            Rectangle {
                visible: Notifications.count > 0

                implicitWidth: Math.max(18, total.implicitWidth + 12)
                implicitHeight: 18

                radius: 6
                color: Style.accent

                Text {
                    id: total

                    anchors.centerIn: parent

                    text: Notifications.count
                    color: Style.surface
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeLabel
                    font.bold: true
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Chip {
                text: "clear all"
                visible: Notifications.count > 0

                onClicked: Notifications.clearAll()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: 14
            boundsBehavior: Flickable.StopAtBounds

            model: Notifications.groups

            delegate: ColumnLayout {
                id: group

                required property var modelData

                width: ListView.view.width

                spacing: Style.gap

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 2

                    spacing: 9

                    Item {
                        implicitWidth: 16
                        implicitHeight: 16

                        readonly property string path: Quickshell.iconPath(group.modelData.icon, true)

                        IconImage {
                            anchors.fill: parent

                            asynchronous: true

                            visible: parent.path !== ""
                            source: parent.path
                        }

                        Rectangle {
                            anchors.fill: parent

                            visible: parent.path === ""

                            radius: 5
                            color: Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, 0.2)

                            Text {
                                anchors.centerIn: parent

                                text: (group.modelData.app || "?").charAt(0).toUpperCase()
                                color: Style.accent
                                font.family: Style.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: (group.modelData.app || "").toUpperCase()

                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.85)
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeDetail
                        font.bold: true
                        font.letterSpacing: 0.7
                    }

                    Rectangle {
                        implicitWidth: Math.max(16, tally.implicitWidth + 10)
                        implicitHeight: 15

                        radius: 5
                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.1)

                        Text {
                            id: tally

                            anchors.centerIn: parent

                            text: group.modelData.count
                            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.7)
                            font.family: Style.fontFamily
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Text {
                        text: group.modelData.collapsed ? "▸" : "▾"

                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.42)
                        font.family: Style.fontFamily
                        font.pixelSize: 12
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Notifications.since(group.modelData.at)

                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.42)
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeLabel
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: Notifications.toggleGroup(group.modelData.app)
                    }
                }

                Repeater {
                    model: group.modelData.collapsed ? [] : group.modelData.items

                    delegate: NotificationRow {
                        id: entry

                        required property var modelData

                        Layout.fillWidth: true

                        notification: entry.modelData

                        onDismissed: Notifications.dismiss(entry.modelData)
                    }
                }
            }
        }

        DetailText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            visible: Notifications.count === 0

            text: "Nothing to catch up on"
            horizontalAlignment: Text.AlignHCenter
        }

    }

    component Chip: Rectangle {
        id: chip

        property alias text: label.text

        signal clicked

        readonly property bool hovered: chipHover.hovered

        implicitWidth: label.implicitWidth + 18
        implicitHeight: 22

        radius: 7
        color: chip.hovered ? Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.12) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.06)

        border.width: 1
        border.color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.09)

        Behavior on color {
            ColorAnimation {
                duration: Style.duration
                easing.type: Easing.OutCubic
            }
        }

        HoverHandler {
            id: chipHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: chip.clicked()
        }

        Text {
            id: label

            anchors.centerIn: parent

            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeDetail
        }
    }
}
