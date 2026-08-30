pragma Singleton
import QtQuick
import Quickshell
import qs.config
import Quickshell.Io

// JSON-backed config. Defaults.values is the schema + fallback; config.json overlays it.
// Anything not in config.json simply uses its default, so the file can stay small.
Singleton {
    id: root

    readonly property string path: `${Quickshell.env("HOME")}/.config/ashura/config.json`
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

    // Writes only the keys that DIFFER from Defaults, so config.json stays small
    // and picks up future default changes instead of freezing today's values.
    function diffFromDefaults(cur, def) {
        let out = {};
        for (const k in cur) {
            const c = cur[k], d = def ? def[k] : undefined;
            if (c !== null && typeof c === "object" && !Array.isArray(c)) {
                const sub = diffFromDefaults(c, d);
                if (Object.keys(sub).length > 0) out[k] = sub;
            } else if (JSON.stringify(c) !== JSON.stringify(d)) {
                out[k] = c;
            }
        }
        return out;
    }

    function setValue(path, value) {
        const keys = path.split(".");
        let next = JSON.parse(JSON.stringify(root.options));
        let o = next;
        for (let i = 0; i < keys.length - 1; i++) {
            if (typeof o[keys[i]] !== "object" || o[keys[i]] === null) o[keys[i]] = {};
            o = o[keys[i]];
        }
        o[keys[keys.length - 1]] = value;
        root.options = next;
        saveTimer.restart();
    }

    // Written via a process rather than FileView.setText: setText reported no
    // error but never touched the file, even with blockWrites false.
    function save() {
        suppressReload = true;
        const json = JSON.stringify(diffFromDefaults(root.options, Defaults.values), null, 2);
        writer.command = ["sh", "-c", `cat > '${root.path}'`];
        writer.running = true;
        writer.write(json + "\n");
        unsuppress.restart();
    }

    Process {
        id: writer
        onRunningChanged: if (!running) stdinEnabled = false
        stdinEnabled: true
    }
    Timer { id: unsuppress; interval: 400; onTriggered: root.suppressReload = false }

    property bool suppressReload: false
    Timer { id: saveTimer; interval: 250; onTriggered: root.save() }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        printErrors: true
        blockWrites: false      // FileView refuses setText() unless this is false
        atomicWrites: true
        onFileChanged: if (!root.suppressReload) reload()
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
