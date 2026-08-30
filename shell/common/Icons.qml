pragma Singleton
import QtQuick

// Nerd Font glyphs as \uXXXX escapes.
//
// Literal private-use-area characters do NOT survive being written through shell
// heredocs - they arrive as empty strings and render as nothing, with no error.
// This file is generated with escapes so every glyph is safe to edit and move.
QtObject {
    readonly property string cog:        "\uf013"
    readonly property string power:      "\uf011"
    readonly property string volHigh:    "\uf028"
    readonly property string volLow:     "\uf027"
    readonly property string volMute:    "\uf026"
    readonly property string mic:        "\uf130"
    readonly property string brightness: "\uf185"
    readonly property string bluetooth:  "\uf293"
    readonly property string wifi:       "\uf1eb"
    readonly property string wifiOff:    "\uf05e"
    readonly property string batFull:    "\uf240"
    readonly property string batThreeQ:  "\uf241"
    readonly property string batHalf:    "\uf242"
    readonly property string batQuarter: "\uf243"
    readonly property string batEmpty:   "\uf244"
    readonly property string charging:   "\uf0e7"
    readonly property string play:       "\uf04b"
    readonly property string pause:      "\uf04c"
    readonly property string next:       "\uf051"
    readonly property string prev:       "\uf048"
    readonly property string bell:       "\uf0f3"
    readonly property string calendar:   "\uf073"
}
