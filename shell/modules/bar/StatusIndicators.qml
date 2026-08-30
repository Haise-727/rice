import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Networking
import qs.common

// Top-right: battery and wifi only, per spec. Everything else lives behind the
// right-edge drag zone.
Row {
    id: root
    spacing: 12

    // ---- wifi ----
    // Quickshell exposes `Networking` (not `Network`); there is no activeConnection —
    // walk devices, find the connected wifi one, take its connected network's strength.
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        readonly property var wifiDev: {
            const ds = Networking.devices?.values ?? [];
            return ds.find(d => d.type === DeviceType.Wifi && d.connected) ?? null;
        }
        readonly property int strength: {
            const nets = wifiDev?.networks?.values ?? [];
            const active = nets.find(n => n.connected) ?? null;
            return active ? Math.round(active.signalStrength) : -1;
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.strength < 0 ? "睊"
                : parent.strength > 70 ? ""
                : parent.strength > 40 ? ""
                : parent.strength > 15 ? "" : ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: parent.strength < 0 ? Colours.error : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.strength >= 0
            text: parent.strength + "%"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            color: Colours.on.surfaceVariant
        }
    }

    // ---- battery ----
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        readonly property var bat: UPower.displayDevice
        readonly property int pct: bat ? Math.round(bat.percentage * 100) : -1
        readonly property bool charging: bat?.state === UPowerDeviceState.Charging

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.charging ? "" : parent.pct > 80 ? "" : parent.pct > 60 ? ""
                : parent.pct > 40 ? "" : parent.pct > 20 ? "" : ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: parent.charging ? Colours.tertiary
                 : parent.pct <= 15 ? Colours.error
                 : Colours.on.surfaceVariant
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.pct >= 0
            text: parent.pct + "%"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            color: parent.pct <= 15 ? Colours.error : Colours.on.surfaceVariant
        }
    }
}
