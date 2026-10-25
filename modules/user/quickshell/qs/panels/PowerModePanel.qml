import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

Panel {
    id: root

    name: "powermode"

    // Matches the notification centre and the bluetooth panel, so the right
    // edge keeps one width whichever of the three is sitting on it.
    depth: 420

    ColumnLayout {
        anchors.fill: parent

        spacing: Style.gap

        TitleText {
            text: "power mode"
            font.pixelSize: 13
        }

        Text {
            Layout.fillWidth: true
            Layout.bottomMargin: 2

            text: PowerMode.label.toUpperCase()

            color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.42)
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeLabel
            font.letterSpacing: 0.7
            elide: Text.ElideRight
        }

        // A Repeater rather than a ListView: there are three profiles at most,
        // so there is nothing to recycle and nothing to scroll.
        Repeater {
            model: PowerMode.profiles

            delegate: PowerModeRow {
                id: entry

                required property var modelData

                Layout.fillWidth: true

                profile: entry.modelData.profile
                name: entry.modelData.name
                icon: entry.modelData.icon
            }
        }

        Item {
            Layout.fillHeight: true
        }

        DetailText {
            Layout.fillWidth: true

            visible: PowerMode.degraded

            text: "Throttled by firmware: " + PowerMode.degradation
            color: Style.danger
            wrapMode: Text.Wrap
        }
    }
}
