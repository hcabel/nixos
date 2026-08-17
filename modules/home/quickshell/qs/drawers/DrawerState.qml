// One screen's drawer state.
//
// PersistentProperties, not a plain QtObject: the whole workflow here is editing
// QML and watching it reload, and plain state resets on every reload, so a drawer
// you were looking at closes itself the moment you tweak it. This survives.
//
// Two slots rather than a flag per drawer. A reserving panel is furniture — it
// should stay put while a transient overlay comes and goes over it — but two
// overlays sharing an edge would have to negotiate geometry, and nothing wants
// that. Two strings per screen is the whole state model.

import Quickshell

PersistentProperties {
    required property ShellScreen modelData

    property string overlay: ""
    property string panel: ""
}
