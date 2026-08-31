import QtQuick
import QtQuick.Layouts
import qs.core

RowLayout {
    id: root

    required property var notification

    readonly property var actions: Notifications.actionsOf(root.notification)
    readonly property bool persistent: Notifications.isPersistent(root.notification)
    readonly property color tint: Notifications.tintOf(root.notification)

    visible: root.actions.length > 0 || root.persistent

    spacing: 9

    Repeater {
        model: root.actions

        delegate: Rectangle {
            id: chip

            required property var modelData
            required property int index

            readonly property bool primary: chip.index === 0
            readonly property bool hovered: hover.hovered

            implicitWidth: label.implicitWidth + 24
            implicitHeight: 26

            radius: 8
            color: chip.primary ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, chip.hovered ? 0.32 : 0.22) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, chip.hovered ? 0.12 : 0.06)

            border.width: 1
            border.color: chip.primary ? Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.34) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.1)

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
                onTapped: Notifications.invoke(root.notification, chip.modelData)
            }

            Text {
                id: label

                anchors.centerIn: parent

                text: chip.modelData.text
                color: chip.primary ? Qt.lighter(root.tint, 1.3) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeDetail
                font.bold: chip.primary
            }
        }
    }

    Item {
        Layout.fillWidth: true
    }

    Text {
        visible: root.persistent

        text: "PERSISTENT"
        color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.6)
        font.family: Style.fontFamily
        font.pixelSize: 9
        font.letterSpacing: 0.4
    }
}
