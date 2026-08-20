import QtQuick
import qs

// The shell uses exactly two type sizes: 12.5/700 names a thing, 11/400 says
// everything else. This is the "everything else" default — set the chromeName
// pair explicitly on anything that is naming something.
Text {
    // color: Style.c.text.body
    font.family: Style.font.mono
    font.pixelSize: Style.type.chromeMeta.size
    font.weight: Style.type.chromeMeta.weight
}
