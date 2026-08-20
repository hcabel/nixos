// Reserving drawer: thickens the whole right edge, so the rail moves toward the
// centre and the compositor re-tiles the windows to fit. Placeholder content.
//
// fullEdge is what makes it span the edge, and `reserves` is what makes the
// windows move. Neither implies the other — a partial reserving drawer, or a
// full-edge floating one, would work the same way.
//
// Its depth is declared rather than measured: how wide a side panel sits is a
// decision about the workspace, not a consequence of what happens to be in it.

import QtQuick
import QtQuick.Layouts
import qs.components
import qs

Drawer {
    name: "controls"

    edge: "right"
    reserves: true
    fullEdge: true
    depth: Style.s.panelWidth

    content: Component {
        ColumnLayout {
            spacing: Style.s.gap[4]

            StyledText {
                Layout.alignment: Qt.AlignHCenter

                text: "Controls"
                font.pixelSize: Style.type.role.h2.size
            }

            StyledText {
                text: "panel · pushes windows"
                color: Style.c.text.secondary
            }
        }
    }
}
