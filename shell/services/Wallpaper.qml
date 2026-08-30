pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tracks the current wallpaper and, for each one, the quietest screen region -
// used to place the desktop clock somewhere it won't sit on busy artwork.
Singleton {
    id: root

    property string path: ""
    property string anchor: "bottom-right"
    property int regionX: 0
    property int regionY: 0
    property int regionW: 0
    property int regionH: 0

    readonly property string stateFile: `${Quickshell.env("HOME")}/.config/ashura/current-wallpaper`

    FileView {
        id: wpFile
        path: root.stateFile
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const p = text().trim();
            if (p !== "" && p !== root.path) {
                root.path = p;
                analyse.running = true;
            }
        }
    }

    Process {
        id: analyse
        command: [`${Quickshell.env("HOME")}/.config/ashura/bin/quiet-region`, root.path, "1920", "1080"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/);
                if (p.length === 5) {
                    root.anchor  = p[0];
                    root.regionX = parseInt(p[1]);
                    root.regionY = parseInt(p[2]);
                    root.regionW = parseInt(p[3]);
                    root.regionH = parseInt(p[4]);
                }
            }
        }
    }
}
