pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Power profile via power-profiles-daemon over DBus. polkit permits a local
// session to set it, so no root and no password prompt.
//
// Note the vocabulary differs from the firmware's: the daemon says
// power-saver / balanced / performance, while /sys/.../platform_profile says
// low-power / balanced / performance.
Singleton {
    id: root

    readonly property var profiles: ["power-saver", "balanced", "performance"]
    property string active: "balanced"
    property string degraded: ""

    readonly property var labels: ({
        "power-saver": "Quiet",
        "balanced":    "Balanced",
        "performance": "Performance"
    })

    function set(p) {
        if (!profiles.includes(p)) return;
        setProc.command = ["busctl", "--system", "set-property",
                           "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles",
                           "net.hadess.PowerProfiles", "ActiveProfile", "s", p];
        setProc.running = true;
        active = p;             // optimistic; the poll corrects it if it failed
    }

    Process { id: setProc }

    Process {
        id: getProc
        command: ["busctl", "--system", "get-property",
                  "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles",
                  "net.hadess.PowerProfiles", "ActiveProfile"]
        stdout: SplitParser {
            onRead: d => {
                const m = d.match(/"([^"]+)"/);
                if (m) root.active = m[1];
            }
        }
    }
    Timer { interval: 4000; running: true; repeat: true; triggeredOnStart: true; onTriggered: getProc.running = true }
}
