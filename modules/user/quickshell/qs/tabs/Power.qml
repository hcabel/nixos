import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.components

Tab {
    id: root

    name: "Power"
    wantsFocus: true

    readonly property int cell: 116

    // One source of truth: the buttons below and the key handler both read
    // this, so a shortcut can never drift from the action it draws.
    readonly property var actions: [
        {
            key: "p",
            label: "Power off",
            glyph: "",
            danger: true,
            cmd: ["systemctl", "poweroff"]
        },
        {
            key: "r",
            label: "Restart",
            glyph: "",
            danger: true,
            cmd: ["systemctl", "reboot"]
        },
        {
            key: "l",
            label: "Lock",
            glyph: "",
            danger: false,
            cmd: ["hyprlock"]
        },
        {
            key: "s",
            label: "Sleep",
            glyph: "",
            danger: false,
            cmd: ["systemctl", "suspend"]
        }
    ]

    property int current: 0

    function run(action) {
        if (!action)
            return;

        // Close first: the frame holds the compositor's keyboard focus
        // exclusively while an open tab wants it, and hyprlock has to be able
        // to collect the password it is about to ask for.
        TabState.close(root.name);
        Quickshell.execDetached(action.cmd);
    }

    function activate(key) {
        for (let i = 0; i < root.actions.length; i++) {
            if (root.actions[i].key === key) {
                root.current = i;
                root.run(root.actions[i]);
                return true;
            }
        }

        return false;
    }

    onOpenChanged: {
        if (root.open) {
            root.current = 0;
            keys.forceActiveFocus();
        }
    }

    Item {
        id: keys

        anchors.fill: parent

        implicitWidth: root.actions.length * root.cell + (root.actions.length - 1) * Style.gap
        implicitHeight: header.implicitHeight + Style.gap + root.cell

        focus: true

        // A closed tab still exists — only its depth animates to zero — so the
        // handler has to stay off unless the tab is actually up.
        Keys.onPressed: event => {
            if (!root.open)
                return;

            if (event.key === Qt.Key_Escape)
                TabState.close(root.name);
            else if (event.key === Qt.Key_Left)
                root.current = Math.max(0, root.current - 1);
            else if (event.key === Qt.Key_Right)
                root.current = Math.min(root.actions.length - 1, root.current + 1);
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                root.run(root.actions[root.current]);
            else if (!root.activate((event.text || "").toLowerCase()))
                return;

            event.accepted = true;
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: Style.gap

            TitleText {
                id: header

                Layout.fillWidth: true

                text: "Power"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: Style.gap

                Repeater {
                    model: root.actions

                    delegate: Button {
                        id: tile

                        required property var modelData
                        required property int index

                        readonly property color ring: tile.modelData.danger ? Style.danger : Style.accent

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        border.width: root.current === tile.index ? 1 : 0
                        border.color: tile.ring

                        onClicked: root.run(tile.modelData)
                        onHoveredChanged: {
                            if (hovered)
                                root.current = tile.index;
                        }

                        ColumnLayout {
                            anchors.centerIn: parent

                            width: parent.width - Style.gap

                            spacing: 6

                            TitleText {
                                Layout.alignment: Qt.AlignHCenter

                                text: tile.modelData.glyph
                                font.pixelSize: 26
                                color: root.current === tile.index ? tile.ring : Style.text
                            }

                            TitleText {
                                Layout.fillWidth: true

                                text: tile.modelData.label
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            DetailText {
                                Layout.fillWidth: true

                                text: tile.modelData.key
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
