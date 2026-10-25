import QtQuick
import qs.core
import qs.components

// The one control on the screen. components/InputBar.qml is the bar's field and
// is deliberately not reused here: it is 40px, shows a placeholder, and echoes
// what you type. Only its focus-border idiom carries over.
Rectangle {
    id: root

    // Under the scrim's near edge the wallpaper behind this field is already
    // ~90% black, so a real backdrop blur would be work with nothing to show
    // for it. A tinted plate plus the hairline reads identically here.
    implicitHeight: 56

    radius: Style.corner
    color: Style.surfaceCard

    border.width: 1
    border.color: Session.failed ? Style.danger : input.activeFocus ? Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.1) : Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.06)

    Behavior on border.color {
        ColorAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    function focusInput() {
        input.forceActiveFocus();
    }

    // A wrong password is worth feeling as well as seeing.
    SequentialAnimation {
        id: shake

        running: Session.failed

        loops: 2

        NumberAnimation {
            target: root
            property: "anchors.horizontalCenterOffset"
            to: 6
            duration: 40
        }
        NumberAnimation {
            target: root
            property: "anchors.horizontalCenterOffset"
            to: -6
            duration: 80
        }
        NumberAnimation {
            target: root
            property: "anchors.horizontalCenterOffset"
            to: 0
            duration: 40
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.right: hint.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        spacing: 9

        Repeater {
            model: Session.echoResponse ? 0 : Session.response.length

            Rectangle {
                width: 8
                height: 8

                anchors.verticalCenter: parent.verticalCenter

                radius: 4
                color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.78)
            }
        }

        // PAM occasionally asks something that is not a secret. Echo it rather
        // than drawing dots nobody can check.
        Text {
            visible: Session.echoResponse

            anchors.verticalCenter: parent.verticalCenter

            text: Session.response

            color: Style.text
            font.family: Style.fontFamily
            font.pixelSize: 14
        }

        Rectangle {
            id: caret

            width: 2
            height: 19

            anchors.verticalCenter: parent.verticalCenter

            color: Style.accentAlt
            visible: input.activeFocus && !Session.busy

            SequentialAnimation on opacity {
                running: caret.visible
                loops: Animation.Infinite

                PropertyAction {
                    value: 1
                }
                PauseAnimation {
                    duration: 550
                }
                PropertyAction {
                    value: 0
                }
                PauseAnimation {
                    duration: 550
                }
            }
        }
    }

    DetailText {
        id: hint

        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter

        text: Session.busy ? "checking" : Session.failed ? Session.message : "↵ unlock"
        color: Session.failed ? Style.danger : Style.textMuted
    }

    // The real keyboard sink. Nothing it draws is ever shown; the dots above
    // are rendered from Session.response so the view has one source of truth.
    TextInput {
        id: input

        anchors.fill: parent

        enabled: !Session.busy

        echoMode: TextInput.NoEcho
        color: "transparent"

        text: Session.response

        onTextChanged: Session.response = text
        onAccepted: Session.submit()

        Component.onCompleted: input.forceActiveFocus()
    }

    // greetd hands focus to whatever comes up; take it back whenever the
    // session machine returns to a state that wants typing.
    Connections {
        target: Session

        function onPhaseChanged() {
            if (Session.phase === "prompting")
                input.forceActiveFocus();
        }
    }
}
