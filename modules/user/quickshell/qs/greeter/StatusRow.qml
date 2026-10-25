import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.components
import qs.modules

// The corner readout: which machine this is, and how much charge it has.
//
// The battery used to be text parsed out of /sys/class/power_supply/BAT1 —
// deliberately, to keep UPower out of a process running as an unprivileged
// user. That was the wrong trade twice over: UPower's properties are readable
// by anyone on the system bus, so there was nothing to avoid, and a battery
// spelled "bat 100%" in 11px muted text in a corner is a battery nobody sees.
// Battery is the bar's own chip, so the login screen now reports charge the
// same way the desktop does.
Row {
    id: root

    property string host: ""

    spacing: 12

    DetailText {
        anchors.verticalCenter: parent.verticalCenter

        text: root.host
        visible: root.host !== ""
    }

    DetailText {
        anchors.verticalCenter: parent.verticalCenter

        text: "·"
        opacity: 0.35
        visible: root.host !== "" && battery.visible
    }

    Battery {
        id: battery

        anchors.verticalCenter: parent.verticalCenter
    }

    FileView {
        id: hostname

        path: "/etc/hostname"

        onLoaded: root.host = hostname.text().trim()
    }
}
