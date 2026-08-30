import QtQuick
import QtQuick.Layouts
import qs.core

Panel {
    id: root

    name: "demo"

    GridLayout {
        anchors.fill: parent

        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

        rowSpacing: 8
        columnSpacing: 8

        Text {
            text: "Demo panel"

            color: Style.text
            font.family: Style.fontFamily
            font.pixelSize: 18
        }

        Repeater {
            model: 5

            Rectangle {

                implicitWidth: root.vertical ? 260 : 140
                implicitHeight: 64

                radius: 12
                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.13)
            }
        }

        Item {
            Layout.fillHeight: root.vertical
            Layout.fillWidth: !root.vertical
        }
    }
}
