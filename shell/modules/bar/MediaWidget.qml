import QtQuick
import Quickshell
import qs.services
import qs.common

// Active player title + play/pause. Hidden when nothing is playing.
Row {
    id: root
    spacing: 6
    visible: Media.has


    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Media.playing ? Icons.pause : Icons.play
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        color: Colours.on.surfaceVariant
        MouseArea {
            anchors.fill: parent; anchors.margins: -4
            onClicked: Media.toggle()
        }
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            const t = Media.title;
            return t.length > 32 ? t.slice(0, 31) + "…" : t;
        }
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        color: Colours.on.surfaceVariant
    }
}
