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
}
