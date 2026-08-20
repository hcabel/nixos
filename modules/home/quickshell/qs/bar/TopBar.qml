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
    readonly property int contentLeft: insets.left + Style.padding
    readonly property int contentRight: insets.right + Style.padding

    readonly property DrawerState state: Drawers.forScreen(screen)

    implicitHeight: Style.barHeight

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

        spacing: Style.gap

        BarButton {
            text: "󰕮"

            active: root.state?.panel === "controls"
            onClicked: Drawers.toggle("controls", root.screen)
        }
    }
}
