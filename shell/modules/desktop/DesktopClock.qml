pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.services

// Large clock drawn over the wallpaper, below windows.
// Placement follows the quietest region of the current wallpaper unless the
// user pins a fixed corner in config.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: Config.options.desktopClock.enabled
            WlrLayershell.namespace: "ashura:desktopclock"
            WlrLayershell.layer: WlrLayer.Background
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            // Background layer, so it must never eat clicks meant for the desktop.
            mask: Region {}

            readonly property string place: Config.options.desktopClock.position === "auto"
                ? Wallpaper.anchor
                : Config.options.desktopClock.position

            readonly property bool atTop:   place.startsWith("top")
            readonly property bool atBottom: place.startsWith("bottom")
            readonly property bool atLeft:  place.endsWith("left")
            readonly property bool atRight: place.endsWith("right")

            Column {
                id: clockCol
                spacing: -6
                // keep clear of the bar when the quiet region is along the top
                readonly property int pad: 56
                readonly property int topPad: pad + Config.options.bar.height

                x: win.atLeft  ? pad
                 : win.atRight ? parent.width - width - pad
                 : (parent.width - width) / 2
                y: win.atTop    ? topPad
                 : win.atBottom ? parent.height - height - pad
                 : (parent.height - height) / 2

                Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                Text {
                    anchors.right: win.atRight ? parent.right : undefined
                    text: Qt.formatDateTime(dclock.date, "HH:mm")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Config.options.desktopClock.size
                    font.bold: true
                    color: Colours.on.background
                    style: Text.Raised
                    styleColor: Qt.rgba(0, 0, 0, 0.35)
                }
                Text {
                    anchors.right: win.atRight ? parent.right : undefined
                    text: Qt.formatDateTime(dclock.date, "dddd, dd MMMM")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(Config.options.desktopClock.size * 0.18)
                    color: Colours.on.background
                    opacity: 0.85
                    style: Text.Raised
                    styleColor: Qt.rgba(0, 0, 0, 0.35)
                }
            }
            SystemClock { id: dclock; precision: SystemClock.Minutes }
        }
    }
}
