import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components

// Overlay rather than Top: nothing should ever be able to paint above a login
// screen. Exclusive keyboard focus for the same reason — the password field has
// to be the only thing on the seat that can see a keystroke.
PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    // Exclusive only in a real greeter session. Under `qs -p` on a live desktop
    // an unescapable full-screen keyboard grab would be the last thing you did.
    WlrLayershell.keyboardFocus: Session.live ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:greeter"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: Style.scrim

    // The composition is authored at 1920x1080. Rather than multiplying every
    // coordinate at its use site, the content lives on a canvas of that size
    // and is scaled once — on this laptop's panel that is exactly 1:1.
    readonly property real s: Math.min(root.width / Style.designWidth, root.height / Style.designHeight)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // Wallpaper and scrim cover the whole output, not the canvas, so an
    // unusual aspect ratio letterboxes the content and never the background.
    Image {
        anchors.fill: parent

        source: "../saturn-rings.jpg"

        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        sourceSize: Qt.size(root.width, root.height)
    }

    Scrim {
        anchors.fill: parent
    }

    Item {
        width: Style.designWidth
        height: Style.designHeight

        anchors.centerIn: parent

        scale: root.s

        Lockup {
            x: Style.lockup.x
            y: Style.lockup.y

            badge: "greetd"
        }

        Column {
            x: Style.lockup.x
            y: Style.lockup.contentY

            width: 700

            spacing: 0

            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm")

                color: Style.text
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeClock
                font.weight: Font.Thin
                font.letterSpacing: -4
            }

            Item {
                width: 1
                height: 12
            }

            Text {
                text: {
                    const parts = [Qt.formatDateTime(clock.date, "dddd dd MMMM").toLowerCase()];

                    if (Session.nixosRelease !== "")
                        parts.push("nixos " + Session.nixosRelease);

                    if (Session.generation > 0)
                        parts.push("gen " + Session.generation);

                    return parts.join(" · ");
                }

                color: Style.textMuted
                font.family: Style.fontFamily
                font.pixelSize: 14
                font.letterSpacing: 2
            }

            Item {
                width: 1
                height: 60
            }

            Row {
                width: parent.width

                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: Session.user

                    color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.85)
                    font.family: Style.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                }

                PasswordField {
                    width: parent.width - parent.spacing - Session.user.length * 10 - 20

                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                width: 1
                height: 26
            }

            SessionChips {}
        }

        StatusRow {
            x: Style.designWidth - width - 60
            y: Style.designHeight - height - 44
        }
    }

    // Shortcuts rather than a Keys handler: the password field holds focus for
    // the whole life of the screen, and a PanelWindow is not an Item so it
    // cannot carry attached key properties anyway.
    Shortcut {
        sequences: ["F1"]

        onActivated: Session.cycleSession()
    }

    // Design-mode escape hatch. Disabled in a real session, where dismissing
    // the login screen is exactly what must not be possible.
    Shortcut {
        sequences: ["Esc"]
        enabled: !Session.live

        onActivated: Qt.quit()
    }
}
