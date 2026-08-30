pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / RAM / temperatures. Polled only while something is watching, so an
// unopened dashboard costs nothing.
Singleton {
    id: root

    property int consumers: 0
    readonly property bool active: consumers > 0
    function acquire() { consumers++; }
    function release() { if (consumers > 0) consumers--; }

    property real cpuPct: 0
    property real memPct: 0
    property string memUsed: "--"
    property string memTotal: "--"
    property int cpuTemp: -1
    property int gpuTemp: -1
    property int gpuPct: -1
    property string gpuMem: "--"

    // --- CPU from /proc/stat deltas ---
    property var _prev: null
    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const l = text().split("\n")[0].trim().split(/\s+/);
            if (l[0] !== "cpu") return;
            const v = l.slice(1).map(Number);
            const idle = v[3] + (v[4] ?? 0);
            const total = v.reduce((a, b) => a + b, 0);
            if (root._prev) {
                const dt = total - root._prev.total;
                const di = idle - root._prev.idle;
                if (dt > 0) root.cpuPct = Math.max(0, Math.min(100, (1 - di / dt) * 100));
            }
            root._prev = { idle: idle, total: total };
        }
    }

    // --- memory ---
    FileView {
        id: mem
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const get = k => {
                const m = t.match(new RegExp(k + ":\\s+(\\d+)"));
                return m ? parseInt(m[1]) : 0;
            };
            const total = get("MemTotal"), avail = get("MemAvailable");
            if (total > 0) {
                root.memPct = (1 - avail / total) * 100;
                root.memUsed = ((total - avail) / 1048576).toFixed(1) + "G";
                root.memTotal = (total / 1048576).toFixed(1) + "G";
            }
        }
    }

    // --- nvidia GPU ---
    Process {
        id: nv
        command: ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total",
                  "--format=csv,noheader,nounits"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.split(",").map(x => x.trim());
                if (p.length >= 4) {
                    root.gpuTemp = parseInt(p[0]);
                    root.gpuPct = parseInt(p[1]);
                    root.gpuMem = (parseInt(p[2]) / 1024).toFixed(1) + "/" + (parseInt(p[3]) / 1024).toFixed(1) + "G";
                }
            }
        }
    }

    // --- CPU package temperature ---
    Process {
        id: temp
        command: ["sh", "-c",
            "for z in /sys/class/thermal/thermal_zone*; do " +
            "  t=$(cat $z/type 2>/dev/null); " +
            "  case \"$t\" in x86_pkg_temp|acpitz|coretemp) cat $z/temp; exit;; esac; done; echo -1"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d); root.cpuTemp = v > 1000 ? Math.round(v / 1000) : v; } }
    }

    Timer {
        interval: 1500
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: { stat.reload(); mem.reload(); nv.running = true; temp.running = true; }
    }
}
