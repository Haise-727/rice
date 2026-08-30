pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// JSON-backed config. Defaults.values is the schema + fallback; config.json overlays it.
// Anything not in config.json simply uses its default, so the file can stay small.
Singleton {
    id: root

    readonly property string path: `${Quickshell.env("HOME")}/.config/rice/config.json`
    property var options: Defaults.values
    property bool ready: false

    function deepMerge(base, over) {
        let out = JSON.parse(JSON.stringify(base));
        for (const k in over) {
            if (over[k] !== null && typeof over[k] === "object" && !Array.isArray(over[k])
                && out[k] !== undefined && typeof out[k] === "object" && !Array.isArray(out[k])) {
                out[k] = deepMerge(out[k], over[k]);
            } else {
                out[k] = over[k];
            }
        }
        return out;
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.options = root.deepMerge(Defaults.values, JSON.parse(text()));
            } catch (e) {
                console.warn("Config: config.json is not valid JSON, using defaults —", e);
                root.options = Defaults.values;
            }
            root.ready = true;
        }
        onLoadFailed: {
            // No config.json yet: defaults are correct, not an error.
            root.options = Defaults.values;
            root.ready = true;
        }
    }
}
