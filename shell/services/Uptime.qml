pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Uptime, read once for the whole shell rather than per widget.
Singleton {
    id: root
    property real seconds: 0
    readonly property string pretty: {
        if (seconds <= 0) return "--";
        const h = Math.floor(seconds / 3600), m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }
    FileView {
        id: f
        path: "/proc/uptime"
        onLoaded: { const s = parseFloat(text().split(" ")[0]); if (!isNaN(s)) root.seconds = s; }
    }
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: f.reload() }
}
