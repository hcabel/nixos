import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

Panel {
    id: root

    name: "bluetooth"

    // Matches the notification centre, so the right edge keeps one width
    // whichever of the two is sitting on it.
    depth: 420

    // Scanning belongs to the panel: it is the only thing that wants devices
    // nobody has paired yet, and discovery left running costs power.
    onOpenChanged: Bluetooth.wantScan = root.open

    ColumnLayout {
        anchors.fill: parent

        spacing: Style.gap

        RowLayout {
            Layout.fillWidth: true

            spacing: 9

            TitleText {
                text: "bluetooth"
                font.pixelSize: 13
            }

            Item {
                Layout.fillWidth: true
            }

            Switch {
                Layout.alignment: Qt.AlignVCenter

                checked: Bluetooth.enabled
                busy: Bluetooth.busy

                onToggled: Bluetooth.toggle()
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.bottomMargin: 2

            text: Bluetooth.label.toUpperCase()

            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.42)
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeLabel
            font.letterSpacing: 0.7
            elide: Text.ElideRight
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: 14
            boundsBehavior: Flickable.StopAtBounds

            model: Bluetooth.sections

            delegate: ColumnLayout {
                id: section

                required property var modelData

                width: ListView.view.width

                spacing: Style.gap

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 2

                    spacing: 9

                    Text {
                        text: section.modelData.title.toUpperCase()

                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.85)
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeDetail
                        font.bold: true
                        font.letterSpacing: 0.7
                    }

                    Rectangle {
                        implicitWidth: Math.max(16, tally.implicitWidth + 10)
                        implicitHeight: 15

                        radius: 5
                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.1)

                        Text {
                            id: tally

                            anchors.centerIn: parent

                            text: section.modelData.items.length
                            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.7)
                            font.family: Style.fontFamily
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                Repeater {
                    model: section.modelData.items

                    delegate: BluetoothRow {
                        id: entry

                        required property var modelData

                        Layout.fillWidth: true

                        device: entry.modelData
                    }
                }
            }
        }

        DetailText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            visible: Bluetooth.sections.length === 0

            text: !Bluetooth.present ? "No adapter on this machine" : Bluetooth.blocked ? "The radio is blocked" : !Bluetooth.enabled ? "Bluetooth is off" : "Looking for devices"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}
