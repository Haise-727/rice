pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Brightness read straight from sysfs (event-ish, no process spawn) and written
// via brightnessctl. Shared so the bar and the sidebar slider always agree.
Singleton {
    id: root

    property int raw: -1
    property int max: 100
    readonly property int percent: raw < 0 ? -1 : Math.round(raw * 100 / max)
    readonly property string device: "nvidia_0"

    function setPercent(p) {
        const v = Math.max(1, Math.min(100, Math.round(p)));
        Quickshell.execDetached(["brightnessctl", "-d", device, "set", v + "%"]);
    }

    FileView {
        id: cur
        path: `/sys/class/backlight/${root.device}/brightness`
        onLoaded: { const v = parseInt(text()); if (!isNaN(v)) root.raw = v; }
    }
    FileView {
        path: `/sys/class/backlight/${root.device}/max_brightness`
        onLoaded: { const v = parseInt(text()); if (!isNaN(v) && v > 0) root.max = v; }
    }
    Timer { interval: 200; running: true; repeat: true; onTriggered: cur.reload() }
}
