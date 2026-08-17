pragma Singleton

// Every colour and dimension in the shell comes from here, and everything here
// comes from hcabel.style in Nix by way of ~/.config/quickshell/style.json.
// Nothing else in the QML tree should hardcode a colour or a pixel count.
//
// The defaults below duplicate style.nix so the shell still renders if the JSON
// is missing or malformed — keep them in sync, but treat Nix as authoritative.
//
// Note: style.json is a symlink into the nix store. QFileSystemWatcher watches
// the resolved target, so a rebuild that changes only theming may not fire
// fileChanged; restart quickshell.service if a colour edit doesn't show up.
// Editing the QML itself is unaffected — those are real files in the repo.

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property color base: adapter.base
    readonly property color surface: adapter.surface
    readonly property color overlay: adapter.overlay
    readonly property color muted: adapter.muted
    readonly property color text: adapter.text
    readonly property color accent: adapter.accent
    readonly property color accentMid: adapter.accentMid
    readonly property color accentAlt: adapter.accentAlt
    readonly property color border: adapter.border
    readonly property color borderInactive: adapter.borderInactive
    readonly property color red: adapter.red
    readonly property color shadow: adapter.shadow
    readonly property color accentInk: adapter.accentInk

    readonly property string fontMono: adapter.fontMono
    readonly property int fontSize: adapter.fontSize

    readonly property int barHeight: adapter.barHeight
    readonly property int rail: adapter.rail
    readonly property int rounding: adapter.rounding
    readonly property int padding: adapter.padding
    readonly property int gap: adapter.gap
    readonly property real barOpacity: 0.85
    readonly property real shadowOpacity: adapter.shadowOpacity
    readonly property real hairlineOpacity: adapter.hairlineOpacity
    readonly property real chromeFill: adapter.chromeFill
    readonly property real chromeFillStrong: adapter.chromeFillStrong
    readonly property real chromeBorder: adapter.chromeBorder
    readonly property real chromeLabel: adapter.chromeLabel

    readonly property int drawerRounding: adapter.drawerRounding
    readonly property int fillet: adapter.fillet
    readonly property int panelWidth: adapter.panelWidth
    readonly property int drawerDuration: adapter.drawerDuration
    readonly property int animFast: adapter.animFast
    readonly property int shadowRange: adapter.shadowRange
    readonly property int shadowBands: adapter.shadowBands

    FileView {
        path: `${Quickshell.env("XDG_CONFIG_HOME") ?? `${Quickshell.env("HOME")}/.config`}/quickshell/style.json`

        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: adapter

            property string base: "#05070a"
            property string surface: "#18162c"
            property string overlay: "#241f38"
            property string muted: "#565a7a"
            property string text: "#ffffff"
            property string accent: "#7aa2f7"
            property string accentMid: "#a78bfa"
            property string accentAlt: "#f28fad"
            property string border: "#7aa2f7"
            property string borderInactive: "#1e1b33"
            property string red: "#f7768e"
            property string shadow: "#04040c"
            property string accentInk: "#0c1420"

            property string fontMono: "CaskaydiaMono Nerd Font"
            property int fontSize: 13

            property int barHeight: 40
            property int rail: 10
            property int rounding: 14
            property int padding: 8
            property int gap: 6
            property real barOpacity: 0.85
            property real shadowOpacity: 0.55
            property real hairlineOpacity: 0.10
            property real chromeFill: 0.055
            property real chromeFillStrong: 0.08
            property real chromeBorder: 0.07
            property real chromeLabel: 0.66

            property int drawerRounding: 18
            property int fillet: 14
            property int panelWidth: 360
            property int drawerDuration: 350
            property int animFast: 150
            property int shadowRange: 32
            property int shadowBands: 24
        }
    }
}
