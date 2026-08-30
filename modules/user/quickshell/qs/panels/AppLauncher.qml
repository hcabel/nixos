import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components

Panel {
    id: root

    name: "AppLauncher"
    wantsFocus: true

    readonly property int cell: 92
    readonly property int columns: 4
    readonly property int rows: 2

    property string query: ""

    function rank(entry, needle) {
        const name = (entry.name || "").toLowerCase();

        if (name.startsWith(needle))
            return 0;
        if (name.indexOf(" " + needle) !== -1)
            return 1;
        if (name.indexOf(needle) !== -1)
            return 2;
        if ((entry.genericName || "").toLowerCase().indexOf(needle) !== -1)
            return 3;

        const keywords = entry.keywords || [];

        for (let i = 0; i < keywords.length; i++) {
            if (keywords[i].toLowerCase().indexOf(needle) !== -1)
                return 4;
        }

        if ((entry.comment || "").toLowerCase().indexOf(needle) !== -1)
            return 5;

        return -1;
    }

    // DesktopEntries scans lazily: the first read comes back empty and the list
    // fills in over the next few frames, so this has to stay a binding.
    readonly property var results: {
        const all = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        const needle = root.query.trim().toLowerCase();

        if (needle === "")
            return all.sort((a, b) => a.name.localeCompare(b.name));

        return all
            .map(e => ({ entry: e, score: root.rank(e, needle) }))
            .filter(m => m.score >= 0)
            .sort((a, b) => a.score - b.score || a.entry.name.localeCompare(b.entry.name))
            .map(m => m.entry);
    }

    onResultsChanged: grid.currentIndex = 0

    function launch(entry) {
        if (!entry)
            return;

        entry.execute();
        PanelState.close(root.edge);
    }

    onOpenChanged: {
        if (root.open) {
            search.text = "";
            search.focusInput();
        }
    }

    Item {
        anchors.fill: parent

        implicitWidth: root.columns * root.cell
        implicitHeight: header.implicitHeight + Style.gap + root.rows * root.cell

        ColumnLayout {
            anchors.fill: parent

            spacing: Style.gap

            ColumnLayout {
                id: header

                Layout.fillWidth: true

                spacing: Style.gap

                TitleText {
                    Layout.fillWidth: true

                    text: "Applications"
                }

                InputBar {
                    id: search

                    Layout.fillWidth: true

                    placeholder: "Search apps…"

                    onTextChanged: root.query = text
                    onAccepted: root.launch(root.results[grid.currentIndex])

                    // Left/Right stay with the caret so typing never fights the
                    // grid; Up/Down step a row, Tab steps a single tile.
                    onKeyPressed: event => {
                        if (event.key === Qt.Key_Escape)
                            PanelState.close(root.edge);
                        else if (event.key === Qt.Key_Up)
                            grid.moveCurrentIndexUp();
                        else if (event.key === Qt.Key_Down)
                            grid.moveCurrentIndexDown();
                        else if (event.key === Qt.Key_Tab)
                            grid.currentIndex = Math.min(grid.count - 1, grid.currentIndex + 1);
                        else if (event.key === Qt.Key_Backtab)
                            grid.currentIndex = Math.max(0, grid.currentIndex - 1);
                        else
                            return;

                        event.accepted = true;
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: grid

                    anchors.fill: parent

                    clip: true
                    cacheBuffer: root.cell * 4

                    cellWidth: root.cell
                    cellHeight: root.cell

                    flow: root.vertical ? GridView.FlowLeftToRight : GridView.FlowTopToBottom
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.results

                    delegate: Item {
                        id: tile

                        required property var modelData
                        required property int index

                        width: grid.cellWidth
                        height: grid.cellHeight

                        Button {
                            anchors.fill: parent
                            anchors.margins: Style.gap / 2

                            border.width: grid.currentIndex === tile.index ? 1 : 0
                            border.color: Style.accent

                            onClicked: root.launch(tile.modelData)
                            onHoveredChanged: {
                                if (hovered)
                                    grid.currentIndex = tile.index;
                            }

                            ColumnLayout {
                                anchors.centerIn: parent

                                width: parent.width - Style.gap

                                spacing: 4

                                Item {
                                    id: icon

                                    Layout.alignment: Qt.AlignHCenter

                                    implicitWidth: 40
                                    implicitHeight: 40

                                    readonly property string path: Quickshell.iconPath(tile.modelData.icon, true)

                                    IconImage {
                                        anchors.fill: parent

                                        asynchronous: true

                                        visible: icon.path !== ""
                                        source: icon.path
                                    }

                                    // The theme carries no generic application
                                    // icon, so an entry we cannot resolve gets a
                                    // monogram instead of an empty hole.
                                    Rectangle {
                                        anchors.fill: parent

                                        visible: icon.path === ""

                                        radius: Style.cornerSmall
                                        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.14)

                                        TitleText {
                                            anchors.centerIn: parent

                                            text: (tile.modelData.name || "?").charAt(0).toUpperCase()
                                        }
                                    }
                                }

                                DetailText {
                                    Layout.fillWidth: true

                                    text: tile.modelData.name
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                DetailText {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    text: root.query === "" ? "No applications found" : "No match for “" + root.query + "”"
                }
            }
        }
    }
}
