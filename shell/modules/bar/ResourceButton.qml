import QtQuick
import Quickshell
import qs.common
import qs.config

// Top-left: opens the resource / task manager panel.
// Placeholder action for now - the panel itself lands with the zone work.
Rectangle {
    id: root
    signal activated()

    width: 26; height: 18
    radius: 6
    color: mouse.containsMouse ? Colours.surfaceContainerHighest : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: Icons.cog
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        color: mouse.containsMouse ? Colours.primary : Colours.on.surfaceVariant
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
    }
}
