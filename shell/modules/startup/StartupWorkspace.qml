pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import qs.common
import qs.config
import qs.zones
import qs.services

// Fullscreen dashboard shown while the startup workspace (default 6) is focused.
//
// Per spec the top bar is hidden here and everything lives inside this surface:
// its own clock at top-middle, profile, media player with cava, an idle
// animation, notifications, and battery/system readouts.
Scope {
    id: root

    readonly property int wsId: Config.options.workspaces.startupWorkspace
    readonly property bool onStartupWs: Hyprland.focusedWorkspace?.id === wsId
        && Config.options.startupWorkspace.enabled

    // Drives ZoneManager.dashboardMode, which hides the bar and every zone.
    onOnStartupWsChanged: ZoneManager.dashboardMode = onStartupWs

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: root.onStartupWs
            WlrLayershell.namespace: "ashura:startup"
            WlrLayershell.layer: WlrLayer.Bottom     // above wallpaper, below windows
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            mask: Region {}                          // never steal clicks

            Component.onCompleted: SysStats.acquire()
            Component.onDestruction: SysStats.release()

            // ---------- clock, top middle ----------
            Column {
                anchors { top: parent.top; topMargin: 60; horizontalCenter: parent.horizontalCenter }
                spacing: -10
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clk.date, "HH:mm")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 130
                    font.bold: true
                    color: Colours.primary
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clk.date, "dddd, dd MMMM")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    color: Colours.on.surfaceVariant
                }
            }
            SystemClock { id: clk; precision: SystemClock.Seconds }

            // ---------- profile, top left ----------
            Row {
                anchors { top: parent.top; left: parent.left; margins: 46 }
                spacing: 14
                Rectangle {
                    width: 56; height: 56; radius: 28
                    color: Colours.primaryContainer
                    Text {
                        anchors.centerIn: parent
                        text: (Quickshell.env("USER") ?? "?").charAt(0).toUpperCase()
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 24; font.bold: true
                        color: Colours.on.primaryContainer
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: Quickshell.env("USER") ?? ""
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17; font.bold: true
                        color: Colours.on.surface
                    }
                    Text {
                        text: "up " + upt.pretty
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                        color: Colours.on.surfaceVariant
                    }
                }
            }
            QtObject { id: upt; property string pretty: "--" }
            FileView {
                id: uptF
                path: "/proc/uptime"
                onLoaded: {
                    const s = parseFloat(text().split(" ")[0]);
                    if (!isNaN(s)) {
                        const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
                        upt.pretty = h > 0 ? `${h}h ${m}m` : `${m}m`;
                    }
                }
            }
            Timer { interval: 60000; running: win.visible; repeat: true; triggeredOnStart: true; onTriggered: uptF.reload() }

            // ---------- battery + system, top right ----------
            Column {
                anchors { top: parent.top; right: parent.right; margins: 46 }
                spacing: 6

                Repeater {
                    model: [
                        { k: "BAT", v: (UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) + "%" : "--") },
                        { k: "CPU", v: Math.round(SysStats.cpuPct) + "%" + (SysStats.cpuTemp >= 0 ? "  " + SysStats.cpuTemp + "°C" : "") },
                        { k: "RAM", v: SysStats.memUsed + " / " + SysStats.memTotal },
                        { k: "GPU", v: (SysStats.gpuPct >= 0 ? SysStats.gpuPct + "%" : "--") + (SysStats.gpuTemp >= 0 ? "  " + SysStats.gpuTemp + "°C" : "") }
                    ]
                    delegate: Text {
                        required property var modelData
                        anchors.right: parent.right
                        text: modelData.k + "  " + modelData.v
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: Colours.on.surfaceVariant
                    }
                }
            }

            // ---------- media player + cava, bottom left ----------
            Column {
                anchors { bottom: parent.bottom; left: parent.left; margins: 46 }
                spacing: 10
                width: 460

                readonly property var player: {
                    const ps = Mpris.players.values;
                    if (!ps || ps.length === 0) return null;
                    return ps.find(p => p.isPlaying) ?? ps[0];
                }

                Text {
                    text: parent.player ? (parent.player.trackTitle ?? "") : "nothing playing"
                    width: parent.width
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; font.bold: true
                    color: Colours.on.surface
                    elide: Text.ElideRight
                }
                Text {
                    visible: parent.player !== null
                    text: parent.player ? (parent.player.trackArtist ?? "") : ""
                    width: parent.width
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    color: Colours.on.surfaceVariant
                    elide: Text.ElideRight
                }

                // cava spectrum
                Row {
                    spacing: 3
                    height: 46
                    Component.onCompleted: Cava.acquire()
                    Component.onDestruction: Cava.release()
                    Repeater {
                        model: Config.options.cava.bars
                        delegate: Rectangle {
                            required property int index
                            width: 5
                            radius: 2
                            anchors.verticalCenter: parent.verticalCenter
                            height: Math.max(3, (Cava.values[index] ?? 0) / 100 * 46)
                            color: Colours.primary
                            opacity: 0.9
                            Behavior on height { NumberAnimation { duration: 60 } }
                        }
                    }
                }
            }

            // ---------- notifications, bottom right ----------
            Column {
                anchors { bottom: parent.bottom; right: parent.right; margins: 46 }
                spacing: 8
                width: 380

                Text {
                    anchors.right: parent.right
                    text: Notifs.list.values.length > 0
                        ? Notifs.list.values.length + " notification" + (Notifs.list.values.length === 1 ? "" : "s")
                        : "no notifications"
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                    color: Colours.on.surfaceVariant
                }
                Repeater {
                    model: Math.min(3, Notifs.list.values.length)
                    delegate: Rectangle {
                        required property int index
                        readonly property var n: Notifs.list.values[Notifs.list.values.length - 1 - index]
                        width: 380
                        height: nc.implicitHeight + 16
                        radius: 10
                        color: Qt.rgba(Colours.surfaceContainer.r, Colours.surfaceContainer.g,
                                       Colours.surfaceContainer.b, 0.75)
                        Column {
                            id: nc
                            anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
                            spacing: 2
                            Text {
                                width: parent.width
                                text: parent.parent.n?.appName ?? ""
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                color: Colours.primary; elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: parent.parent.n?.summary ?? ""
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                color: Colours.on.surface; elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            // ---------- idle animation, bottom centre ----------
            AnimatedImage {
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 40 }
                source: Config.options.startupWorkspace.animation
                playing: win.visible
                speed: 1.0
                width: 160
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
            }
        }
    }
}
