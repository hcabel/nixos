import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var insets

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell:background"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    mask: Region {}

    Rectangle {
        x: root.insets.left
        y: root.insets.top
        width: root.width - root.insets.left - root.insets.right
        height: root.height - root.insets.top - root.insets.bottom

        color: Style.surface
        clip: true

        Image {
            anchors.fill: parent
            source: "../saturn-rings.jpg"

            fillMode: Image.PreserveAspectCrop
            asynchronous: true

            sourceSize: Qt.size(root.width, root.height)
        }
    }
}
