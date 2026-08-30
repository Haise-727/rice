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

    // A node's `properties` and `audio` are only populated once it is TRACKED, so
    // the tracker cannot depend on a filter that reads properties - that is a
    // chicken-and-egg that leaves the mixer empty. Track every stream (isStream is
    // readable untracked), then filter the tracked ones.
    readonly property var allStreams: {
        const out = [];
        for (const n of (Pipewire.nodes?.values ?? [])) if (n.isStream) out.push(n);
        return out;
    }

    // Per-application PLAYBACK streams. Capture streams (cava reading the monitor)
    // are Stream/Input/Audio and must not appear, or the mixer lists the visualiser
    // instead of the browser.
    readonly property var streams: {
        const out = [];
        for (const n of root.allStreams) {
            if (!n.audio) continue;
            const cls = n.properties ? (n.properties["media.class"] ?? "") : "";
            if (cls !== "" && cls !== "Stream/Output/Audio") continue;
            if (cls === "") continue;                    // not yet resolved
            out.push(n);
        }
        return out;
    }

    function appName(n) {
        const p = n.properties;
        return (p && (p["application.name"] || p["node.description"])) || n.name || "app";
    }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink, ...root.allStreams] }
}
