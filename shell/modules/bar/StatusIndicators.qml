import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.common

// Top-right readouts.
//
// Two layout rules that bit us here:
//  * children of a Row may NOT use horizontal anchors - a MouseArea with
//    anchors.fill collapsed the volume entry to zero width and it vanished
//    with no error. Clickable entries are a MouseArea WRAPPING a Row instead.
//  * icons alone were unreadable at 12px, so each entry carries a short tag.
Row {
    id: root
    spacing: 14

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // ---------- data ----------
    readonly property var sinkAudio: Pipewire.defaultAudioSink?.audio ?? null
    readonly property int volPct: sinkAudio ? Math.round(sinkAudio.volume * 100) : -1
    readonly property bool muted: sinkAudio?.muted ?? false

    // Brightness is read straight from sysfs rather than by shelling out to
    // brightnessctl on a timer - that was the 1-2s lag.
    property int briRaw: -1
    property int briMax: 100
    readonly property int briPct: briRaw < 0 ? -1 : Math.round(briRaw * 100 / briMax)
    FileView {
        id: briFile
        path: "/sys/class/backlight/nvidia_0/brightness"
        onLoaded: { const v = parseInt(text()); if (!isNaN(v)) root.briRaw = v; }
    }
    FileView {
        path: "/sys/class/backlight/nvidia_0/max_brightness"
        onLoaded: { const v = parseInt(text()); if (!isNaN(v) && v > 0) root.briMax = v; }
    }
    Timer { interval: 200; running: true; repeat: true; onTriggered: briFile.reload() }

    readonly property int btCount: (Bluetooth.devices?.values ?? []).filter(d => d.connected).length
    readonly property bool btOn: Bluetooth.defaultAdapter?.enabled ?? false

    readonly property int wifiPct: {
        const ds = Networking.devices?.values ?? [];
        const dev = ds.find(d => d.type === DeviceType.Wifi && d.connected) ?? null;
        const nets = dev?.networks?.values ?? [];
        const a = nets.find(n => n.connected) ?? null;
        if (!a) return -1;
        const s = a.signalStrength;          // 0..1, not 0..100
        return Math.round(s <= 1 ? s * 100 : s);
    }

    readonly property var bat: UPower.displayDevice
    readonly property int batPct: bat ? Math.round(bat.percentage * 100) : -1
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging

    // ---------- one reusable entry ----------
    component Entry: Row {
        property string tag: ""
        property string value: ""
        property color tint: Colours.on.surfaceVariant
        spacing: 5
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.tag
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.bold: true
            color: parent.tint; opacity: 0.65
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: parent.tint
        }
    }

    // ---------- volume (clickable: MouseArea wraps the Row) ----------
    MouseArea {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: volEntry.implicitWidth
        implicitHeight: volEntry.implicitHeight
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted
        Entry {
            id: volEntry
            tag: "VOL"
            value: root.volPct < 0 ? "--" : root.muted ? "mute" : root.volPct + "%"
            tint: root.muted ? Colours.error : Colours.on.surfaceVariant
        }
    }

    Entry {
        anchors.verticalCenter: parent.verticalCenter
        tag: "BRI"
        value: root.briPct < 0 ? "--" : root.briPct + "%"
    }

    Entry {
        anchors.verticalCenter: parent.verticalCenter
        tag: "BT"
        value: !root.btOn ? "off" : root.btCount > 0 ? String(root.btCount) : "on"
        tint: root.btCount > 0 ? Colours.primary : Colours.on.surfaceVariant
    }

    Entry {
        anchors.verticalCenter: parent.verticalCenter
        tag: "WIF"
        value: root.wifiPct < 0 ? "off" : root.wifiPct + "%"
        tint: root.wifiPct < 0 ? Colours.error : Colours.on.surfaceVariant
    }

    Entry {
        anchors.verticalCenter: parent.verticalCenter
        tag: "BAT"
        value: root.batPct < 0 ? "--" : root.batPct + "%" + (root.charging ? "+" : "")
        tint: root.charging ? Colours.tertiary : root.batPct <= 15 ? Colours.error : Colours.on.surfaceVariant
    }
}
