import QtQuick
import Quickshell
import qs.core
import qs.components

BarChip {
    id: root

    readonly property int count: Notifications.count

    // Notifications.qml keeps a clock of its own, but privately, so this one
    // ticks on its own account.
    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    interactive: true
    active: PanelState.edgeOf("notifications") !== ""

    onClicked: PanelState.toggle("right", "notifications")

    Text {
        text: Qt.formatDateTime(clock.date, "ddd dd MMM").toUpperCase()

        color: Style.textMuted
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeDetail
        font.letterSpacing: 0.8
    }

    Rectangle {
        implicitWidth: 1
        implicitHeight: 12

        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.12)
    }

    Text {
        text: Qt.formatDateTime(clock.date, "HH:mm")

        color: Style.text
        font.family: Style.fontFamily
        font.pixelSize: 13
        font.bold: true
        font.letterSpacing: 0.4
    }

    Rectangle {
        visible: root.count > 0

        implicitWidth: Math.max(14, badge.implicitWidth + 8)
        implicitHeight: 14

        radius: 5
        color: Style.accent

        Text {
            id: badge

            anchors.centerIn: parent

            text: root.count
            color: Style.surface
            font.family: Style.fontFamily
            font.pixelSize: 9
            font.bold: true
        }
    }
}
