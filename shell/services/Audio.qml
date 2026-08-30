pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// One source of truth for audio, so the bar readout, the sidebar slider and the
// quick toggle can never disagree (a mute has to be visible in all three).
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink ?? null
    readonly property var node: sink?.audio ?? null

    readonly property bool ready: node !== null
    readonly property bool muted: node?.muted ?? false
    readonly property real volume: node?.volume ?? 0          // 0..1, raw
    readonly property int percent: ready ? Math.round(volume * 100) : -1

    // What the UI should show: muted reads as 0 everywhere.
    readonly property real effective: muted ? 0 : volume
    readonly property int effectivePercent: muted ? 0 : percent

    function setVolume(v) { if (node) { node.volume = Math.max(0, Math.min(1, v)); if (node.muted && v > 0) node.muted = false; } }
    function toggleMute() { if (node) node.muted = !node.muted; }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
}
