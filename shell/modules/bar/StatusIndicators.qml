import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.common

// Top-right cluster. Spec eventually wants only battery + wifi here with the rest
// behind the right-edge drag zone, but these are the day-to-day readouts and the
// drag zone doesn't exist yet, so they live here for now.
Row {
    id: root
    spacing: 12

    // Pipewire needs the sink bound before its audio properties are readable.
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    component Indicator: Row {
        property string glyph: ""
        property string label: ""
        property color tint: Colours.on.surfaceVariant
        spacing: 5
        anchors.verticalCenter: parent?.verticalCenter ?? undefined
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.glyph
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
            color: parent.tint
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.label !== ""
            text: parent.label
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: parent.tint
        }
    }

    // ---- volume ----
    Indicator {
        readonly property var sink: Pipewire.defaultAudioSink?.audio ?? null
        readonly property int pct: sink ? Math.round(sink.volume * 100) : -1
        glyph: !sink ? "" : sink.muted ? "" : pct > 50 ? "" : pct > 0 ? "" : ""
        label: pct >= 0 && !(sink?.muted ?? false) ? pct + "%" : ""
        tint: (sink?.muted ?? false) ? Colours.error : Colours.on.surfaceVariant
        MouseArea {
            anchors.fill: parent
            onClicked: if (parent.sink) parent.sink.muted = !parent.sink.muted
        }
    }

    // ---- brightness ----
    Indicator {
        id: bright
        property int pct: -1
        glyph: ""
        label: pct >= 0 ? pct + "%" : ""
        Process {
            id: brightProc
            running: true
            command: ["sh", "-c", "echo $((100 * $(brightnessctl g) / $(brightnessctl m)))"]
            stdout: SplitParser { onRead: d => bright.pct = parseInt(d) }
        }
        Timer { interval: 2000; running: true; repeat: true; onTriggered: brightProc.running = true }
    }

    // ---- bluetooth ----
    Indicator {
        readonly property var adapter: Bluetooth.defaultAdapter ?? null
        readonly property int connected: (Bluetooth.devices?.values ?? []).filter(d => d.connected).length
        visible: adapter !== null
        glyph: !(adapter?.enabled ?? false) ? "" : connected > 0 ? "" : ""
        label: connected > 0 ? String(connected) : ""
        tint: connected > 0 ? Colours.primary : Colours.on.surfaceVariant
    }

    // ---- wifi ----
    Indicator {
        readonly property var wifiDev: {
            const ds = Networking.devices?.values ?? [];
            return ds.find(d => d.type === DeviceType.Wifi && d.connected) ?? null;
        }
        readonly property int strength: {
            const nets = wifiDev?.networks?.values ?? [];
            const active = nets.find(n => n.connected) ?? null;
            return active ? Math.round(active.signalStrength) : -1;
        }
        glyph: strength < 0 ? "睊" : strength > 70 ? "" : strength > 40 ? "" : strength > 15 ? "" : ""
        label: strength >= 0 ? strength + "%" : ""
        tint: strength < 0 ? Colours.error : Colours.on.surfaceVariant
    }

    // ---- battery ----
    Indicator {
        readonly property var bat: UPower.displayDevice
        readonly property int pct: bat ? Math.round(bat.percentage * 100) : -1
        readonly property bool charging: bat?.state === UPowerDeviceState.Charging
        glyph: charging ? "" : pct > 80 ? "" : pct > 60 ? "" : pct > 40 ? "" : pct > 20 ? "" : ""
        label: pct >= 0 ? pct + "%" : ""
        tint: charging ? Colours.tertiary : pct <= 15 ? Colours.error : Colours.on.surfaceVariant
    }
}
