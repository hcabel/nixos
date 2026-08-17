import QtQuick
import Quickshell
import qs.components
import qs
import qs.drawers

StyledText {
    id: root

    required property ShellScreen screen

    text: Qt.formatDateTime(clock.date, "ddd d   HH:mm")

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // Stands in for a real trigger until the dashboard holds something worth
    // opening; the point for now is that the drawer comes out under its own
    // button.
    MouseArea {
        anchors.fill: parent
        anchors.margins: -Style.padding

        cursorShape: Qt.PointingHandCursor
        onClicked: Drawers.toggle(Drawers.forScreen(root.screen), "dashboard", false)
    }
}
