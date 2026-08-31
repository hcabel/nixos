import QtQuick

Item {
    id: root

    required property string name
    property string edge: "top"
    property real offset: 0
    property bool wantsFocus: false
    readonly property bool open: TabState.isOpen(root.name)
    readonly property bool vertical: root.edge === "left" || root.edge === "right"
    property real padding: Style.padding
    property real length: 0
    property real depth: 0

    property int measureEpoch: 0

    function contentSize(wide) {
        let out = 0;
        const cs = pad.children;

        for (let i = 0; i < cs.length; i++)
            out = Math.max(out, wide ? cs[i].implicitWidth : cs[i].implicitHeight);

        return out;
    }

    readonly property real contentLength: (root.measureEpoch, root.contentSize(!root.vertical))
    readonly property real contentDepth: (root.measureEpoch, root.contentSize(root.vertical))

    readonly property real effectiveLength: root.length > 0 ? root.length : root.contentLength + root.padding * 2
    readonly property real effectiveDepth: root.depth > 0 ? root.depth : root.contentDepth + root.padding * 2

    readonly property real targetDepth: root.open ? root.effectiveDepth : 0

    property real liveDepth: root.targetDepth

    Behavior on liveDepth {
        NumberAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    readonly property var ins: parent.insets

    readonly property real runFrom: (root.vertical ? root.ins.top : root.ins.left) + Style.corner
    readonly property real runTo: (root.vertical ? parent.height - root.ins.bottom : parent.width - root.ins.right) - Style.corner

    readonly property real span: Math.max(0, Math.min(root.effectiveLength, root.runTo - root.runFrom))

    readonly property real axis: {
        const half = root.span / 2;
        const at = (root.runFrom + root.runTo) / 2;
        return at + root.offset;
    }

    x: root.vertical ? (root.edge === "left" ? root.ins.left : parent.width - root.ins.right - root.liveDepth) : root.axis - root.span / 2
    y: root.vertical ? root.axis - root.span / 2 : (root.edge === "top" ? root.ins.top : parent.height - root.ins.bottom - root.liveDepth)

    width: root.vertical ? root.liveDepth : root.span
    height: root.vertical ? root.span : root.liveDepth

    clip: true

    Item {
        id: body

        width: root.vertical ? root.effectiveDepth : root.width
        height: root.vertical ? root.height : root.effectiveDepth

        x: root.edge === "left" ? root.width - width : 0
        y: root.edge === "top" ? root.height - height : 0

        Item {
            id: pad

            anchors.fill: parent
            anchors.margins: root.padding

            // The implicit sizes above are read through a function, so the
            // binding cannot see children coming and going by itself.
            onChildrenChanged: root.measureEpoch++
        }
    }

    default property alias content: pad.data
}
