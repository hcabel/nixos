import QtQuick

Item {
    id: root

    required property string name

    readonly property string target: PanelState.edgeOf(root.name)

    property string edge: "left"

    onTargetChanged: {
        if (root.target === "")
            root.open = false;
        else if (root.target === root.edge)
            root.open = true;
        else {
            root.edge = root.target;
            reshape.restart();
        }
    }

    property int measureEpoch: 0

    Timer {
        id: reshape

        interval: 32

        onTriggered: {
            root.measureEpoch++;
            root.open = root.target !== "";
        }
    }

    property bool open: false
    property bool wantsFocus: false

    readonly property bool vertical: root.edge === "left" || root.edge === "right"

    property real depth: 0

    property real padding: Style.padding

    readonly property string inner: root.edge === "left" ? "right" : root.edge === "right" ? "left" : root.edge === "top" ? "bottom" : "top"

    function sidePad(side) {
        return side === root.inner ? root.padding : Math.max(0, root.padding - Style.insets[side]);
    }

    function deepestChild() {
        let deepest = 0;
        const cs = pad.children;

        for (let i = 0; i < cs.length; i++)
            deepest = Math.max(deepest, root.vertical ? cs[i].implicitWidth : cs[i].implicitHeight);

        return deepest;
    }

    readonly property real contentDepth: (root.measureEpoch, root.deepestChild())
    readonly property real padDepth: root.vertical ? root.sidePad("left") + root.sidePad("right") : root.sidePad("top") + root.sidePad("bottom")
    readonly property real effectiveDepth: root.depth > 0 ? root.depth : root.contentDepth + root.padDepth

    readonly property real targetDepth: root.open ? root.effectiveDepth : 0

    property real liveDepth: root.targetDepth

    Behavior on liveDepth {
        NumberAnimation {
            duration: Style.duration
            easing.type: Easing.OutCubic
        }
    }

    readonly property var ins: parent.insets

    x: root.edge === "left" ? root.ins.left - root.liveDepth : root.edge === "right" ? parent.width - root.ins.right : root.ins.left
    y: root.edge === "top" ? root.ins.top - root.liveDepth : root.edge === "bottom" ? parent.height - root.ins.bottom : root.ins.top
    width: root.vertical ? root.liveDepth : parent.width - root.ins.left - root.ins.right
    height: root.vertical ? parent.height - root.ins.top - root.ins.bottom : root.liveDepth

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
            anchors.leftMargin: root.sidePad("left")
            anchors.rightMargin: root.sidePad("right")
            anchors.topMargin: root.sidePad("top")
            anchors.bottomMargin: root.sidePad("bottom")
        }
    }

    default property alias content: pad.data
}
