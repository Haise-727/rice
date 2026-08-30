pragma Singleton
import QtQuick

// Every tunable lives here with its default. The user's config.json overlays this,
// so a missing key is always safe and the file is the documentation.
QtObject {
    readonly property var values: ({
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
            "leftCentre":  { "enabled": false },
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
            "widgets": ["profile", "clock", "player", "cava", "animation", "notifications", "battery"]
        },
        "wallpaper": {
            "dir": "~/Pictures/Wallpapers",
            "live": { "enabled": false, "backend": "mpvpaper" },
            // user's rule: quiet = off, balance/performance = on
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
            "site": "gelbooru",
            "sites": ["gelbooru", "danbooru"],
            "blacklist": [],
            "blacklistEnabled": true
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
