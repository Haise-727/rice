pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Spawns cava in raw-ASCII mode and exposes the band levels as `values` (0..100).
// Only runs while something is actually listening, so it costs nothing when idle.
Singleton {
    id: root

    property var values: []
    readonly property int bars: Config.options.cava.bars
    property int consumers: 0                      // widgets increment/decrement this
    readonly property bool shouldRun: Config.options.cava.enabled && consumers > 0

    function acquire() { consumers++; }
    function release() { if (consumers > 0) consumers--; }

    Process {
        id: proc
        running: root.shouldRun
        command: ["cava", "-p", `${Quickshell.env("HOME")}/rice/shell/assets/cava-raw.conf`]
        onRunningChanged: if (!running) root.values = []
        stdout: SplitParser {
            onRead: data => {
                const v = data.split(";").map(x => parseFloat(x)).filter(x => !isNaN(x));
                if (v.length > 0) root.values = v;
            }
        }
    }
}
