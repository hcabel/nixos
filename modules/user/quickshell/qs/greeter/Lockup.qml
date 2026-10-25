import QtQuick
import QtQuick.Shapes
import qs.core

// Mark, rule, wordmark, stage badge. Every boot stage draws this identically at
// the same place, so the eye has something that does not move while everything
// underneath it is replaced. The Plymouth theme reproduces it as pre-rendered
// PNGs cut to these exact metrics.
Row {
    id: root

    // What this stage is called, in the pill on the right.
    property string badge: "greetd"

    spacing: 12

    Item {
        width: 66
        height: 66

        anchors.verticalCenter: parent.verticalCenter

        // The mark is drawn in the 120x100 space it was designed in and scaled
        // once here, so the path data stays copy-pasteable from the source SVG.
        Item {
            width: 120
            height: 100

            anchors.centerIn: parent

            scale: 58 / 120

            Shape {
                anchors.fill: parent

                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeWidth: -1

                    fillGradient: LinearGradient {
                        x1: 0
                        y1: 100
                        x2: 120
                        y2: 0

                        GradientStop {
                            position: 0
                            color: Style.accent
                        }

                        GradientStop {
                            position: 1
                            color: Style.accentAlt
                        }
                    }

                    PathSvg {
                        path: "M20 18 L32 18 L32 44 L54 44 L54 18 L66 18 L66 82 L54 82 L54 56 L32 56 L32 82 L20 82 Z"
                    }
                }

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: Style.text
                    strokeWidth: 12
                    capStyle: ShapePath.FlatCap

                    PathSvg {
                        path: "M100 34a24 24 0 1 0 0 32"
                    }
                }
            }
        }
    }

    Rectangle {
        width: 1
        height: 34

        anchors.verticalCenter: parent.verticalCenter

        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.16)
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: "SATURN"

        color: Qt.rgba(Style.text.r, Style.text.g, Style.text.b, 0.6)
        font.family: Style.fontFamily
        font.pixelSize: 11
        font.letterSpacing: 3
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter

        implicitWidth: badgeLabel.implicitWidth + 18
        implicitHeight: 20

        radius: 7

        color: Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, 0.16)

        Text {
            id: badgeLabel

            anchors.centerIn: parent

            text: root.badge

            color: "#c2d5fd"
            font.family: Style.fontFamily
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 2
            font.capitalization: Font.AllUppercase
        }
    }
}
