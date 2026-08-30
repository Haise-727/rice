pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.common
import qs.config
import qs.zones

// Right-edge sidebar. Slides in when ZoneManager opens "rightCentre".
//
// Notifications are NOT here yet: taking the org.freedesktop.Notifications DBus
// name means replacing mako, which also means building the popup, or the user
// loses notifications entirely. That lands as its own change.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("rightCentre") && ZoneManager.zonesVisible
            visible: shown || panel.x < panel.width

            WlrLayershell.namespace: "ashura:sidebar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; bottom: true; right: true }
            implicitWidth: Config.options.zones.rightCentre.width
            color: "transparent"

            HyprlandFocusGrab {
                active: win.shown
                windows: [win]
                onCleared: ZoneManager.close("rightCentre")
            }

            PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

            Rectangle {
                id: panel
                width: parent.width
                height: parent.height
                color: Colours.surfaceContainer
                x: win.shown ? 0 : width
                Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

                Column {
                    anchors { fill: parent; margins: 20; topMargin: Config.options.bar.height + 20 }
                    spacing: 18

                    // ---------- header ----------
                    Row {
                        width: parent.width
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Uptime " + upt.pretty
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Item { width: parent.width - 210; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Icons.power
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                            color: Colours.error
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["wlogout"])
                            }
                        }
                    }

                    // ---------- quick toggles ----------
                    Row {
                        spacing: 10
                        Repeater {
                            model: [
                                { glyph: Icons.wifi, on: (Networking.wifiEnabled ?? false), act: "wifi" },
                                { glyph: Icons.bluetooth, on: (Bluetooth.defaultAdapter?.enabled ?? false), act: "bt" },
                                { glyph: Icons.volHigh, on: !(Pipewire.defaultAudioSink?.audio?.muted ?? false), act: "mute" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                width: 54; height: 40; radius: 20
                                color: modelData.on ? Colours.primary : Colours.surfaceContainerHigh
                                Behavior on color { ColorAnimation { duration: 160 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.glyph
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                                    color: modelData.on ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.act === "wifi")
                                            Quickshell.execDetached(["nmcli", "radio", "wifi",
                                                Networking.wifiEnabled ? "off" : "on"]);
                                        else if (modelData.act === "bt")
                                            Quickshell.execDetached(["bluetoothctl", "power",
                                                (Bluetooth.defaultAdapter?.enabled ?? false) ? "off" : "on"]);
                                        else if (Pipewire.defaultAudioSink?.audio)
                                            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
                                    }
                                }
                            }
                        }
                    }

                    // ---------- volume ----------
                    Column {
                        width: parent.width; spacing: 6
                        Text {
                            text: "Volume  " + (Pipewire.defaultAudioSink?.audio
                                  ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "--")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Rectangle {
                            id: volTrack
                            width: parent.width; height: 8; radius: 4
                            color: Colours.surfaceContainerHigh
                            Rectangle {
                                width: parent.width * (Pipewire.defaultAudioSink?.audio?.volume ?? 0)
                                height: parent.height; radius: 4
                                color: Colours.primary
                            }
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -8
                                onPressed: mouse => setVol(mouse.x)
                                onPositionChanged: mouse => { if (pressed) setVol(mouse.x); }
                                function setVol(px) {
                                    const a = Pipewire.defaultAudioSink?.audio;
                                    if (a) a.volume = Math.max(0, Math.min(1, px / volTrack.width));
                                }
                            }
                        }
                    }

                    // ---------- brightness ----------
                    Column {
                        width: parent.width; spacing: 6
                        Text {
                            text: "Brightness  " + (bri.pct >= 0 ? bri.pct + "%" : "--")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Rectangle {
                            id: briTrack
                            width: parent.width; height: 8; radius: 4
                            color: Colours.surfaceContainerHigh
                            Rectangle {
                                width: parent.width * Math.max(0, bri.pct) / 100
                                height: parent.height; radius: 4
                                color: Colours.tertiary
                            }
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -8
                                onPressed: mouse => setBri(mouse.x)
                                onPositionChanged: mouse => { if (pressed) setBri(mouse.x); }
                                function setBri(px) {
                                    const p = Math.max(1, Math.min(100, Math.round(px / briTrack.width * 100)));
                                    Quickshell.execDetached(["brightnessctl", "set", p + "%"]);
                                }
                            }
                        }
                    }

                    Item { width: 1; height: 4 }
                    Text {
                        text: "Notifications, volume mixer and calendar land next."
                        width: parent.width
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                        color: Colours.on.surfaceVariant; opacity: 0.5
                        wrapMode: Text.Wrap
                    }
                }
            }

            // uptime
            QtObject {
                id: upt
                property string pretty: "--"
            }
            FileView {
                id: uptFile
                path: "/proc/uptime"
                onLoaded: {
                    const s = parseFloat(text().split(" ")[0]);
                    if (!isNaN(s)) {
                        const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
                        upt.pretty = h > 0 ? `${h}h ${m}m` : `${m}m`;
                    }
                }
            }
            Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: uptFile.reload() }

            // brightness readout
            QtObject { id: bri; property int pct: -1 }
            FileView {
                id: briF
                path: "/sys/class/backlight/nvidia_0/brightness"
                onLoaded: { const v = parseInt(text()); if (!isNaN(v)) bri.pct = Math.round(v * 100 / 100); }
            }
            Timer { interval: 300; running: true; repeat: true; onTriggered: briF.reload() }
        }
    }
}
