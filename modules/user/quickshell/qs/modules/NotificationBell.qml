import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

Item {
    id: root

    readonly property int count: Notifications.count
    readonly property bool active: PanelState.edgeOf("notifications") !== ""

    implicitWidth: row.implicitWidth + Style.gap
    implicitHeight: Style.insets.top

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: 5

        Text {
            text: ""

            color: root.active || root.count > 0 ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.5)
            font.family: Style.fontFamily
            font.pixelSize: 12

            Behavior on color {
                ColorAnimation {
                    duration: Style.duration
                    easing.type: Easing.OutCubic
                }
            }
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

    TapHandler {
        onTapped: PanelState.toggle("right", "notifications")
    }
}
