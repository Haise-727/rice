pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.config
import qs.zones
import qs.services

// Settings window.
//
// Deliberately covers only what gets retuned often (user's call: "if we do it for
// EVERYTHING it just becomes overloaded"). Everything else lives in
// ~/.config/ashura/config.json and is documented in CONFIG-REFERENCE.md.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("bottomRight") && ZoneManager.zonesVisible
            visible: shown || card.opacity > 0.01

            WlrLayershell.namespace: "ashura:settings"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"

            property int tab: 0
            readonly property var tabs: ["Look", "Bar", "Zones", "Notifications", "Booru"]

            MouseArea {
                anchors.fill: parent
                onClicked: ZoneManager.close("bottomRight")
            }

            Rectangle {
                id: card
                width: 660; height: 460
                anchors.centerIn: parent
                radius: 20
                color: Colours.surfaceContainer
                border.width: 1
                border.color: Colours.outline
                opacity: win.shown ? 1 : 0
                scale: win.shown ? 1 : 0.96
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                MouseArea { anchors.fill: parent }   // swallow clicks

                // ---- reusable rows ----
                component Toggle: Row {
                    property string label: ""
                    property string path: ""
                    property bool value: false
                    width: 600
                    spacing: 10
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 300
                        text: parent.label
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: Colours.on.surface
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 42; height: 22; radius: 11
                        color: parent.value ? Colours.primary : Colours.surfaceContainerHighest
                        Behavior on color { ColorAnimation { duration: 140 } }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            y: 3
                            x: parent.parent.value ? parent.width - 19 : 3
                            color: parent.parent.value ? Colours.on.primary : Colours.on.surfaceVariant
                            Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.setValue(parent.parent.path, !parent.parent.value)
                        }
                    }
                }

                component Choice: Column {
                    property string label: ""
                    property string path: ""
                    property var options: []
                    property string value: ""
                    width: 600
                    spacing: 6
                    Text {
                        text: parent.label
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: Colours.on.surface
                    }
                    Flow {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: parent.parent.options
                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool cur: modelData === parent.parent.value
                                width: ct.implicitWidth + 16; height: 24; radius: 12
                                color: cur ? Colours.primary : Colours.surfaceContainerHigh
                                Behavior on color { ColorAnimation { duration: 130 } }
                                Text {
                                    id: ct
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    color: parent.cur ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Config.setValue(parent.parent.parent.path, modelData)
                                }
                            }
                        }
                    }
                }

                component Slider2: Column {
                    property string label: ""
                    property string path: ""
                    property int value: 0
                    property int from: 0
                    property int to: 100
                    width: 600
                    spacing: 6
                    Text {
                        text: parent.label + "  " + parent.value
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: Colours.on.surface
                    }
                    Rectangle {
                        id: track
                        width: parent.width; height: 8; radius: 4
                        color: Colours.surfaceContainerHighest
                        Rectangle {
                            width: parent.width * (parent.parent.value - parent.parent.from)
                                   / Math.max(1, parent.parent.to - parent.parent.from)
                            height: parent.height; radius: 4
                            color: Colours.primary
                        }
                        MouseArea {
                            anchors.fill: parent; anchors.margins: -8
                            function set(px) {
                                const f = Math.max(0, Math.min(1, px / track.width));
                                const c = parent.parent;
                                Config.setValue(c.path, Math.round(c.from + f * (c.to - c.from)));
                            }
                            onPressed: mouse => set(mouse.x)
                            onPositionChanged: mouse => { if (pressed) set(mouse.x); }
                        }
                    }
                }

                Column {
                    anchors { fill: parent; margins: 20 }
                    spacing: 14

                    Row {
                        width: parent.width
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Ashura Settings"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true
                            color: Colours.on.surface
                        }
                        Item { width: parent.width - 300; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "config.json"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                            color: Colours.primary
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh","-c","code ~/.config/ashura/config.json || xdg-open ~/.config/ashura/config.json"])
                            }
                        }
                    }

                    Row {
                        spacing: 6
                        Repeater {
                            model: win.tabs
                            delegate: Rectangle {
                                required property int index
                                required property string modelData
                                width: tl.implicitWidth + 20; height: 26; radius: 13
                                color: win.tab === index ? Colours.primary : Colours.surfaceContainerHigh
                                Behavior on color { ColorAnimation { duration: 130 } }
                                Text {
                                    id: tl
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                    color: win.tab === index ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: win.tab = index }
                            }
                        }
                    }

                    // ---- Look ----
                    Column {
                        visible: win.tab === 0
                        spacing: 14
                        Choice {
                            label: "Palette scheme"
                            path: "palette.scheme"
                            value: Config.options.palette.scheme
                            options: ["scheme-tonal-spot","scheme-content","scheme-expressive","scheme-fidelity",
                                      "scheme-fruit-salad","scheme-monochrome","scheme-neutral","scheme-rainbow","scheme-vibrant"]
                        }
                        Choice {
                            label: "Source colour preference"
                            path: "palette.prefer"
                            value: Config.options.palette.prefer
                            options: ["saturation","less-saturation","darkness","lightness","value"]
                        }
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 150; height: 28; radius: 14
                                color: Colours.primaryContainer
                                Text {
                                    anchors.centerIn: parent; text: "apply to wallpaper"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    color: Colours.on.primaryContainer
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["sh","-c",
                                        `ASHURA_SCHEME='${Config.options.palette.scheme}' ASHURA_PREFER='${Config.options.palette.prefer}' ~/.config/ashura/bin/set-theme`])
                                }
                            }
                            Rectangle {
                                width: 130; height: 28; radius: 14
                                color: Colours.surfaceContainerHigh
                                Text {
                                    anchors.centerIn: parent; text: "random wallpaper"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    color: Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached([`${Quickshell.env("HOME")}/.config/ashura/bin/set-theme`,"--random"])
                                }
                            }
                        }
                        Toggle { label: "Desktop clock"; path: "desktopClock.enabled"; value: Config.options.desktopClock.enabled }
                        Toggle { label: "Live wallpaper (video)"; path: "wallpaper.live.enabled"; value: Config.options.wallpaper.live.enabled }
                        Text {
                            width: 600
                            wrapMode: Text.Wrap
                            text: "live: " + (LiveWallpaper.status === "" ? "idle" : LiveWallpaper.status)
                                + "   ·   power profile: " + LiveWallpaper.profile
                                + (Config.options.wallpaper.live.file === ""
                                   ? "   ·   set wallpaper.live.file in config.json" : "")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                            color: LiveWallpaper.profileAllows ? Colours.on.surfaceVariant : Colours.tertiary
                            opacity: 0.8
                        }
                        Choice {
                            label: "Desktop clock position"
                            path: "desktopClock.position"
                            value: Config.options.desktopClock.position
                            options: ["auto","top-left","top-right","bottom-left","bottom-right"]
                        }
                    }

                    // ---- Bar ----
                    Column {
                        visible: win.tab === 1
                        spacing: 14
                        Toggle { label: "Top bar"; path: "bar.enabled"; value: Config.options.bar.enabled }
                        Slider2 { label: "Bar height"; path: "bar.height"; value: Config.options.bar.height; from: 24; to: 56 }
                        Toggle { label: "Audio visualiser (cava)"; path: "cava.enabled"; value: Config.options.cava.enabled }
                        Slider2 { label: "Cava bars"; path: "cava.bars"; value: Config.options.cava.bars; from: 8; to: 64 }
                        Slider2 { label: "Workspaces"; path: "workspaces.count"; value: Config.options.workspaces.count; from: 3; to: 10 }
                        Slider2 { label: "Startup workspace"; path: "workspaces.startupWorkspace"; value: Config.options.workspaces.startupWorkspace; from: 1; to: 10 }
                    }

                    // ---- Zones ----
                    Column {
                        visible: win.tab === 2
                        spacing: 12
                        Toggle { label: "Left edge — booru"; path: "zones.leftCentre.enabled"; value: Config.options.zones.leftCentre.enabled }
                        Toggle { label: "Right edge — sidebar"; path: "zones.rightCentre.enabled"; value: Config.options.zones.rightCentre.enabled }
                        Toggle { label: "Bottom — launcher"; path: "zones.bottomCentre.enabled"; value: Config.options.zones.bottomCentre.enabled }
                        Toggle { label: "Startup workspace dashboard"; path: "startupWorkspace.enabled"; value: Config.options.startupWorkspace.enabled }
                        Toggle { label: "Per-edge exclusivity"; path: "zones.perEdgeExclusive"; value: Config.options.zones.perEdgeExclusive }
                        Slider2 { label: "Edge hover-open ms (0 = click only)"; path: "zones.rightCentre.dwellMs"; value: Config.options.zones.rightCentre.dwellMs; from: 0; to: 1200 }
                    }

                    // ---- Notifications ----
                    Column {
                        visible: win.tab === 3
                        spacing: 14
                        Toggle { label: "Do not disturb"; path: "notifications.dnd"; value: Notifs.dnd
                                 onValueChanged: Notifs.dnd = value }
                        Slider2 { label: "Timeout (ms)"; path: "notifications.timeoutMs"; value: Config.options.notifications.timeoutMs; from: 1000; to: 15000 }
                        Slider2 { label: "Critical timeout (ms)"; path: "notifications.criticalTimeoutMs"; value: Config.options.notifications.criticalTimeoutMs; from: 2000; to: 60000 }
                        Toggle { label: "Critical never expires"; path: "notifications.criticalNeverExpires"; value: Config.options.notifications.criticalNeverExpires }
                        Slider2 { label: "Popup width"; path: "notifications.width"; value: Config.options.notifications.width; from: 260; to: 560 }
                    }

                    // ---- Booru ----
                    Column {
                        visible: win.tab === 4
                        spacing: 14
                        Choice {
                            label: "Site  (* needs an API key in config.json)"
                            path: "booru.site"
                            value: Config.options.booru.site
                            options: Config.options.booru.sites
                        }
                        Toggle { label: "Blacklist filter"; path: "booru.blacklistEnabled"; value: Config.options.booru.blacklistEnabled }
                        Slider2 { label: "Results per page"; path: "booru.pageSize"; value: Config.options.booru.pageSize; from: 10; to: 100 }
                        Choice {
                            label: "Overview preview mode"
                            path: "overview.previewMode"
                            value: Config.options.overview.previewMode
                            options: ["live","event"]
                        }
                        Text {
                            width: 600
                            wrapMode: Text.Wrap
                            text: "Everything not shown here lives in ~/.config/ashura/config.json — see CONFIG-REFERENCE.md."
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                            color: Colours.on.surfaceVariant; opacity: 0.65
                        }
                    }
                }
            }
        }
    }
}
