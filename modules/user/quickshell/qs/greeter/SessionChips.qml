import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components

// Which session Enter will start. One chip, and it is a real control: click it
// or press F1 to cycle. There used to be two more pills beside it — a keyboard
// hint and the keymap — but neither did anything when pressed, and a login
// screen is the worst possible place to learn which of its buttons are real.
RowLayout {
    id: root

    spacing: 9

    BarChip {
        active: true

        // A single-session machine has nothing to cycle to, so the chip drops
        // back to being a readout rather than offering a press that no-ops.
        interactive: Session.sessions.length > 1

        onClicked: Session.cycleSession()

        Rectangle {
            Layout.alignment: Qt.AlignVCenter

            implicitWidth: 5
            implicitHeight: 5

            radius: 2.5
            color: Style.accent
        }

        Text {
            Layout.alignment: Qt.AlignVCenter

            text: Session.sessionLabel

            color: "#c2d5fd"
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeDetail
        }

        // Inside the control it names, not beside it as its own pill: this is
        // the shortcut for *this* chip, and there is nothing here to press.
        DetailText {
            Layout.alignment: Qt.AlignVCenter

            visible: Session.sessions.length > 1

            text: "F1"
            opacity: 0.55
        }
    }
}
