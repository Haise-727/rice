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
- [x] **ACCEPTED** — **Keybind cheatsheet overlay**. 119 binds and a dead Alt key
      on this machine; a searchable overlay is navigation, not decoration.

---

## Packaging — both A and B ship as standalone projects  🔒 DECIDED 2026-08-31

The zone system and the dev cockpit are to be **releasable on their own**, not
just parts of Ashura. That is an architecture constraint, and it is cheapest to
honour from the first line rather than untangled later.

### Layout

```
~/rice/
  shell/                 Ashura - consumes the packages, owns nothing of them
  packages/
    qs-zones/            edge-gesture framework   -> future standalone repo
    qs-cockpit/          dev cockpit              -> future standalone repo
```

### Rules each package follows

- **Own module namespace and `qmldir`** (`module qszones`), never `qs.*`.
- **No imports from Ashura.** Not `qs.config`, not `qs.common`, not `qs.services`.
  A package that reaches into the shell cannot be extracted.
- **Own config with complete defaults**, same Defaults/Config pattern that already
  works here — a package must run correctly with no config file at all.
- **Colours arrive through an adapter, not a singleton.** The package declares the
  roles it needs and ships a neutral fallback palette; Ashura injects its Material
  You colours. This is what lets someone else drop it into a different shell.
- **`standalone.qml` entry point.** `qs -p packages/qs-zones/standalone.qml` must
  run the thing on its own.
- Own README, LICENSE, and a screenshot.

### The separability test

**If it does not run standalone, it is not decoupled.** Running each package's
`standalone.qml` is the check, and it should be run every time the package
changes — coupling creeps in silently otherwise.

### Cockpit specifically: split the data layer from the UI

The cockpit's value is the data, not the panel. So:

- **`cockpitd`** — a plain script (Python) that emits JSON: repos, containers,
  ports, disk, failed units, time tracking. No Qt, no compositor.
- **The QML panel just renders that JSON.**

Three payoffs: the data layer is testable without a compositor, it is useful on
its own as a CLI (`cockpitd --json | jq`), and *that* is the part worth showing
for DevOps/backend work. The panel becomes a thin view over it.

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
- [x] **ACCEPTED, lives inside the dev cockpit** — time per workspace/project per
      day. Feeds the cockpit's repo rows, so hours attach to the project they
      belong to rather than being a standalone widget.
- [ ] **Clipboard zone with image previews** — cliphist already stores images.
- [ ] **Quick capture** — append a timestamped note to a file from anywhere.
- [ ] **Window search by typing** — keyboard-first fuzzy window switcher
      (no Alt+Tab, since Alt is dead).

**Machine-specific (Legion / 4060)**
- [ ] GPU load, temp and VRAM in the bar or cockpit.
- [ ] Fan and power-profile switching from the bar.
- ~~Battery charge limit~~ — **declined 2026-08-31**: settable from Windows, and
  the BIOS is not trusted to honour it from Linux.
- [ ] legionaura RGB control from the settings panel.

**Polish with teeth**
- ~~DND auto-engage on fullscreen games~~ — **declined 2026-08-31**: no gaming on
  Linux. Revisit only if that changes.
- ~~Wallpaper-aware bar contrast~~ — **not needed, closed 2026-08-31.** The bar is
  `Colours.surface`, fully opaque, so its text and background come from the same
  regenerated palette and are contrasty by construction. It already adapts to the
  wallpaper — via the palette, not via luma. Only surfaces drawn *directly onto*
  the wallpaper (desktop clock, startup workspace) need the luma rule.
- [ ] Notification rules: per-app mute, priority colouring.
- [ ] Media: lyrics and album art in the dashboard.
- [ ] Settings: validate-and-revert on bad config writes.

---

## E — Visionary directions (2026-08-31)

**The thesis:** every rice *displays* things. Almost none of them *know* things.
The differentiator is not another widget — it is an environment with awareness of
your work, your machine and your context. A, B and C below already point that way;
these push it further. Nothing here is committed.

### E1 — Modes: switch the whole environment at once
The machine has modes — Study, Deep Work, Ops, Watch. Switching one changes
wallpaper and palette, which zones are enabled, DND state, the cockpit's filter,
even the power profile. One action reconfigures everything instead of you setting
six things by hand. Cheap to build once C exists, because the palette and
wallpaper machinery is already there.

### E2 — Workspace = project  ★ the strongest idea here
Bind a workspace to a repo. Enter ws3 and: the cockpit filters to that repo, a
terminal opens at its path, time accrues to *that project*, its wallpaper and
palette load. Projects become first-class citizens of the window manager rather
than folders you happen to `cd` into. This is the piece that ties A, B and C into
one thing instead of three panels, and nothing else out there does it.

### E3 — Zones as a framework, not as drawers
The packaging decision above implies this: a zone is declared by a small manifest
(edge, stages, content component) and appears. Ashura then becomes *a consumer of
its own framework*. That reframes the release from "my drawers" to "an
edge-gesture framework for quickshell" — which is a real gap in that ecosystem,
and a far better thing to put your name on.

### E4 — A command palette for the machine
One fuzzy surface over windows, workspaces, repos, containers, ports, files,
settings and keybinds — that also *acts*: "kill port 3000", "prune docker",
"rename ws3 study", "wallpaper dark". VSCode's Ctrl+Shift+P, but for the whole
system. The launcher is already most of the input half; the cockpit's data layer
is most of the query half. Note this **subsumes the keybind cheatsheet** — the
cheatsheet becomes one view over the palette rather than a separate overlay.

### E5 — Busy-ness awareness: what is this machine doing?
Track long-running work — builds, `pacman`, ffmpeg, downloads, Claude Code
sessions — with progress and a notification on completion. Answers "why is the fan
loud" and "is that done yet" without hunting through terminals. Fits the cockpit's
data layer directly.

### E6 — An environment that reacts
On battery: fewer animations, blur off, dimmer palette. Late at night: warmer
scheme. Build running: the edge itself shows progress (which needs A's live edge
affordances). The environment responds to state instead of being a static
configuration.

### E7 — Session replay
The cockpit will already record time per workspace. Recording *layout* too is a
small step: "what was I doing at 3pm yesterday" restores that workspace's window
arrangement and app set.

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
