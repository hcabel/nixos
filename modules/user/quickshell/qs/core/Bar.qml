import QtQuick
import QtQuick.Layouts
import qs.core

// The strip of chrome above the viewport. Content goes in one of three slots;
// the Frame punches each of them into its input mask so bar modules can take
// clicks while the rest of the chrome stays click-through.
Item {
    id: root

    property alias leftContent: leftRow.data
    property alias centerContent: centerRow.data
    property alias rightContent: rightRow.data

    // Read by Frame to build the mask. Sound only because Bar sits at the
    // window origin, which makes every slot's x/y window coordinates already.
    readonly property var slots: [leftRow, centerRow, rightRow]

    RowLayout {
        id: leftRow

        anchors.left: parent.left
        anchors.leftMargin: Style.padding
        anchors.verticalCenter: parent.verticalCenter

        spacing: Style.gap
    }

    RowLayout {
        id: centerRow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        spacing: Style.gap
    }

    RowLayout {
        id: rightRow

        anchors.right: parent.right
        anchors.rightMargin: Style.padding
        anchors.verticalCenter: parent.verticalCenter

        spacing: Style.gap
    }
}
