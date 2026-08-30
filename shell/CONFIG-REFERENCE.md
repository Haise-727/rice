# Ashura config reference

Every tunable, its default, and whether the settings GUI exposes it.

User config lives at `~/.config/ashura/config.json` and **overlays** these defaults —
only keys that differ need to be present, and the settings GUI writes exactly that diff.
A missing key always falls back to its default, so the file cannot break the shell.
Invalid JSON logs a warning and the shell runs on defaults alone.

> Generated from `config/Defaults.qml` — that file is the source of truth.

```jsonc
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
```

## Exposed in the settings GUI
Opened from the bottom-right zone. Deliberately partial — it covers what gets
retuned often, not every key, so it stays usable.

| Tab | Covers |
|---|---|
| Look | palette scheme + source preference, apply/random wallpaper, desktop clock on/off and position |
| Bar | bar on/off, height, cava on/off + bar count, workspace count, startup workspace |
| Zones | each edge zone on/off, startup dashboard, per-edge exclusivity, hover-open delay |
| Notifications | DND, normal and critical timeouts, critical-never-expires, popup width |
| Booru | site, blacklist filter, page size, overview preview mode |

## Only in JSON
- `booru.credentials` — gelbooru needs `apiKey` + `userId`; danbooru needs `login` + `apiKey`.
  Without them those sites return 401 / a Cloudflare challenge and are shown dimmed.
- `booru.blacklist` — tag list, applied as `-tag`. Note danbooru counts these against
  its 2-tag API limit; gelbooru does not.
- `wallpaper.livePowerProfiles` — power profiles in which live wallpaper may run.
- `startupWorkspace.animation` — file:// URL of the gif shown on the dashboard.
- `zones.*.edgeWidth` / `edgeSpan` / `stage1` / `stage2` — edge trigger geometry.
- `overview.columns`, `desktopClock.size`, `notifications.width`.
