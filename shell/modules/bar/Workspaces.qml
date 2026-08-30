pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.config
import qs.zones

// Fixed set of workspace pips. The startup workspace (default 6) is highlighted
// differently so it reads as "not an ordinary workspace".
//
// NOTE: dispatchers use CLASSIC syntax ("workspace 3"). Hyprland 0.55's Lua form
// (hl.dsp.focus{...}) is rejected on a .conf setup - verified 2026-08-30.
Row {
    id: root
    spacing: 4

    readonly property int count: Config.options.workspaces.count
    readonly property int startupWs: Config.options.workspaces.startupWorkspace
    readonly property bool markStartup: Config.options.workspaces.highlightStartup
    readonly property int activeWs: Hyprland.focusedWorkspace?.id ?? 1

    function occupied(id) {
        const ws = Hyprland.workspaces.values.find(w => w.id === id);
        return ws !== undefined && ws.lastIpcObject?.windows > 0;
    }

    Repeater {
        model: root.count
        delegate: Rectangle {
            id: pip
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: wsId === root.activeWs
            readonly property bool isStartup: root.markStartup && wsId === root.startupWs
            readonly property bool hasWindows: root.occupied(wsId)

            width: active ? 26 : 18
            height: 18
            radius: height / 2

            color: active      ? Colours.primary
                 : hasWindows  ? Colours.surfaceContainerHighest
                               : "transparent"

            // The startup workspace keeps a visible outline even when empty,
            // so it is always distinguishable from ordinary workspaces.
            border.width: isStartup ? 2 : 0
            border.color: active ? Colours.on.primary : Colours.tertiary

            Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on color  { ColorAnimation  { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: pip.wsId
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.bold: pip.active || pip.isStartup
                color: pip.active ? Colours.on.primary
                     : pip.hasWindows ? Colours.on.surface
                     : Colours.on.surfaceVariant
                opacity: pip.active || pip.hasWindows || pip.isStartup ? 1 : 0.45
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) Quickshell.execDetached(["qs", "ipc", "-c", "overview", "call", "overview", "toggle"]);
                    else Hyprland.dispatch(`workspace ${pip.wsId}`);
                }
                onEntered: pip.scale = 1.12
                onExited: pip.scale = 1.0
            }
            Behavior on scale { NumberAnimation { duration: 120 } }
        }
    }
}
