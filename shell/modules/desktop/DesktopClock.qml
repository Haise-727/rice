pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.services

// Large clock over the wallpaper, below windows.
//
// Placement follows the quietest region of the wallpaper and SLIDES to it.
// The old double-move was not the animation: matugen used to write the palette
// into the shell directory, which made quickshell reload the whole shell on every
// wallpaper change - the clock reinitialised, then repositioned. The palette is
// runtime JSON now, so one wallpaper change means one move.
//
// Colour comes from the wallpaper's own Material You palette rather than plain
// black/white, choosing the mode that contrasts with the region it sits on.
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
            mask: Region {}

            readonly property string place: Config.options.desktopClock.position === "auto"
                ? Wallpaper.anchor : Config.options.desktopClock.position

            readonly property bool atTop:    place.startsWith("top")
            readonly property bool atBottom: place.startsWith("bottom")
            readonly property bool atLeft:   place.endsWith("left")
            readonly property bool atRight:  place.endsWith("right")

            // A bright region needs the LIGHT scheme's colours (which are dark inks);
            // a dark region needs the DARK scheme's (which are light inks).
            readonly property bool brightRegion: Wallpaper.luma >= 0.5
            // not readonly: Behavior cannot attach to a readonly property
            property color fg: Colours.role("primary", !brightRegion)
            property color subFg: Colours.role("onSurfaceVariant", !brightRegion)

            Behavior on fg    { ColorAnimation { duration: 500 } }
            Behavior on subFg { ColorAnimation { duration: 500 } }

            Item {
                id: clockCol
                width: childrenRect.width
                height: childrenRect.height
                readonly property int pad: 56
                readonly property int topPad: pad + Config.options.bar.height

                // Only positioned once the text has laid out - width/height are 0 on
                // the first frame, which previously threw x into the centre branch.
                readonly property bool measured: width > 0 && height > 0

                x: !measured ? win.width
                 : win.atLeft  ? pad
                 : win.atRight ? win.width - width - pad
                 : (win.width - width) / 2
                y: !measured ? win.height
                 : win.atTop    ? topPad
                 : win.atBottom ? win.height - height - pad
                 : (win.height - height) / 2

                Behavior on x { enabled: clockCol.measured; NumberAnimation { duration: 650; easing.type: Easing.InOutCubic } }
                Behavior on y { enabled: clockCol.measured; NumberAnimation { duration: 650; easing.type: Easing.InOutCubic } }

                Column {
                    spacing: -8
                    Text {
                        anchors.right: win.atRight ? parent.right : undefined
                        text: Qt.formatDateTime(dclock.date, "HH:mm")
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Config.options.desktopClock.size
                        font.bold: true
                        color: win.fg
                    }
                    Text {
                        anchors.right: win.atRight ? parent.right : undefined
                        text: Qt.formatDateTime(dclock.date, "dddd, dd MMMM")
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(Config.options.desktopClock.size * 0.18)
                        color: win.subFg
                    }
                }
            }
            SystemClock { id: dclock; precision: SystemClock.Minutes }
        }
    }
}
