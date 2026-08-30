# Ashura — checkpoint, 2026-08-30

Every item in the original spec is built. What follows is what exists, how to reach it,
what is deliberately deferred, and what has never been verified.

## Keybinds
| Key | Surface |
|---|---|
| `Super+Space` | launcher — apps; `>` or `/` for commands |
| `Super+Tab` | workspace overview (separate `qs -c overview` instance) |
| `Super+N` | right sidebar |
| `Super+B` | booru panel |
| `Super+I` | settings |
| `Super+L` | lock |
| `Ctrl+Alt+Shift+U` | **emergency unlock** |
| `Super+W` | random wallpaper + palette regen |

Edges: click, drag, or hover the **left** (booru) and **right** (sidebar) middle edges.
Hover the bar clock for the dashboard. Right-click the workspace strip for the overview.

## Surfaces
| Surface | Notes |
|---|---|
| Top bar | workspaces (startup ws outlined), clock, cava, media, VOL/BRI/BT/WIF/BAT |
| Dashboard | hover the clock — performance + calendar tabs |
| Right sidebar | uptime, quick toggles, **power profile**, volume, brightness, volume mixer, notifications |
| Left panel | booru search, thumbnail grid, site selector, blacklist toggle |
| Launcher | fuzzy app search; `>`/`/` for wallpaper, clipboard, screenshots, power… |
| Overview | adopted `quickshell-overview`, patched with drag-to-close |
| Desktop clock | placed in the quietest region of the wallpaper, contrast-aware |
| Startup workspace | ws6 — fullscreen dashboard, bar hidden |
| Notifications | Ashura owns the DBus name; toasts + sidebar list + DND |
| Lock | own overlay, **fails open**, PAM auth |
| Settings | 5 tabs; writes only the diff against defaults |
| Login screen | SDDM with qylock's NieR theme |

## Services
`Colours` (matugen palette, runtime JSON) · `Audio` · `Brightness` · `Power` · `Cava` ·
`SysStats` · `Notifs` · `Wallpaper` · `LiveWallpaper` · `Booru`

Audio/Brightness/Power are shared singletons specifically so surfaces cannot disagree —
muting collapses the sidebar slider *and* changes the bar readout, from one source.

## Escape hatches
- `~/.config/ashura/bin/ashura-unlock` — releases the lock; works from a TTY
- `~/.config/ashura/bin/sddm-revert` — restores the previous login theme
- `waybar &` — the old bar still installed as a fallback
- `mako` — still installed if Ashura's notification server is ever stopped

## Never verified
- **Lock password entry.** Requires the real password; never typed. `Super+L` and unlock
  needs a human test.
- **SDDM NieR theme at a real login.** Test-rendered only.
- **Suspend on the current kernel** beyond the one successful s2idle cycle.

## Deferred
See §26b/§26c in COMPONENTS.md: sleep-does-not-lock, in-workspace window rearranging,
media widget showing while paused, cava running while paused, animation tuning,
booru API keys for gelbooru/danbooru, GLSL shader wallpapers.
