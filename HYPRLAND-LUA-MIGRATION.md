# Planned: migrate `.conf` → `hyprland.lua`

Hyprland 0.56.2 now warns: *"You are using the .conf config format, support for which
will be removed in Hyprland 0.57."* We are one release ahead of a forced migration.

## Why this matters more than it looks

We chose `.conf` deliberately (2026-08-27) to avoid rewriting a working config. That was
right at the time, but it has cost us twice since:

1. **`hyprctl eval` is Lua-only.** It returns *"eval is only supported with the lua config
   manager"*, which is why `hl.clear_crashed_lockscreen()` is unavailable — and therefore
   why qylock's `WlSessionLock` lockscreen is unsafe here and we built our own fail-open one.
2. **illogical-impulse's dispatchers are Lua-form** (`hl.dsp.focus{...}`) and are rejected
   on `.conf`, so every interaction adapted from it needs translating.

Migrating fixes both.

## Scope

| Area | Size | Notes |
|---|---|---|
| `keybinds.conf` | 234 lines | the bulk; `bind = MOD, key, dispatcher, args` → `hl.bind(...)`. Mechanical, scriptable. |
| `rules.conf` | 93 | windowrule/layerrule → `hl.windowrule{...}` |
| `variables.conf` | 95 | `$var` → Lua locals |
| everything else | ~100 | general/decoration/input/misc/animations/execs/env/group/gestures |
| **total** | **423 non-comment lines** | |

**Ashura itself is nearly unaffected** — the shell calls `Hyprland.dispatch` in exactly one
place (`workspace <n>` in `Workspaces.qml`). Classic dispatchers are expected to keep working
over IPC under a Lua config; verify that before relying on it.

Reference: Hyprland ships `/usr/share/hypr/hyprland.lua` (356 lines, commented).

## How to do it safely

This is **boot-critical** — a broken config means no desktop.

1. Do it while the current `.conf` set is committed and pushed (it is).
2. Convert into `hyprland.lua` alongside the existing files; do **not** delete them.
   Hyprland prefers `hyprland.lua` when present, so the `.conf` set stays as a rollback.
3. Keep a TTY open (`Ctrl+Alt+F2`) while testing.
4. Rollback = `mv hyprland.lua hyprland.lua.bad` and restart Hyprland.
5. Verify in this order: it starts → keybinds work → rules apply → `hyprctl eval` works.
6. Only after that, revisit qylock's lockscreen, which becomes recoverable.

## Not urgent, but not indefinite
0.57 is not released yet and Arch has not shipped it. The forcing function is whenever
`hyprland` next updates past 0.56 — worth doing before that lands unattended, not after.
