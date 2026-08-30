import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.common

// Top-right readouts. Each carries a short text tag as well as its glyph:
// icons alone were not identifiable at 12px. Tags can be turned off later.
Row {
    id: root
    spacing: 14

    // Pipewire audio properties do not resolve until the node is tracked.
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    readonly property var sinkAudio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property int volPct: sinkAudio ? Math.round(sinkAudio.volume * 100) : -1
    readonly property bool muted: sinkAudio?.muted ?? false

    property int briPct: -1
    Process {
        id: briProc
        running: true
        command: ["sh", "-c", "echo $((100 * $(brightnessctl g) / $(brightnessctl m)))"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d); if (!isNaN(v)) root.briPct = v; } }
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: briProc.running = true }

    readonly property var btAdapter: Bluetooth.defaultAdapter ?? null
    readonly property int btCount: (Bluetooth.devices?.values ?? []).filter(d => d.connected).length

    readonly property var wifiDev: {
        const ds = Networking.devices?.values ?? [];
        return ds.find(d => d.type === DeviceType.Wifi && d.connected) ?? null;
    }
    readonly property int wifiPct: {
        const nets = wifiDev?.networks?.values ?? [];
        const a = nets.find(n => n.connected) ?? null;
        if (!a) return -1;
        // signalStrength is 0..1, NOT 0..100 - rounding it directly gave "1%".
        const s = a.signalStrength;
        return Math.round(s <= 1 ? s * 100 : s);
    }

    readonly property var bat: UPower.displayDevice
    readonly property int batPct: bat ? Math.round(bat.percentage * 100) : -1
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging

    // ---------- volume ----------
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.muted ? "" : root.volPct > 50 ? "" : ""
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: root.muted ? Colours.error : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.volPct < 0 ? "--" : root.muted ? "mute" : root.volPct + "%"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: root.muted ? Colours.error : Colours.on.surfaceVariant
        }
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted
        }
    }

    // ---------- brightness ----------
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.briPct < 0 ? "--" : root.briPct + "%"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: Colours.on.surfaceVariant
        }
    }

    // ---------- bluetooth ----------
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        visible: root.btAdapter !== null
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: root.btCount > 0 ? Colours.primary : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.btCount > 0 ? String(root.btCount) : "off"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: root.btCount > 0 ? Colours.primary : Colours.on.surfaceVariant
        }
    }

    // ---------- wifi ----------
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.wifiPct < 0 ? "" : ""
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: root.wifiPct < 0 ? Colours.error : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.wifiPct < 0 ? "off" : root.wifiPct + "%"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: root.wifiPct < 0 ? Colours.error : Colours.on.surfaceVariant
        }
    }

    // ---------- battery ----------
    Row {
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.charging ? "" : root.batPct > 80 ? "" : root.batPct > 60 ? ""
                : root.batPct > 40 ? "" : root.batPct > 20 ? "" : ""
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: root.charging ? Colours.tertiary : root.batPct <= 15 ? Colours.error : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batPct < 0 ? "--" : root.batPct + "%"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: root.charging ? Colours.tertiary : root.batPct <= 15 ? Colours.error : Colours.on.surfaceVariant
        }
    }
}
