import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components

PanelWindow {
    id: root

    required property var insets

    readonly property real cardWidth: 380

    // Region is a plain QObject, so the mask cannot be built by a Repeater.
    // Fixed slots, collapsing to zero when no toast occupies them. The Repeater
    // is itself a child of the column, hence the card test rather than an index.
    function toastAt(slot) {
        const cs = column.children;
        let seen = 0;

        for (let i = 0; i < cs.length; i++) {
            if (!cs[i].visible || cs[i].notification === undefined)
                continue;

            if (seen === slot)
                return cs[i];

            seen++;
        }

        return null;
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:toasts"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    mask: Region {
        ToastMask {
            slot: 0
        }

        ToastMask {
            slot: 1
        }

        ToastMask {
            slot: 2
        }

        ToastMask {
            slot: 3
        }
    }

    Column {
        id: column

        x: root.width - root.insets.right - width - Style.gap
        y: root.insets.top + Style.gap

        width: root.cardWidth

        spacing: Style.gap

        Repeater {
            model: Notifications.toasts

            delegate: NotificationCard {
                id: card

                required property var modelData

                width: column.width

                notification: card.modelData

                opacity: 0
                x: 40

                onDismissed: Notifications.dismiss(card.modelData)

                Component.onCompleted: {
                    card.opacity = 1;
                    card.x = 0;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.duration
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: Style.duration
                        easing.type: Easing.OutCubic
                    }
                }

                Timer {
                    interval: Notifications.lifetimeOf(card.modelData)
                    running: interval > 0 && !card.hovered
                    repeat: false

                    onTriggered: Notifications.hideToast(card.modelData)
                }
            }
        }
    }

    component ToastMask: Region {
        required property int slot

        readonly property Item toast: root.toastAt(slot)

        x: toast ? column.x + toast.x : 0
        y: toast ? column.y + toast.y : 0
        width: toast ? toast.width : 0
        height: toast ? toast.height : 0
    }
}
