pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Video / animated wallpaper via mpvpaper, layered under everything.
//
// Power-profile aware, per spec: quiet (low-power) turns it off, balanced and
// performance allow it. Read from /sys/firmware/acpi/platform_profile rather
// than powerprofilesctl, which is broken on this machine.
Singleton {
    id: root

    property string profile: "balanced"
    readonly property bool profileAllows:
        (Config.options.wallpaper.livePowerProfiles ?? []).includes(profile)
    readonly property string source: Config.options.wallpaper.live.file ?? ""
    readonly property bool wanted:
        Config.options.wallpaper.live.enabled && source !== "" && profileAllows
    property bool running: false
    property string status: ""

    FileView {
        id: profFile
        path: "/sys/firmware/acpi/platform_profile"
        onLoaded: {
            const p = text().trim();
            // map the firmware's names onto the config's vocabulary
            root.profile = p === "low-power" ? "quiet"
                         : p === "max-power" ? "performance"
                         : p;
        }
    }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: profFile.reload() }

    onWantedChanged: wanted ? start() : stop()

    function start() {
        if (running) return;
        // -o mutes and loops; "-l background" puts it beneath windows
        proc.command = ["mpvpaper", "-o",
                        "no-audio loop input-ipc-server=/tmp/ashura-mpvpaper.sock",
                        "-l", "background", "-f", "*", root.source];
        proc.running = true;
        running = true;
        status = "playing";
    }

    function stop() {
        proc.running = false;
        Quickshell.execDetached(["pkill", "-x", "mpvpaper"]);
        running = false;
        status = profileAllows ? "stopped" : `off (power profile: ${profile})`;
    }

    Process {
        id: proc
        onExited: { root.running = false; if (root.status === "playing") root.status = "exited"; }
    }

    Component.onCompleted: if (wanted) start()
}
