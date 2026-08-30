import QtQuick
import Quickshell
import qs.common
import qs.zones

// Centre clock. Hover opens the top-middle dashboard zone;
// double-click toggles the desktop clock drawn over the wallpaper.
Text {
    id: root
    signal desktopClockToggled()

    text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    font.bold: true
    color: mouse.containsMouse ? Colours.on.surface : Colours.primary
    Behavior on color { ColorAnimation { duration: 120 } }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        onEntered: ZoneManager.open("topCentre")
        onDoubleClicked: root.desktopClockToggled()
    }
}
