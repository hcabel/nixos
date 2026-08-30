import QtQuick
import qs.core

Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""

    readonly property alias focused: input.activeFocus

    signal accepted

    // Raised before the field handles the key itself, so a consumer can claim
    // navigation keys by setting `event.accepted`.
    signal keyPressed(var event)

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: 40

    radius: Style.corner
    color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.08)

    border.width: 1
    border.color: input.activeFocus ? Style.accent : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.12)

    Behavior on border.color {
        ColorAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    DetailText {
        anchors.left: parent.left
        anchors.leftMargin: Style.gap
        anchors.verticalCenter: parent.verticalCenter

        text: root.placeholder
        visible: input.text.length === 0
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: Style.gap
        anchors.rightMargin: Style.gap
        verticalAlignment: TextInput.AlignVCenter

        color: Style.text
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeDetail

        onAccepted: root.accepted()

        Keys.onPressed: event => root.keyPressed(event)
    }
}
