import QtQuick
import qs

// A persistent surface — never glass. Glass is for the bar, panels and the OSD,
// which are temporary and float over your work.
Rectangle {
    color: Style.c.bg.surface
    radius: Style.r.card
}
