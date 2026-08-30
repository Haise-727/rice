pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Palette read at RUNTIME from ~/.config/ashura/palette.json (written by matugen).
//
// It deliberately lives outside the shell directory: quickshell watches its own
// config dir and reloads the whole shell when a file there changes, which made
// every wallpaper change restart the shell and jump the desktop clock twice.
//
// Exposes both Material You modes, so a widget can pick whichever contrasts with
// whatever it is drawn on: Colours.dark.primary / Colours.light.primary.
// The bare roles (Colours.primary, Colours.on.surface) follow the dark scheme,
// which is what the shell chrome uses.
Singleton {
    id: root

    property var dark:  ({})
    property var light: ({})
    property bool ready: false

    function role(name, wantDark) {
        const src = wantDark ? root.dark : root.light;
        return src[name] !== undefined ? src[name] : "#888888";
    }

    // convenience accessors for shell chrome (dark scheme)
    readonly property color background: dark.background ?? "#151515"
    readonly property color surface: dark.surface ?? "#151515"
    readonly property color surfaceContainer: dark.surfaceContainer ?? "#202020"
    readonly property color surfaceContainerHigh: dark.surfaceContainerHigh ?? "#2a2a2a"
    readonly property color surfaceContainerHighest: dark.surfaceContainerHighest ?? "#333333"
    readonly property color outline: dark.outline ?? "#777777"
    readonly property color primary: dark.primary ?? "#9ccfd8"
    readonly property color primaryContainer: dark.primaryContainer ?? "#33484d"
    readonly property color secondary: dark.secondary ?? "#9c9cd8"
    readonly property color tertiary: dark.tertiary ?? "#d8c79c"
    readonly property color error: dark.error ?? "#eb6f92"

    readonly property QtObject on: QtObject {
        readonly property color background: root.dark.onBackground ?? "#e6e6e6"
        readonly property color surface: root.dark.onSurface ?? "#e6e6e6"
        readonly property color surfaceVariant: root.dark.onSurfaceVariant ?? "#b8b8b8"
        readonly property color primary: root.dark.onPrimary ?? "#101014"
        readonly property color primaryContainer: root.dark.onPrimaryContainer ?? "#e6e6e6"
    }

    FileView {
        path: `${Quickshell.env("HOME")}/.config/ashura/palette.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text());
                root.dark = d.dark ?? ({});
                root.light = d.light ?? ({});
                root.ready = true;
            } catch (e) {
                console.warn("Colours: palette.json invalid —", e);
            }
        }
    }
}
