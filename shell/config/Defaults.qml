pragma Singleton
import QtQuick

// Every tunable lives here with its default. The user's config.json overlays this,
// so a missing key is always safe and the file is the documentation.
QtObject {
    readonly property var values: ({
        // Audio. maxVolume is a multiplier: 1.5 lets output boost to 150%.
        // PipeWire allows software gain above 100%; past ~150% clipping is audible.
        audio: {
            maxVolume: 1.5
        },
        "bar": {
            "enabled": true,
            "height": 34,
            "alwaysVisible": true,        // user: "top bar always visible at 100%"
            "opacity": 1.0
        },
        "zones": {
            // Per-edge exclusivity: zones on DIFFERENT edges may be open together
            // (top + bottom fine), zones sharing an edge may not (top-left + top-right).
            "perEdgeExclusive": true,
            "topLeft":     { "enabled": true },
            "topCentre":   { "enabled": true },
            "topRight":    { "enabled": true },
            "leftCentre":  { "enabled": true, "edgeWidth": 8, "edgeSpan": 0.42, "stage2": 150, "dwellMs": 0, "width": 420 },
            "rightCentre": {
                "enabled": true,
                "edgeWidth": 8,      // px of screen edge that accepts the gesture
                "edgeSpan": 0.42,    // fraction of screen height the strip covers (middle band)
                "dwellMs": 0,        // hover-to-open; 0 = click only (user preference)
                "stage1": 60,        // drag this far -> session options
                "stage2": 190,       // drag this far -> full sidebar
                "width": 400         // sidebar width
            },
            "bottomCentre":{ "enabled": true },
            "bottomRight": { "enabled": true }
        },
        "workspaces": {
            "count": 6,
            "startupWorkspace": 6,        // the dashboard workspace
            "highlightStartup": true
        },
        "startupWorkspace": {
            "enabled": true,
            "fullscreen": true,           // hides bar + panels while focused
            "widgets": ["profile", "clock", "player", "cava", "animation", "notifications", "battery"],
            // gif/webp shown at the bottom; kurukuru is the caelestia spinner
            "animation": "file:///home/haise/dotfiles-archive-20260825/caelestia-shell-fork-1.3.4/quickshell-caelestia-fork/assets/kurukuru.gif"
        },
        "wallpaper": {
            "dir": "~/Pictures/Wallpapers",
            "live": {
                "enabled": false,
                "backend": "mpvpaper",   // mpvpaper plays any video/gif as the background
                "file": ""               // absolute path to the video
            },
            // user's rule: quiet = off, balanced/performance = on
            "livePowerProfiles": ["balanced", "performance"]
        },
        "desktopClock": {
            "enabled": true,
            "size": 96,
            // "auto" follows the quietest region of the wallpaper; or pin one of
            // top-left / top-right / bottom-left / bottom-right / middle-centre
            "position": "auto"
        },
        "palette": {
            "scheme": "scheme-tonal-spot",
            "prefer": "saturation"
        },
        "booru": {
            // safebooru and yandere work with no account; gelbooru and danbooru
            // need credentials filled in below or they return 401 / a CF challenge.
            "site": "safebooru",
            "sites": ["safebooru", "yandere", "gelbooru", "danbooru"],
            "credentials": {
                "gelbooru": { "apiKey": "", "userId": "" },
                "danbooru": { "login": "", "apiKey": "" }
            },
            "pageSize": 40,
            // Local blacklist, always on by default with a toggle in the panel.
            // Danbooru counts these against its 2-tag cap; gelbooru does not.
            "blacklist": [],
            "blacklistEnabled": true
        },
        "overview": {
            "columns": 3,
            // "live" = continuous capture (best looking, more RAM/GPU)
            // "event" = refresh on window changes only
            "previewMode": "live"
        },
        "notifications": {
            "width": 380,
            "timeoutMs": 5000,          // normal + low urgency
            "criticalTimeoutMs": 12000, // critical: longer, but it DOES go away
            "criticalNeverExpires": false,
            "dnd": false
        },
        "cava": {
            "enabled": true,
            "inBorders": false,
            "bars": 32
        }
    })
}
