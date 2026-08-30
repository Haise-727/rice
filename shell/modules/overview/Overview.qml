pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.config
import qs.zones

// Workspace overview with LIVE window thumbnails.
//
// Each workspace tile mirrors the real screen, and each window is drawn at its
// true position scaled down, so the grid reads like a map of the desktop rather
// than a list. Captures use ScreencopyView against the toplevel's wl handle;
// Quickshell.Hyprland gives workspace -> toplevels directly, so no address
// matching is needed.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("overview")
            visible: shown || fade.opacity > 0.01

            WlrLayershell.namespace: "ashura:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"

            readonly property int cols: Config.options.overview.columns
            readonly property int count: Config.options.workspaces.count
            readonly property int rows: Math.ceil(count / cols)
            // live capture is heavier; "event" refreshes only on window changes
            readonly property bool liveCapture: Config.options.overview.previewMode === "live"

            Rectangle {
                id: fade
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.55)
                opacity: win.shown ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: ZoneManager.close("overview")
                }

                Grid {
                    id: grid
                    anchors.centerIn: parent
                    columns: win.cols
                    spacing: 18

                    readonly property real tileW: (win.width * 0.78 - (win.cols - 1) * spacing) / win.cols
                    readonly property real tileH: tileW * (win.height / win.width)

                    Repeater {
                        model: win.count
                        delegate: Rectangle {
                            id: tile
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property var ws: {
                                const all = Hyprland.workspaces?.values ?? [];
                                return all.find(w => w.id === wsId) ?? null;
                            }
                            readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                            readonly property bool isStartup: wsId === Config.options.workspaces.startupWorkspace
                            readonly property real sc: width / win.width      // screen -> tile scale

                            width: grid.tileW
                            height: grid.tileH
                            radius: 12
                            color: Colours.surface
                            border.width: isActive ? 3 : isStartup ? 2 : 1
                            border.color: isActive ? Colours.primary
                                        : isStartup ? Colours.tertiary
                                        : Colours.outline
                            clip: true

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            // windows, positioned by real geometry
                            Repeater {
                                model: tile.ws?.toplevels ?? null
                                delegate: Item {
                                    required property var modelData
                                    readonly property var geo: modelData.lastIpcObject ?? null
                                    visible: geo !== null

                                    x: geo ? (geo.at[0] - win.screen.x) * tile.sc : 0
                                    y: geo ? (geo.at[1] - win.screen.y) * tile.sc : 0
                                    width:  geo ? geo.size[0] * tile.sc : 0
                                    height: geo ? geo.size[1] * tile.sc : 0

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 5
                                        color: Colours.surfaceContainerHigh
                                        border.width: 1
                                        border.color: Colours.outline
                                    }
                                    ScreencopyView {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        captureSource: modelData.wayland ?? null
                                        live: win.shown && win.liveCapture
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Hyprland.dispatch(`focuswindow address:${modelData.address}`);
                                            ZoneManager.close("overview");
                                        }
                                    }
                                }
                            }

                            // workspace number, bottom-left
                            Rectangle {
                                anchors { left: parent.left; bottom: parent.bottom; margins: 6 }
                                width: 24; height: 20; radius: 6
                                color: tile.isActive ? Colours.primary : Colours.surfaceContainerHighest
                                opacity: 0.9
                                Text {
                                    anchors.centerIn: parent
                                    text: tile.wsId
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.bold: true
                                    color: tile.isActive ? Colours.on.primary : Colours.on.surface
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                z: -1
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Hyprland.dispatch(`workspace ${tile.wsId}`);
                                    ZoneManager.close("overview");
                                }
                            }
                        }
                    }
                }
            }

            Keys.onEscapePressed: ZoneManager.close("overview")
        }
    }
}
