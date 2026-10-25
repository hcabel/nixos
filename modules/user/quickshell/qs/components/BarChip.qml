import QtQuick
import QtQuick.Layouts
import qs.core

// The pill every bar widget sits in. Button already owns the hover/press
// surface, so this only adds the hairline border, the chip metrics, and a row
// to drop content into.
Button {
    id: root

    property real padH: 12
    property alias spacing: row.spacing

    // Whatever this chip toggles is open. Lights the border rather than the
    // fill, so a chip at rest and a chip in use read as the same object.
    property bool active: false

    // Named `items` because `content` is already Button's default property.
    default property alias items: row.data

    Layout.alignment: Qt.AlignVCenter

    implicitWidth: row.implicitWidth + root.padH * 2
    implicitHeight: Style.chipHeight

    radius: Style.cornerChip

    // Chips display by default; the ones that toggle something opt in.
    interactive: false

    border.width: 1
    border.color: root.active ? Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, 0.45) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.08)

    Behavior on border.color {
        ColorAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: 9
    }
}
