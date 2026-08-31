import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.core

Rectangle {
    id: root

    required property var notification

    readonly property bool critical: Notifications.isCritical(root.notification)
    readonly property color tint: Notifications.tintOf(root.notification)
    readonly property bool hovered: hover.hovered

    signal dismissed

    implicitHeight: pad.implicitHeight + Style.padding

    radius: Style.cornerSmall
    color: root.critical ? Qt.tint(Style.surfaceCard, Qt.rgba(Style.danger.r, Style.danger.g, Style.danger.b, 0.18)) : Style.surfaceCard

    border.width: 1
    border.color: root.critical ? Qt.rgba(Style.danger.r, Style.danger.g, Style.danger.b, 0.34) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.12)

    HoverHandler {
        id: hover
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton

        onTapped: Notifications.activate(root.notification)
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton

        onTapped: root.dismissed()
    }

    RowLayout {
        id: pad

        anchors.fill: parent
        anchors.margins: Style.padding / 2

        spacing: Style.gap + 4

        Item {
            Layout.fillHeight: true

            implicitWidth: 3

            RectangularShadow {
                anchors.fill: rail

                radius: rail.radius
                blur: 10
                spread: 0
                offset: Qt.vector2d(0, 0)
                color: Style.danger

                opacity: root.critical ? 0.8 : 0
            }

            Rectangle {
                id: rail

                anchors.fill: parent

                radius: 2
                color: root.tint
                opacity: root.critical ? 1 : 0.8
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                spacing: 9

                Text {
                    text: (root.notification?.appName || "unknown").toUpperCase()

                    color: root.tint
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeLabel
                    font.bold: true
                    font.letterSpacing: 1
                }

                Rectangle {
                    visible: root.critical

                    implicitWidth: tag.implicitWidth + 12
                    implicitHeight: 14

                    radius: 5
                    color: Qt.rgba(Style.danger.r, Style.danger.g, Style.danger.b, 0.2)

                    Text {
                        id: tag

                        anchors.centerIn: parent

                        text: "CRITICAL"
                        color: Style.danger
                        font.family: Style.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: Notifications.timeOf(root.notification)

                    color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.42)
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeLabel
                }
            }

            Text {
                Layout.fillWidth: true

                text: root.notification?.summary ?? ""

                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""
                text: root.notification?.body ?? ""

                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeDetail
                lineHeight: 1.35

                wrapMode: Text.Wrap
                maximumLineCount: 3
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
