pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs

Drawer {
    id: root

    name: "applauncher"

    edge: "top"
    align: 0.5
    padding: Style.s.gap[7]

    readonly property int columns: 6
    readonly property int cellWidth: 92
    readonly property int cellHeight: 86
    readonly property int maxRows: 4

    // Subsequence fuzzy match: every query char must appear in order in the
    // name. Score rewards prefix and word-boundary matches so "fx" ranks
    // "firefox" above some unrelated app that merely contains f...x.
    function score(name, query) {
        if (query.length === 0)
            return 0;

        const n = name.toLowerCase();
        const q = query.toLowerCase();

        if (n.startsWith(q))
            return 1000 - n.length;

        let ni = 0;
        let total = 0;
        let consecutive = 0;

        for (let qi = 0; qi < q.length; qi++) {
            const idx = n.indexOf(q[qi], ni);
            if (idx === -1)
                return -1;

            const boundary = idx === 0 || n[idx - 1] === " " || n[idx - 1] === "-";
            total += boundary ? 20 : 1;
            if (idx === ni)
                consecutive += 3;

            ni = idx + 1;
        }

        return total + consecutive - n.length * 0.1;
    }

    content: Component {
        ColumnLayout {
            id: content

            spacing: Style.s.gutter

            property var filtered: []

            function refresh() {
                const query = field.text;
                const apps = [];
                const model = DesktopEntries.applications;

                for (let i = 0; i < model.values.length; i++) {
                    const entry = model.values[i];
                    if (entry.noDisplay)
                        continue;

                    const s = root.score(entry.name, query);
                    if (s < 0)
                        continue;

                    apps.push({
                        entry: entry,
                        s: s
                    });
                }

                apps.sort((a, b) => b.s - a.s);
                filtered = apps.map(a => a.entry);
                grid.currentIndex = filtered.length > 0 ? 0 : -1;
            }

            function launchCurrent() {
                const entry = filtered[grid.currentIndex];
                if (entry) {
                    entry.execute();
                    Drawers.dismiss("applauncher");
                }
            }

            Component.onCompleted: {
                field.text = "";
                refresh();
                field.input.forceActiveFocus();
            }

            StyledTextField {
                id: field

                Layout.preferredWidth: root.columns * root.cellWidth

                onTextChanged: content.refresh()
                onUpPressed: grid.moveCurrentIndexUp()
                onDownPressed: grid.moveCurrentIndexDown()
                onLeftPressed: grid.moveCurrentIndexLeft()
                onRightPressed: grid.moveCurrentIndexRight()
                onConfirmed: content.launchCurrent()
                onCancelled: Drawers.dismiss("applauncher")
            }

            GridView {
                id: grid

                readonly property int rows: Math.ceil(content.filtered.length / root.columns)

                Layout.preferredWidth: root.columns * root.cellWidth
                Layout.preferredHeight: Math.max(1, Math.min(rows, root.maxRows)) * root.cellHeight

                model: content.filtered
                cellWidth: root.cellWidth
                cellHeight: root.cellHeight
                clip: true
                interactive: rows > root.maxRows
                keyNavigationEnabled: false
                keyNavigationWraps: false

                delegate: Item {
                    id: tile

                    required property var modelData
                    required property int index

                    readonly property bool isCurrent: GridView.isCurrentItem

                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4

                        radius: Style.r.row
                        color: tile.isCurrent ? Style.c.accent.primary.tintFill : "transparent"
                        border.color: tile.isCurrent ? Style.c.accent.primary.line : "transparent"
                        border.width: Style.s.strokeHair

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: grid.currentIndex = tile.index
                            onClicked: content.launchCurrent()
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            Item {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Style.r.chip
                                    color: Style.c.bg.raised
                                    visible: icon.status !== Image.Ready

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: (tile.modelData.name || "?").charAt(0).toUpperCase()
                                        font.pixelSize: Style.type.chromeName.size
                                    }
                                }

                                IconImage {
                                    id: icon
                                    anchors.fill: parent
                                    source: Quickshell.iconPath(tile.modelData.icon, true)
                                    implicitSize: 44
                                }
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillWidth: true

                                text: tile.modelData.name
                                font.pixelSize: Style.type.chromeMeta.size
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Style.s.gutter

                StyledText {
                    text: "↑↓←→ move · ↵ launch · esc close"
                    color: Style.c.text.quiet
                    font.pixelSize: Style.type.chromeMeta.size
                }
            }
        }
    }
}
