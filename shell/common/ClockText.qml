import QtQuick
import Quickshell
import qs.services

// The shell's clock, in one place. It was previously re-implemented in five
// surfaces, each picking its own colours, which is why the startup workspace
// drifted out of step with everything else.
//
// `surface` decides how colours are chosen:
//   "shell"     drawn on one of our own panels -> plain palette roles
//   "wallpaper" drawn straight over the wallpaper -> contrast-aware, picking the
//               light or dark scheme based on how bright that region is
Column {
    id: root

    property int size: 40
    property bool showDate: true
    property string timeFormat: "HH:mm"
    property string dateFormat: "dddd, dd MMMM"
    property string surface: "shell"
    property int precision: SystemClock.Minutes
    property bool alignRight: false

    readonly property bool overWallpaper: surface === "wallpaper"
    readonly property bool brightBehind: overWallpaper && Wallpaper.luma >= 0.5

    property color accent: overWallpaper ? Colours.role("primary", !brightBehind) : Colours.primary
    property color subtle: overWallpaper ? Colours.role("onSurfaceVariant", !brightBehind)
                                         : Colours.on.surfaceVariant
    Behavior on accent { ColorAnimation { duration: 400 } }
    Behavior on subtle { ColorAnimation { duration: 400 } }

    spacing: Math.round(-size * 0.07)

    Text {
        anchors.right: root.alignRight ? parent.right : undefined
        text: Qt.formatDateTime(clk.date, root.timeFormat)
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: root.size
        font.bold: true
        color: root.accent
    }
    Text {
        visible: root.showDate
        anchors.right: root.alignRight ? parent.right : undefined
        text: Qt.formatDateTime(clk.date, root.dateFormat)
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Math.max(10, Math.round(root.size * 0.18))
        color: root.subtle
    }
    SystemClock { id: clk; precision: root.precision }
}
