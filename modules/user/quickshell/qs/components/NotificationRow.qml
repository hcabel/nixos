import QtQuick
import QtQuick.Layouts
import qs.core

Rectangle {
    id: root

    required property var notification

    readonly property bool critical: Notifications.isCritical(root.notification)
    readonly property bool hovered: hover.hovered

    signal dismissed

    implicitHeight: pad.implicitHeight + 24

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
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton

        onTapped: root.dismissed()
    }

    RowLayout {
        id: pad

        anchors.fill: parent
        anchors.margins: 12

        spacing: Style.gap + 1

        Rectangle {
            Layout.fillHeight: true

            implicitWidth: 2

            radius: 1
            color: Notifications.tintOf(root.notification)
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 5

            RowLayout {
                Layout.fillWidth: true

                spacing: 9

                Text {
                    Layout.fillWidth: true

                    text: root.notification?.summary ?? ""

                    color: Style.text
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeDetail
                    font.bold: true
                    elide: Text.ElideRight
                }

                // The time and the dismiss button share one slot, sized to the
                // wider of the two so nothing shifts when the row is hovered.
                Item {
                    Layout.alignment: Qt.AlignVCenter

                    implicitWidth: Math.max(18, time.implicitWidth)
                    implicitHeight: 18

                    Text {
                        id: time

                        anchors.centerIn: parent

                        text: Notifications.timeOf(root.notification)
                        opacity: root.hovered ? 0 : 1

                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.28)
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeLabel

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Style.duration
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent

                        implicitWidth: 18
                        implicitHeight: 18

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

                        TapHandler {
                            // A zero-opacity item still takes input.
                            enabled: root.hovered

                            onTapped: root.dismissed()
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""
                text: root.notification?.body ?? ""

                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeDetail

                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            NotificationActions {
                Layout.fillWidth: true
                Layout.topMargin: 2

                notification: root.notification
            }
        }
    }
}
