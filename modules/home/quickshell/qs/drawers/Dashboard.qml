// Overlay drawer: extrudes out of the top bar, floats over the windows, nothing
// re-tiles. Placeholder content — this exists to prove the frame geometry, not
// to be a dashboard.
//
// It declares no size at all. The frame measures the content and the drawer
// becomes that big, which is what anything with a variable amount to show will
// need.

import QtQuick
import QtQuick.Layouts
import qs.components
import qs

Drawer {
    name: "dashboard"

    edge: "top"
    align: 0.5
    padding: Style.padding * 4

    content: Component {
        ColumnLayout {
            spacing: Style.gap

            StyledText {
                Layout.alignment: Qt.AlignHCenter

                text: "Dashboard"
                font.pixelSize: Style.fontSize * 1.6
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter

                text: "overlay · floats over windows · sized by this text"
                color: Style.muted
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter

                text: "this third line was added while the drawer was open,\nand it neither closed nor needed a hardcoded height"
                color: Style.muted
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
