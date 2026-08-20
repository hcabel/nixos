import QtQuick
import qs

Rectangle {
    id: root

    property alias text: input.text
    property alias input: input
    signal upPressed
    signal downPressed
    signal leftPressed
    signal rightPressed
    signal confirmed
    signal cancelled

    implicitHeight: Style.s.height.row
    radius: Style.r.chip
    color: Style.c.bg.inset
    border.color: Style.c.hairline.chip
    border.width: 1

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: Style.s.panelPad
        anchors.rightMargin: Style.s.panelPad

        verticalAlignment: TextInput.AlignVCenter
        color: Style.c.text.primary
        font.family: Style.font.mono
        font.pixelSize: Style.type.chromeMeta.size
        selectionColor: Style.c.accent.primary.active
        clip: true
        focus: true

        Keys.onUpPressed: root.upPressed()
        Keys.onDownPressed: root.downPressed()
        Keys.onLeftPressed: event => {
            if (input.cursorPosition !== 0)
                event.accepted = false;
            else
                root.leftPressed();
        }
        Keys.onRightPressed: event => {
            if (input.cursorPosition !== input.text.length)
                event.accepted = false;
            else
                root.rightPressed();
        }
        Keys.onReturnPressed: root.confirmed()
        Keys.onEnterPressed: root.confirmed()
        Keys.onEscapePressed: root.cancelled()
    }

    StyledText {
        anchors.left: input.left
        anchors.verticalCenter: input.verticalCenter

        visible: input.text.length === 0
        text: "search apps…"
        color: Style.c.text.quiet
    }
}
