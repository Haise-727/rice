# Rice Build — Implementation Plan

Companion to `COMPONENTS.md` (the spec you fill in). This is *how* we build it.

---

## Guiding principle

**The last setup failed because config was a loose, untracked copy.** Everything here is
designed so that a year from now, `git pull && yay -Syu` still works. Concretely:

1. **Version control before anything else.** No config change happens outside git.
2. **Configure > fork.** Only write code where config genuinely can't express it.
3. **One component at a time, verified working, committed.** No big-bang rewrites.
4. **The fallback always stays installed** until the replacement is trusted.

---

## Phase 0 — Foundation (do first, regardless of your spec answers)

**0.1 Dotfiles under version control**
- Init `~/.dotfiles` (bare repo) or chezmoi — your pick from §25
- Import current *working* minimal config as commit #1 — this is the known-good baseline
- Push to a private GitHub repo → machine-independent recovery
- **Acceptance:** `git log` shows the baseline; a fresh clone reproduces the current desktop

**0.2 Fix the two known-open items**
- ⚠️ **Test suspend/resume** — nvidia services enabled but unproven. If it still hangs, we
  investigate before building anything on top.
- Add OSD (§15) — brightness/volume keys currently give zero feedback. Smallest, highest-value fix.

**0.3 Architecture — 🔒 DECIDED**
- **Shell tech:** quickshell (QML) — Claude writes the code
- **Palette:** wallpaper-generated — *pending user's reference link before choosing the generator*
- **Bar:** top position
- **Auth:** PIN/password only, no biometrics

---

## Phase 1 — Palette & theming pipeline

Do this *before* visual components, so everything built after inherits it.
- Choose generator (matugen/wallust) or fixed scheme
- Write templates for: hyprland, waybar, terminal, GTK, Qt, mako, launcher, btop
- Wire wallpaper-change → regenerate → reload (if generated)
- **Acceptance:** change wallpaper (or edit palette), every surface updates coherently
- **Commit per template**

---

## Phase 2 — quickshell foundation + core surfaces

**2.0 Project skeleton (before any UI)**
- New git repo `~/rice/shell/` — our own quickshell config, **not a caelestia fork**
- Establish from commit #1: config schema (`config.json`) + hot-reload + settings-driven
  everything. Every feature added later gets a settings entry **by construction** (§30), which
  is the thing caelestia made hard.
- Palette module reads generated colours (Phase 1) → single source of truth for all QML
- **Acceptance:** empty bar renders on top, reads config, hot-reloads on config change

**2.1 Surfaces, in dependency order** — each verified before the next:
1. **Bar** (top) — modules per §4.2
2. **Launcher** — modes per §5.2
3. **Notifications** — incl. history/centre
4. **OSD** — volume/brightness/caps (currently missing entirely)
5. **Lock screen** (`WlSessionLock`) — **PIN/password only**
6. **Power/session menu**
- **Rule:** waybar/mako/fuzzel stay installed until each replacement is trusted
- **Acceptance per item:** survives a full Hyprland restart, not just live-reload

---

## Phase 3 — Workspace UX

- **Overview / between-workspace app switcher** (§11.1) — gap #6
  - quickshell route (chosen tech) — thumbnails vs app icons still ❓ (§31 Q4)
- **Ambient workspace** (§29) — gap #7. Layer-shell widgets, so relocation is free.
  Build after the bar, since it reuses the same palette + config plumbing.
- Window switcher, scratchpads, refined window rules
- **Acceptance:** overview opens/closes smoothly at **144Hz**, no stutter; ambient workspace
  shifts instantly with zero window movement

---

## Phase 4 — Wallpaper, booru & atmosphere

- Static wallpaper + transitions + cycling
- **Live wallpaper** (§9.2) — gap #2. Type still ❓ (§31 Q3)
- **Booru searcher** (§28) — gap #1. Feeds wallpaper + palette pipeline.
- Desktop widgets (§24)
- **Acceptance:** measure idle GPU draw before/after live wallpaper; you decide if the cost
  is worth it on battery

---

## Phase 5 — Boot & login polish

Deliberately last — highest risk, lowest daily impact, Secure Boot complicates it.
- **GRUB theme** — gap #4
- Plymouth splash (mkinitcpio hook + re-sign)
- Display manager theme or swap
- **Acceptance:** reboot **twice** successfully before considering it done

### ⚠️ Safety protocol for this phase (agreed 2026-08-27)
- **I will ask before every boot-chain action.** No exceptions.
- Secure Boot may be disabled if it blocks progress — **but only with explicit go-ahead**
- Bootable USB on hand before starting
- Snapshot `/boot`, `/etc/default/grub`, and sbctl state before the first change
- Verify `sbctl verify` clean after every change that touches a signed binary

---

## Phase 6 — Per-app theming

Firefox userChrome, VSCode, vesktop/Vencord, spicetify, btop, fastfetch.
Low risk, cosmetic, do anytime after Phase 1.
- **Note:** spicetify needs re-applying after Spotify updates — a recurring cost

---

## Checkpointing protocol

Every change follows this loop:
1. `git checkout -b <component>` — work on a branch
2. Make the change; **write the old value/file into the change log** (`COMPONENTS.md` §27)
3. Verify live (and after a compositor restart)
4. Commit with what+why; merge to main
5. Update the §27 table with the revert command

**Rollback tiers:**
- Single config → `git checkout <file>` or the `.bak` beside it
- A whole component → `git revert <commit>`
- Total → reset to the Phase-0.1 baseline commit
- Nuclear → `~/dotfiles-archive-20260825/` (pre-strip state) still exists, untouched

**Panic buttons that must never break:**
- `SUPER+Return` → foot terminal (already bound, survives shell failure)
- A TTY (`Ctrl+Alt+F2`) always works
- Keep `waybar` installed even if replaced — instant fallback bar

---

## Settings-first build rule 🔒

Because §30 requires everything to be tunable from one place, we invert the usual order:
**a feature is not "done" until it has a settings entry.** Practically:
1. Add the config key + default to the schema
2. Build the feature reading from config
3. Add the settings-GUI control
4. Only then commit as complete

This is what stops us re-creating "caelestia is hard to modify."

## Working loop with the user

Agreed 2026-08-27: **the user fills in `COMPONENTS.md`, Claude reads it, responds with
suggestions and questions, and we build the doc up together until it's final.** No code
until the relevant section is settled.

## Immediate blockers
1. **Palette reference link** — gates Phase 1, which gates all visual work
2. **§29 ambient workspace: Option A/B/C**
3. **§31 Q3** live wallpaper type, **Q4** overview thumbnails-vs-icons
These three unblock Phases 1, 3 and 4 respectively.
