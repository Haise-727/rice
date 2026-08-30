import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common

// Active player title + play/pause. Hidden when nothing is playing.
Row {
    id: root
    spacing: 6
    visible: player !== null

    readonly property var player: {
        const ps = Mpris.players.values;
        if (!ps || ps.length === 0) return null;
        return ps.find(p => p.isPlaying) ?? ps[0];
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.player?.isPlaying ? "" : ""      // pause / play glyphs
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        color: Colours.on.surfaceVariant
        MouseArea {
            anchors.fill: parent; anchors.margins: -4
            onClicked: if (root.player?.canTogglePlaying) root.player.togglePlaying()
        }
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            const t = root.player?.trackTitle ?? "";
            return t.length > 32 ? t.slice(0, 31) + "…" : t;
        }
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        color: Colours.on.surfaceVariant
    }
}
