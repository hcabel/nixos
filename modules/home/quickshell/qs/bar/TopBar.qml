pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.drawers

Item {
    id: root

    required property ShellScreen screen
    required property var insets

    // Aligned against the inset so when a panel open top bar shrink
    readonly property int contentLeft: insets.left + Style.s.panelPad
    readonly property int contentRight: insets.right + Style.s.panelPad

    readonly property DrawerState state: Drawers.forScreen(screen)

    implicitHeight: Style.s.height.bar

    Clock {
        anchors.left: parent.left
        anchors.leftMargin: root.contentLeft
        anchors.verticalCenter: parent.verticalCenter

        screen: root.screen
    }

    Workspaces {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: (root.insets.left - root.insets.right) / 2
        anchors.verticalCenter: parent.verticalCenter

        screen: root.screen
    }

    // Tray, status icons and the recording indicator land here.
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: root.contentRight
        anchors.verticalCenter: parent.verticalCenter

        spacing: Style.s.gutter

        BarButton {
            text: "󰕮"

            active: root.state?.panel === "controls"
            onClicked: Drawers.toggle("controls", root.screen)
        }
    }
}
