# Ashura — Roadmap

Living document. Update status as things land; add ideas at the bottom of each
section rather than rewriting history.

**Status key:** `[ ]` not started · `[~]` in progress · `[x]` done · `[?]` needs a decision

---

## Where we actually are (2026-08-31)

All eight original gap-list items exist and the shell is 3.5k lines of QML. But
the honest read is: **a competent reimplementation of a standard quickshell rice,
plus two novel panels.** A wifi picker and an OSD are table stakes — caelestia,
illogical-impulse and end-4 all ship them. The only structurally *different* thing
here is the edge-zone system, and it is the least developed part.

Chosen identity (2026-08-31): **zone system** + **dev cockpit** first, universal
image→palette loop last.

---

## P0 — Missing basics (asked for, never built)

These do not make the rice unique; they make it not-annoying. Build first.

- [ ] **Own OSD** (§15) — volume/brightness/caps popup. Currently shells out to
      swayosd, which is why it looks nothing like the rest.
- [ ] **Wifi picker** (§17, "yep do the rice") — bar only *displays* `WIF 63%`.
      Want: click → network list → connect/forget, no nm-connection-editor.
- [ ] **Bluetooth device picker** — currently an on/off toggle only. Want pair,
      connect, disconnect, battery level where exposed.
- [ ] **Wallpaper picker UI** (§9.3) — wide preview rectangles, two rows:
      static and live. Only `Super+W` random exists today.
- [ ] **Per-app task manager** (§18) — Windows-style per-process list with kill.
      `qps` is bound but it is a separate GTK app, not part of the rice.
- [ ] **Power/logout surface** — right-edge drag should reveal it with a gif
      (§15), not shell out to `wlogout`.
- [ ] **Keybind cheatsheet overlay** — 119 binds now, and the Alt key is dead on
      this machine. A searchable overlay is genuinely useful, not decoration.

---

## A — Zone system as the identity  🔒 CHOSEN

Progressive edge-drag is the one thing here nobody else has. Right now zones just
toggle a panel; the drag distance is measured (`dragProgress`) but unused.

### Core
- [ ] **Drag stages per edge** — peek → panel → full surface, with the stage
      chosen by drag distance. Right edge per §15: peek = quick toggles,
      panel = notification centre, full = power menu.
- [ ] **Rubber-band resistance** at stage boundaries so stages are *felt*, not
      just crossed. Snap with a spring, not a linear tween.
- [ ] **Flick vs scrub** — a fast flick jumps to the next stage; a slow drag
      scrubs continuously and follows the finger back.
- [ ] **Position along the edge matters** — right-middle vs right-top give
      different surfaces (already implied by "right middle hover" in §15).
- [ ] **Pin past full** — dragging beyond 100% pins the surface open until
      dismissed, so a panel can be kept without holding a gesture.

### Enhancements
- [ ] **Live edge affordances** — the edge itself reacts: notification pending
      makes the right edge glow, booru results ready pulses the left.
- [ ] **Corner zones** as a second axis (4 corners, e.g. top-left = overview).
- [ ] **Cross-edge gestures** — drag left edge → right edge as a workspace fling.
- [ ] **Keyboard parity** — every zone stage reachable by bind, since gestures
      are not always convenient and the Alt key is dead.
- [ ] **Zone content is lazy** — stages only instantiate on approach, so a
      four-stage edge does not cost four surfaces at rest.

---

## B — Dev cockpit  🔒 CHOSEN

A zone that knows the machine and the work. Practically useful, and doubles as a
portfolio piece for the DevOps/cloud direction.

### Repos
- [ ] Scan `~/Coding/Projects/*`, `~/rice`, `~/.config` — branch, dirty file
      count, ahead/behind, last-commit age.
- [ ] Row actions: open in VSCode, terminal at path, fetch, stash.
- [ ] **"What changed today"** — commits across every repo, since granular
      history is something you care about.
- [ ] Warn on: unpushed commits older than N days, detached HEAD, stash piling up.

### Machine
- [ ] **Containers** — running (name, image, ports, CPU/mem), stopped count,
      image and volume disk usage.
- [ ] **Disk pressure** — root fs %, NTFS free, biggest offenders (docker,
      pacman cache, `~/.cache`). You hit 92% once; this shows it coming.
- [ ] **Port map** — what is listening on which port and which process owns it.
- [ ] **Failed systemd user units** surfaced instead of discovered later.
- [ ] **One-glance health line**: disk · RAM · GPU · failed units · dirty repos.

### Actions (all confirm first)
- [ ] Prune docker / clear pacman cache / empty trash, each showing the space it
      would reclaim *before* running.

---

## C — Any image → wallpaper → palette  🔒 CHOSEN, LAST PRIORITY

Explicitly **not** booru-only — booru is mediocre and this must work for any
image on the machine. Treated as QoL, done after A and B.

- [ ] **Unified source model** — local folders, booru sites, pasted URL, all in
      one picker with the same interaction.
- [ ] Index `~/Pictures`, `/media/Data/Wallpapers`, plus arbitrary folders.
- [ ] **Live preview on the real desktop** before committing.
- [ ] **Palette preview** — see the generated scheme before applying it.
- [ ] Favourites and local tags, independent of any booru's tags.
- [ ] **Per-workspace wallpaper + palette**, so workspaces have identities.
- [ ] "Match my current palette" — find local images close to the active scheme.
- [ ] Drag an image file onto a zone to set it.

---

## D — Further ideas (unsorted, not yet chosen)

Kept here so they are not lost. Nothing below is committed.

**Genuinely useful**
- [ ] **Screen OCR** — select region → text to clipboard (`grim` + tesseract).
      You flagged OCR in §14.2 and nothing was built.
- [ ] **Per-workspace app profiles** — your original ask ("apps per workspace"):
      define a workspace's app set, launch it in one action.
- [ ] **Time per workspace/project per day** — you have a GMAT project and
      several repos; where the hours actually went is real data.
- [ ] **Clipboard zone with image previews** — cliphist already stores images.
- [ ] **Quick capture** — append a timestamped note to a file from anywhere.
- [ ] **Window search by typing** — keyboard-first fuzzy window switcher
      (no Alt+Tab, since Alt is dead).

**Machine-specific (Legion / 4060)**
- [ ] GPU load, temp and VRAM in the bar or cockpit.
- [ ] Fan and power-profile switching from the bar.
- [ ] Battery charge limit (sysfs threshold) — real battery-health win.
- [ ] legionaura RGB control from the settings panel.

**Polish with teeth**
- [ ] **DND auto-engage** when a `steam_app_*` window is fullscreen — the window
      rule already identifies them.
- [ ] **Wallpaper-aware bar contrast** — the clock already does this; the bar
      does not, and it sits over the wallpaper too.
- [ ] Notification rules: per-app mute, priority colouring.
- [ ] Media: lyrics and album art in the dashboard.
- [ ] Settings: validate-and-revert on bad config writes.

---

## Deferred (from COMPONENTS.md §26b)

- [ ] Sleep does not lock — `before_sleep_cmd` never restored after the 2026-08-27
      lockout fixes. Also no lock-on-idle.
- [ ] Overview: rearranging windows *within* a workspace snaps back.
- [ ] Desktop clock animation easing wants another pass.
- [ ] Media widget shows while paused; cava runs while paused.
- [ ] Hyprland Lua migration follow-ups: verify `Super+U` (move out of group) and
      `Super+Shift+,` (lock group) behave right — several Lua spellings validate.
- [ ] qylock's animated lockscreen is now viable (`hl.clear_crashed_lockscreen()`
      exists in the Lua API). Revisit when the lock gets attention.
