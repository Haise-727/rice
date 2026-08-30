pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The "current" player, chosen once so the bar, the startup dashboard and any
// future surface always agree on which player they are talking about.
Singleton {
    id: root

    readonly property var players: Mpris.players?.values ?? []
    readonly property var active: {
        if (players.length === 0) return null;
        return players.find(p => p.isPlaying) ?? players[0];
    }
    readonly property bool has: active !== null
    readonly property bool playing: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle ?? ""
    readonly property string artist: active?.trackArtist ?? ""

    function toggle() { if (active?.canTogglePlaying) active.togglePlaying(); }
    function next()   { if (active?.canGoNext) active.next(); }
    function prev()   { if (active?.canGoPrevious) active.previous(); }
}
