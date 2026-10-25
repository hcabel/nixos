import QtQuick
import QtQuick.Shapes
import qs.core

// The wash that pulls the wallpaper back under the content column. The angle is
// what makes it read as a composition rather than a vignette, and an angled
// gradient is the one thing a Rectangle gradient cannot do — hence Shapes,
// which core/Frame.qml and core/RailShadow.qml already pull in.
Shape {
    id: root

    // Measured the way the CSS this came from measures: 0 points up, turning
    // clockwise. The gradient line is as long as the box's projection onto that
    // direction, which is what makes stop positions mean the same here as they
    // did in the mockup.
    readonly property real angle: 100
    readonly property real radians: root.angle * Math.PI / 180

    ShapePath {
        strokeWidth: -1

        fillGradient: LinearGradient {
            // Inlined on purpose. Routing these through readonly properties on
            // the Shape left the gradient permanently unpainted: at creation the
            // Shape is still 0x0, so the gradient line has zero length, and it
            // never recovered once the surface was sized. Written out here it
            // tracks width and height correctly.
            x1: root.width / 2 - Math.sin(root.radians) * (Math.abs(root.width * Math.sin(root.radians)) + Math.abs(root.height * Math.cos(root.radians))) / 2
            y1: root.height / 2 + Math.cos(root.radians) * (Math.abs(root.width * Math.sin(root.radians)) + Math.abs(root.height * Math.cos(root.radians))) / 2
            x2: root.width / 2 + Math.sin(root.radians) * (Math.abs(root.width * Math.sin(root.radians)) + Math.abs(root.height * Math.cos(root.radians))) / 2
            y2: root.height / 2 - Math.cos(root.radians) * (Math.abs(root.width * Math.sin(root.radians)) + Math.abs(root.height * Math.cos(root.radians))) / 2

            GradientStop {
                position: 0.0
                color: Qt.rgba(Style.scrim.r, Style.scrim.g, Style.scrim.b, Style.scrimNear)
            }

            GradientStop {
                position: 0.38
                color: Qt.rgba(Style.scrim.r, Style.scrim.g, Style.scrim.b, Style.scrimMid)
            }

            GradientStop {
                position: 0.68
                color: Qt.rgba(Style.scrim.r, Style.scrim.g, Style.scrim.b, Style.scrimFar)
            }
        }

        startX: 0
        startY: 0

        PathLine { x: root.width; y: 0 }
        PathLine { x: root.width; y: root.height }
        PathLine { x: 0; y: root.height }
        PathLine { x: 0; y: 0 }
    }
}
