pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.services

// Large clock over the wallpaper, below windows.
//
// Placement follows the quietest region of the wallpaper. It does NOT slide
// between positions: animating x/y meant the clock travelled across the screen
// (and briefly through the centre, because width is 0 until the text lays out).
// It cross-fades instead - out, snap, in.
//
// Text colour follows the region's brightness so it stays readable on light
// wallpapers, which plain on-background did not.
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
            mask: Region {}          // never intercept desktop clicks

            // Applied position. Only updated while the clock is invisible.
            property string place: Config.options.desktopClock.position === "auto"
                ? Wallpaper.anchor : Config.options.desktopClock.position
            property real luma: Wallpaper.luma

            readonly property string wanted: Config.options.desktopClock.position === "auto"
                ? Wallpaper.anchor : Config.options.desktopClock.position

            onWantedChanged: if (wanted !== place) reposition.restart()

            SequentialAnimation {
                id: reposition
                NumberAnimation { target: clockCol; property: "opacity"; to: 0; duration: 180; easing.type: Easing.OutCubic }
                ScriptAction { script: { win.place = win.wanted; win.luma = Wallpaper.luma; } }
                NumberAnimation { target: clockCol; property: "opacity"; to: 1; duration: 260; easing.type: Easing.InCubic }
            }

            readonly property bool atTop:    place.startsWith("top")
            readonly property bool atBottom: place.startsWith("bottom")
            readonly property bool atLeft:   place.endsWith("left")
            readonly property bool atRight:  place.endsWith("right")

            // Light text on dark regions, dark text on light ones.
            readonly property bool darkRegion: luma < 0.5
            readonly property color fg: darkRegion ? "#ffffff" : "#101014"
            readonly property color shadowCol: darkRegion ? Qt.rgba(0,0,0,0.55) : Qt.rgba(255,255,255,0.65)

            Column {
                id: clockCol
                spacing: -6
                opacity: 1
                readonly property int pad: 56
                readonly property int topPad: pad + Config.options.bar.height

                x: win.atLeft  ? pad
                 : win.atRight ? parent.width - width - pad
                 : (parent.width - width) / 2
                y: win.atTop    ? topPad
                 : win.atBottom ? parent.height - height - pad
                 : (parent.height - height) / 2

                Text {
                    anchors.right: win.atRight ? parent.right : undefined
                    text: Qt.formatDateTime(dclock.date, "HH:mm")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Config.options.desktopClock.size
                    font.bold: true
                    color: win.fg
                    style: Text.Outline
                    styleColor: win.shadowCol
                }
                Text {
                    anchors.right: win.atRight ? parent.right : undefined
                    text: Qt.formatDateTime(dclock.date, "dddd, dd MMMM")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(Config.options.desktopClock.size * 0.18)
                    color: win.fg
                    opacity: 0.9
                    style: Text.Outline
                    styleColor: win.shadowCol
                }
            }
            SystemClock { id: dclock; precision: SystemClock.Minutes }
        }
    }
}
