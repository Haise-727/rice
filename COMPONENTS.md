# Linux Rice — Complete Component Catalog

**How to use this doc:** every component has a `>>> WANT:` / `<<< END` block. Write whatever
you like between those two markers — plain text, multiple lines, links, questions, half-formed
thoughts. **Nothing is quoted or formatted, so you can't break it.** Don't delete the markers;
they're how I find your answers.

```
>>> WANT:
write anything here, as many lines as you want
<<< END
```

Leave a block empty = skip it. Write `KEEP` = keep what's there now.
Plain text elsewhere in the file is fine too — I read the whole thing.

Baseline hardware/software this is written against:
- Lenovo Legion, RTX 4060 Max-Q (nvidia-open 610), single **eDP-1 1920x1080@144Hz**
- Arch, kernel 7.1.9, **Hyprland 0.56.2**, Secure Boot ON (sbctl), GRUB
- Login shell **fish** + starship; terminals kitty + foot
- Currently minimal: waybar / mako / awww / hypridle / fuzzel / swaylock-effects

Legend for "Have now": ✅ installed & running · ⚪ installed, unused · ❌ not installed
Legend for answers: 🔒 **LOCKED** (decided) · ❓ open · 💬 needs discussion

> ⚠️ **Round-2 answers below are DRAFT (💬), not final.** User explicitly said
> "this is not a final confirmation" — still iterating. Only the table below is locked.

## 🔒 Locked decisions (2026-08-27)
| Decision | Choice |
|---|---|
| Shell technology | **quickshell (QML)** — Claude writes the code |
| Palette | **Wallpaper-generated** (Material You style); user sharing an additional reference link |
| Bar position | **TOP** (old setup was a side bar — a main complaint) |
| Lock auth | **PIN / typed password ONLY** — no fingerprint, no face/IR scanners |
| Secure Boot | May be disabled **if needed** — but ALWAYS ask first |
| Settings | Integrated GUI for **frequently-retuned** things; JSON for the rest, **well documented** |
| Overview | **Live window thumbnails** (not just icons) |
| Booru rating | **No filter** — explicit content allowed |
| Repo hosting | Push to user's **own GitHub account** (Haise-727) |

## 🔒 The gap list — what caelestia did NOT provide
This is the reason the custom build exists:
1. **Booru image searcher** (§28) — no way to search/pull wallpapers from booru sites
2. **Live wallpaper support** (§9.2) — none
3. **Lock screen** (§7) — not working/present in their build
4. **GRUB screen** (§1.1) — unthemed
5. **Top bar** (§4.3) — their version was a side bar
6. **Between-workspace app switcher** (§11.1)
7. **Ambient startup workspace** (§29) — cava + music + clock + misc on a reserved workspace
8. **Integrated settings platform** (§30)

---

# 1. Boot & Early Userspace

### 1.1 Bootloader
Menu that picks the OS/kernel.
- **Have now:** ✅ GRUB 2.14, `GRUB_TIMEOUT=5`, `GFXMODE=auto`, no theme, os-prober on (dual-boot Windows)
- **Options:** GRUB (themeable, most flexible) · systemd-boot (minimal, fast, plain) · rEFInd (pretty, auto-detects) · Limine (modern, themeable)
- **Rice angle:** GRUB themes (Catppuccin, Vimix, distro themes), custom resolution, background image, font
>>> WANT:
🔒 **Themed GRUB screen** — was missing before. ⚠️ Secure Boot is ON; user OK to disable if needed but **ASK FIRST**. See §1.3.
<<< END


### 1.2 Boot splash
Hides kernel text during boot with a logo/animation.
- **Have now:** ❌ none (you see raw kernel messages)
- **Options:** Plymouth (standard; themes: spinner, bgrt, custom), or leave text-mode (some prefer it)
- **Note:** needs an mkinitcpio hook; adds ~1s boot time
>>> WANT:
what would u recommend here... some anime animation into transition would be cool, keep this open I'll search some up
<<< END


### 1.3 Secure Boot / signing
- **Have now:** ✅ Secure Boot **enabled**, sbctl managing keys, GRUB+kernel signed
- **Constraint:** anything touching the boot chain (Plymouth, new kernel, bootloader swap) must be re-signed or you won't boot
>>> WANT:

<<< END
 (usually KEEP)

### 1.4 Silent boot / kernel params
- **Have now:** `loglevel=3 quiet`
- **Options:** full silent (`quiet splash loglevel=0 rd.systemd.show_status=false`), or verbose for debugging
>>> WANT:

<<< END


---

# 2. Display Manager (Login Screen)

### 2.1 The DM itself
First graphical thing you see; handles login + session choice.
- **Have now:** ✅ SDDM (from `sddm-git`), enabled
- **Options:** SDDM (Qt, very themeable — sugar-candy, corners, sddm-astronaut) · GDM · LightDM · **greetd + tuigreet** (minimal TTY-style, fast) · ly (TUI, animated) · **no DM** (autologin → `uwsm start hyprland` from shell profile)
- **Rice angle:** this is a big visual moment — themed SDDM vs minimal tuigreet is a real aesthetic fork
>>> WANT:

<<< END


### 2.2 Session entries
- **Have now:** `hyprland.desktop`, `hyprland-uwsm.desktop`, and a **stale `caelestia.desktop`** (dead, package removed — will clean)
- **Note:** `uwsm` (universal wayland session manager) is NOT installed but a session entry references it. uwsm gives proper systemd user-session integration (better app scoping, cleaner shutdown). Worth considering.
>>> WANT:

<<< END


### 2.3 Autologin / passwordless
- **Have now:** ❌ password each boot
- **Note:** with full-disk-encryption absent, autologin is a real security tradeoff on a laptop
>>> WANT:

<<< END


---

# 3. Compositor (Hyprland)

### 3.1 Compositor choice
- **Have now:** ✅ Hyprland 0.56.2
- **Options:** Hyprland (animations, plugins, most riced) · Sway (stable, i3-like) · river (tag-based) · niri (scrollable tiling — very different feel)
>>> WANT:

<<< END
 (assume KEEP unless you say otherwise)

### 3.2 Animations & curves
- **Have now:** ✅ your `animations.conf` (preserved from before)
- **Rice angle:** bezier curves, per-type durations, workspace slide vs fade, window open/close style
>>> WANT:

<<< END


### 3.3 Decoration — blur, shadow, rounding, opacity
- **Have now:** ✅ `decoration.conf` + vars: rounding 20, border 3px, shadow on (range 20), **blur currently OFF** (`$blurEnabled = false`), opacity 1
- **Rice angle:** blur passes/size, xray blur, dim inactive, active/inactive border gradients (animated borders possible)
>>> WANT:

<<< END


### 3.4 Gaps & layout
- **Have now:** gaps in 10 / out 10 / single-window 15, **workspace gaps 150**
- **Options:** dwindle (default) · master · **hy3** (i3-like tabs/splits, plugin) · scroller plugin
>>> WANT:

<<< END


### 3.5 Hyprland plugins
- **Have now:** ❌ none
- **Options:** **hyprexpo** (workspace exposé grid) · **hyprspace** (overview w/ drag-drop) · hy3 (layout) · hyprbars (title bars) · hyprwinwrap (video wallpaper *behind* windows) · borders-plus-plus · hyprtrails
- **Note:** plugins must be rebuilt on every Hyprland update (`hyprpm update`) — a maintenance cost
>>> WANT:

<<< END


---

# 4. Bar / Panel / Status

### 4.1 The bar
- **Have now:** ✅ waybar 0.15 (minimal config I just wrote — top, 34px, plain text modules)
- **Options:** **waybar** (GTK, CSS, stable, huge module set) · **quickshell** (QML, what caelestia uses — most powerful, most work) · **AGS/Astal** (JS/TS + GTK, very flexible) · **eww** (Yuck/Lisp, widgets) · **HyprPanel** (AGS-based, batteries-included) · **fabric** (Python)
- **Tradeoff:** waybar = fast to configure, limited interactivity. quickshell/AGS = anything you can imagine, but it's real programming.
>>> WANT:
🔒 **quickshell** (QML). Claude writes the code. waybar stays installed as fallback until trusted.
<<< END


### 4.2 Bar modules — tick what you want
Workspaces (with window icons?) · window title · clock/date · calendar popup · system tray ·
audio (+ per-app mixer?) · mic · brightness · battery (+ time remaining) · network (wifi picker?) ·
bluetooth (device list?) · CPU · RAM · disk · temperature · **GPU (nvidia)** · media player (art/scrub) ·
weather · pending updates · notification bell + DND toggle · VPN · recording indicator ·
power profile switcher · idle-inhibitor toggle · custom scripts
>>> WANT:
One small button for taskmanager/resource panel liek btop, then workspaces (5) with that one special one (also a way to do the wrokspace manager tool we talked abt), Date and time in the middle which when hoevered shall activate and show a lot of stuff liek it does on caelestia, audio visualizer would be nice but it needs to go when hovered (make sections where each sections goes away when it's deignated dropdown is triggered), battery and wifi alone here, keep sound, brightness on the right side like caelestia along with logout options and notification and other stuff if dragged out from right. the gpu, ram and all that stuff should be hovered from topmiddle and come out liek caelestia top middle does on hover, weather is useless so no, notifs, dnd, vpn and all that stuff on right side drag. the sections are as follows (top left/middle/right, right middle, left middle, bottom middle, bottom right corner(settings here)) each should have appropriate hover and drag, we can decide as we go if I want something or gone. ofc this should also be manageable in the settings
<<< END


### 4.3 Bar behaviour
- Position (top/bottom/left) · auto-hide/reveal-on-hover · per-monitor · floating w/ margins · rounded · transparency · exclusive zone
>>> WANT:
🔒 **TOP bar** (explicit — the old side bar was a main complaint). Other behaviour ❓ open: auto-hide? floating w/ margins? rounded? transparency?
<<< END


---

# 5. Application Launcher

### 5.1 Launcher
- **Have now:** ✅ fuzzel (bound to tap-Super), `fuzzel.ini` exists from old setup
- **Options:** **fuzzel** (fast, native wayland, minimal) · **rofi** (wayland fork; most themeable, huge ecosystem) · wofi · **anyrun** (Rust, plugins) · **walker** (modern, many modules) · tofi (fastest) · custom (quickshell/AGS)
- **Rice angle:** centered vs top, icons, blur behind, animated, grid vs list, image previews
>>> WANT:

<<< END


### 5.2 Launcher modes wanted
apps (drun) · run command · window switcher · **clipboard history** · emoji picker · **calculator** ·
unit converter · file search · ssh hosts · power menu · web search · dictionary · color picker ·
kill process · wallpaper picker · project/repo jumper
>>> WANT:

<<< END


### 5.3 The "tap Super" behaviour
Old caelestia had tap-Super-to-launch **with interrupt** (typing/clicking cancels it, so Super+key combos still work). Currently approximated with `bindr` (fires on release) — slightly different feel.
>>> WANT:

<<< END


---

# 6. Notifications

### 6.1 Daemon
- **Have now:** ✅ mako 1.11 (config written: top-right, 8px radius, teal border, 5s timeout)
- **Options:** **mako** (light, INI config) · **dunst** (classic, very configurable) · **swaync** (notification *center* w/ history panel + DND toggle + widgets) · custom (quickshell/AGS)
- **Note:** if you want a notification **history panel**, that's swaync or a custom shell — mako has no UI
>>> WANT:

<<< END


### 6.2 Features
history/center · DND toggle · grouping · inline replies · action buttons · images/album art ·
per-app rules · urgency styling · sounds · on-screen position
>>> WANT:

<<< END


---

# 7. Lock Screen

### 7.1 Locker
- **Have now:** ✅ swaylock-effects (called by hypridle at 5min, and Super+M / Super+Alt+L)
- **Options:** **hyprlock** (Hyprland-native, most riceable — widgets, shaders, per-monitor) · **swaylock-effects** (blur/pixelate, no widgets) · gtklock (GTK modules) · custom (quickshell)
- **Rice angle:** blurred/dimmed wallpaper, big clock, date, user avatar, **media player controls**, weather, battery, failed-attempt feedback, fade-in animation
>>> WANT:
🔒 **Custom quickshell lock screen** (quickshell supports
<<< END
WlSessionLock`). Was missing entirely before. Design ❓ open — see questions in §31.`

### 7.2 Auth methods
- **Have now:** password only
- **Options:** password · **fingerprint** (fprintd — does your Legion have a reader?) · **face unlock** (Howdy, uses IR/webcam) · YubiKey
>>> WANT:
🔒 **PIN / typed password ONLY.** No fingerprint reader, no face/IR unlock. Do not build biometric paths.
<<< END


---

# 8. Idle, Power & Thermal

### 8.1 Idle daemon
- **Have now:** ✅ hypridle — lock at 5min, screen off at 10min, **no auto-suspend** (deliberately, while nvidia resume is unproven)
- **Rice angle:** dim-before-lock, different timeouts on AC vs battery, inhibit while fullscreen/video
>>> WANT:

<<< END


### 8.2 Power management
- **Have now:** ✅ power-profiles-daemon (just restored)
- **Options:** power-profiles-daemon (simple 3 profiles) · TLP (deep control) · auto-cpufreq (adaptive)
- **Relevant:** ⚠️ nvidia suspend/resume services just enabled to fix your wake hang — **needs testing**
>>> WANT:

<<< END


### 8.3 Battery / thermal
- Low-battery notification + critical action · charge limit (Legion supports conservation mode via `lenovolegionlinux`) · fan curves · thermal throttle alerts
- **Note:** you had `lenovolegionlinux-git-debug` (removed as orphan); the main package may be worth having for fan/charge control
>>> WANT:

<<< END


### 8.4 GPU mode switching
- **Have now:** ⚪ envycontrol installed (hybrid/integrated/nvidia switching)
- **Note:** on a Max-Q laptop, integrated-only mode massively improves battery
>>> WANT:

<<< END


---

# 9. Wallpaper

### 9.1 Static wallpaper daemon
- **Have now:** ✅ awww (a swww fork — binaries are `awww`/`awww-daemon`), 30 wallpapers in `~/Pictures/Wallpapers`
- **Options:** swww/awww (animated transitions, per-output) · hyprpaper (light, Hyprland-native) · swaybg (bare)
- **Rice angle:** transition types (wipe/grow/outer), random cycling on timer, per-workspace wallpapers
>>> WANT:

<<< END


### 9.2 LIVE / animated wallpaper — pick which kind
This is several very different technologies:
- **Video loop:** `mpvpaper` (mpv as wallpaper — any video/GIF; pauses when covered)
- **Shader:** `glpaper` / `shaderbg` (GLSL shaders, Shadertoy-style)
- **Wallpaper Engine (Windows) scenes:** `linux-wallpaperengine` (runs actual WE workshop items — you'd need the Steam content)
- **Behind-windows video:** `hyprwinwrap` plugin (any app becomes the wallpaper layer)
- **Audio-reactive:** cava-driven visualiser as background (caelestia had this)
- ⚠️ **All of these cost GPU + battery continuously.** On a laptop this is a real tradeoff.
>>> WANT:
💬 **YES — required.** User wants to "just run live wallpapers", plans to
**use Wallpaper Engine content**, and wants **gowall's upscaler applied to videos**.
Undecided on shader vs audio-reactive — asked what those even are; explained in §32.
→ Leading approach: **
<<< END
linux-wallpaperengine` + mpvpaper**, with GLSL/audio-reactive optional later.`

### 9.3 Wallpaper picker UI
- **Have now:** ⚪ waypaper installed (GTK picker), plus Super+W = random
- **Options:** waypaper · rofi/fuzzel with image previews · custom shell module
>>> WANT:

<<< END


---

# 10. Colour Scheme & Theming Engine

### 10.1 Colour generation
The thing that makes a rice feel *cohesive* — one palette across bar, terminal, GTK, Qt, apps.
- **Have now:** ❌ nothing (caelestia did this via `python-materialyoucolor`, now removed). Your `~/.config/hypr/scheme/` still holds a static colour conf.
- **Options:** **matugen** (Material You from wallpaper — what caelestia used, Rust, template-based) · **wallust** (fast pywal successor, actively maintained) · pywal (classic, unmaintained-ish) · **fixed hand-picked palette** (Catppuccin/Gruvbox/Rose Pine/Tokyo Night/Nord — no generation, total control)
- **Big decision:** auto-generated-from-wallpaper (changes with every wallpaper, cohesive but unpredictable) vs fixed palette (consistent, predictable, you control every hex)
>>> WANT:
💬 **Wallpaper-generated via
<<< END
gowall` if viable, else caelestia's matugen-style approach.**
Reference: **gowall** — https://github.com/Achno/gowall · docs https://achno.github.io/gowall-docs/
User explicitly wants gowall's extras too (see §33): **image upscaler** (for making wallpapers
AND upscaling live-wallpaper video), colour-theory utilities, icon theme conversion, bg removal.
→ Needs evaluation: gowall is an image-processing toolkit; matugen is a palette generator.
They may be **complementary rather than alternatives** — gowall for image ops, matugen for the
Material You palette. See §33.`

### 10.2 What gets themed by it
hyprland borders · waybar · launcher · notifications · lock screen · **terminal** · **GTK apps** ·
**Qt apps** · btop · cava · fish/starship · **VSCode** · **Firefox** · **Discord** · **Spotify** · mako · thunar
>>> WANT:

<<< END


### 10.3 GTK theming
- **Have now:** ⚪ nwg-look + lxappearance installed; papirus-icon-theme
- **Needs:** GTK3 + GTK4/libadwaita theme, icon theme, cursor theme, font
- **Note:** GTK4/libadwaita resists theming; needs `gtk4/gtk.css` overrides
>>> WANT:

<<< END


### 10.4 Qt theming
- **Have now:** ⚪ qt6ct installed (qt5ct was removed as orphan — may need re-adding for Qt5 apps)
- **Options:** qt5ct/qt6ct (palette + style) · **Kvantum** (SVG-based, much prettier) · adwaita-qt
>>> WANT:

<<< END


### 10.5 Cursor & icons & fonts
- **Have now:** cursor `sweet-cursors` @24 (referenced in your vars — verify installed), Papirus icons, **JetBrainsMono Nerd Font** (Cascadia Nerd was removed in the caelestia cascade)
- **Rice angle:** icon theme (Papirus/Tela/Colloid/Reversal), cursor (Bibata/Sweet/Phinger), UI font vs mono font vs display font
>>> WANT:

<<< END


---

# 11. Workspace & Window Management UX

### 11.1 Workspace overview — "the app slider between workspaces"
**This is the feature from your reference screenshot** — a zoomed-out grid of all workspaces
showing live window thumbnails, click/drag to switch or move windows.
- **Have now:** ❌ removed with caelestia (it had a built-in `Overview.qml`)
- **Options:**
  - **hyprexpo** (Hyprland plugin) — exposé grid of workspaces, keybind-toggled, live thumbnails. Closest drop-in.
  - **hyprspace** (plugin) — overview with drag-and-drop between workspaces
  - **caelestia/quickshell overview** — what you had; fully custom, live previews + app icons
  - **AGS/HyprPanel overview** — similar, JS-based
- **Decide:** live window *thumbnails* (needs compositor plugin or screencopy) vs just *app icons* per workspace (much cheaper, what waybar can do today)
>>> WANT:
🔒 **Live window thumbnails.** Confirmed — not just app icons.
→ Implementation: quickshell
<<< END
ScreencopyView` (wlr-screencopy) per window. Cost noted in §31.`

### 11.2 Alt-Tab / window switcher
- **Have now:** ✅ `Alt+Tab` cycles within group (`changegroupactive`) — not a global window switcher
- **Options:** hyprswitch (GUI switcher w/ previews) · rofi window mode · sway-style `focus next`
>>> WANT:

<<< END


### 11.3 Special workspaces / scratchpads
- **Have now:** ✅ `Super+S` toggles special ws; vars exist for music/comms/todo/sysmon scratchpads (bindings were caelestia's, now commented out)
- **Rice angle:** dropdown terminal (quake-style), floating music player, notes scratchpad
>>> WANT:

<<< END


### 11.4 Window rules
- **Have now:** ✅ `rules.conf` preserved (opacity, float, blur rules — caelestia layerrules commented out)
>>> WANT:

<<< END


### 11.5 Gestures (touchpad)
- **Have now:** ✅ Hyprland native: 4-finger workspace swipe, 3-finger gestures configured
- **Options:** native hyprland gestures · hyprgrass plugin (more gestures) · libinput-gestures
>>> WANT:

<<< END


---

# 12. Terminal & Shell

### 12.1 Terminal emulator
- **Have now:** ✅ kitty 0.48 (primary, `$terminal`), ✅ foot (panic-button terminal)
- **Options:** kitty (GPU, tabs/splits, images, ligatures) · foot (tiny, fast, native wayland) · alacritty (GPU, minimal) · wezterm (Lua config, multiplexer built in) · ghostty (new, fast)
- **Rice angle:** padding, opacity/blur, background image, font + ligatures, cursor trail, tab bar styling
>>> WANT:

<<< END


### 12.2 Shell + prompt
- **Have now:** ✅ fish 4.8 (login shell) + starship 1.26
- **Rice angle:** starship prompt design (powerline/minimal/two-line), git status, language versions, command duration, exit status styling
>>> WANT:

<<< END


### 12.3 Terminal extras
- **Have now:** ✅ tmux, ✅ fastfetch (has config), ✅ btop, ✅ fzf, ✅ krabby (pokemon fetch)
- **Options:** zellij (modern multiplexer) · eza/lsd (ls) · bat (cat) · zoxide (cd) · ripgrep · fd · yazi (file manager) · atuin (shell history) · cava (audio visualiser)
>>> WANT:

<<< END


---

# 13. File Management

### 13.1 GUI file manager
- **Have now:** ✅ thunar (+ archive plugin, tumbler thumbnails, ffmpegthumbnailer)
- **Options:** thunar (light, XFCE) · nautilus (GNOME, modern) · dolphin (KDE, feature-rich) · nemo · **cosmic-files**
>>> WANT:

<<< END


### 13.2 TUI file manager
- **Have now:** ❌ none
- **Options:** **yazi** (fast, image previews in kitty) · ranger · lf · nnn
>>> WANT:

<<< END


### 13.3 Disk / mounts
- NTFS `/media/Data` + `/media/Windows` auto-mounted via fstab · udiskie for USB automount · gvfs (installed)
>>> WANT:

<<< END


---

# 14. Clipboard, Screenshot, Recording

### 14.1 Clipboard
- **Have now:** ✅ cliphist + wl-clipboard (Super+C → cliphist via fuzzel)
- **Options:** cliphist (history, images) · clipse (TUI) · copyq (GUI, most features)
- **Rice angle:** image previews in history, pinned entries, per-type filtering
>>> WANT:

<<< END


### 14.2 Screenshot
- **Have now:** ✅ grim + slurp + swappy — `Print` full→clipboard, `Super+S` region→swappy, `Super+Shift+S` region→clipboard, `Super+Shift+Alt+S` region→file
- **Options:** grim/slurp (primitive, scriptable) · grimblast · hyprshot · **satty** (nicer annotation than swappy) · flameshot
- **Rice angle:** freeze-screen-while-selecting (caelestia had this — grim alone doesn't), annotation UI, auto-upload, OCR
>>> WANT:

<<< END


### 14.3 Screen recording
- **Have now:** ✅ wf-recorder (Super+Alt+R w/ audio, Ctrl+Alt+R, Super+Shift+Alt+R region)
- **Options:** wf-recorder (simple) · **gpu-screen-recorder** (NVENC, replay buffer — was removed in cascade, was installed before) · wl-screenrec (fast, VAAPI) · OBS (full production)
- **Rice angle:** instant-replay hotkey, recording indicator in bar, GIF output
>>> WANT:

<<< END


### 14.4 Colour picker / magnifier / OCR
- **Options:** hyprpicker (colour pick) · woomer/wl-zoom (magnify) · `grim+tesseract` (OCR screenshot to text)
>>> WANT:

<<< END


---

# 15. On-Screen Display (OSD)

Volume/brightness/caps-lock popups.
- **Have now:** ❌ **none** — brightness/volume keys work but show no feedback (caelestia provided the OSD)
- **Options:** **swayosd** (volume/brightness/caps, themeable) · avizo · custom (quickshell/AGS) · waybar tooltip only
- **Note:** this is the most-noticed missing piece right now — you press brightness and see nothing
>>> WANT:

<<< END


---

# 16. Audio & Media

### 16.1 Audio stack
- **Have now:** ✅ pipewire + wireplumber + pipewire-pulse/alsa/jack, pamixer, pavucontrol
- **Options add-on:** **easyeffects** (EQ, noise suppression, autogain) · noise-suppression-for-voice
>>> WANT:

<<< END


### 16.2 Music & players
- **Have now:** ✅ Spotify (spotify-launcher) + ⚪ spicetify-cli (theming), ✅ mpv, ✅ vlc, ✅ playerctl
- **Options:** spicetify themes (Comfy/Text/Dribbblish) · mpd + ncmpcpp/rmpc · YouTube Music (th-ch client) · feishin
- **Rice angle:** media widget in bar w/ album art + scrubber, lyrics display, **cava visualiser**, lock-screen media controls
>>> WANT:

<<< END


### 16.3 Audio visualiser
- **Have now:** ❌ (`libcava` was removed in the caelestia cascade)
- **Options:** cava (terminal/bar bars) · in-shell visualiser (caelestia had one) · glava (GL, desktop)
>>> WANT:

<<< END


---

# 17. Network, Bluetooth, VPN

- **Have now:** ✅ NetworkManager + nm-applet + nm-connection-editor, ✅ bluez + blueman, ⚪ cloudflared
- **Options:** GUI picker in bar (waybar network module w/ menu, or custom) · iwd (lighter wifi) · bluetuith (TUI)
- **Rice angle:** wifi picker popup from the bar rather than launching nm-connection-editor
>>> WANT:

<<< END


---

# 18. System Monitoring

- **Have now:** ✅ btop
- **Options:** btop (TUI, themeable) · **nvtop** (GPU — relevant, you have a 4060) · bottom · macchina/fastfetch · **conky**-style desktop widgets · mission-center (GUI)
- **Rice angle:** desktop widget overlay (CPU/GPU/RAM/temp), bar modules, dedicated scratchpad monitor workspace (`Ctrl+Shift+Esc` var already defined)
>>> WANT:

<<< END


---

# 19. Session, Power Menu, Logout

- **Have now:** ✅ wlogout (bound to `Ctrl+Alt+Del`)
- **Options:** wlogout (grid of buttons, themeable) · wleave (maintained fork) · rofi power menu · custom shell session screen
- **Rice angle:** blurred backdrop, icon grid, confirmation dialogs, hibernate/suspend/lock/logout/reboot/shutdown
>>> WANT:

<<< END


---

# 20. Portals, Polkit, Keyring, Session Services

Plumbing — invisible when right, very broken when wrong.
- **Have now:** ✅ xdg-desktop-portal-hyprland + -gtk (screenshare/file pickers), ✅ polkit-gnome agent, ✅ gnome-keyring (secrets — **your git/gh/VSCode creds depend on this**)
- **Options:** consider **uwsm** for proper systemd user-session scoping (app2unit already in use for app launching)
>>> WANT:

<<< END


---

# 21. Input

- **Have now:** ✅ Hyprland native input config (`input.conf`), touchpad disable-while-typing, libinput-tools
- **Options:** **keyd**/kanata (remap at kernel level — caps→esc/ctrl, home-row mods) · fcitx5 (IME, CJK input) · emoji picker · `hyprctl` per-device configs
>>> WANT:

<<< END


---

# 22. Per-App Theming

### 22.1 Browser
- **Have now:** ✅ Firefox 154
- **Options:** userChrome.css (hide tab bar, vertical tabs, match palette) · **Sidebery**/Tree Style Tab · Zen Browser (pre-riced Firefox fork) · **Note:** you have `~/.cache/zen` — Zen was installed at some point
>>> WANT:

<<< END


### 22.2 Editor
- **Have now:** ✅ VSCode 1.134 (settings symlinked from `~/temp_dots/vscode/`), ✅ neovim 0.12
- **Options:** VSCode theme matching palette · neovim distro (LazyVim/NvChad/AstroNvim/kickstart) · transparent background
>>> WANT:

<<< END


### 22.3 Discord
- **Have now:** ✅ vesktop (just installed) — Vencord built in
- **Options:** Vencord themes, custom CSS matching palette
>>> WANT:

<<< END


### 22.4 Spotify
- **Have now:** ✅ spotify-launcher + ⚪ spicetify-cli
- **Note:** spicetify needs re-applying after every Spotify update
>>> WANT:

<<< END


---

# 23. Fonts

- **Have now:** ✅ JetBrainsMono Nerd Font, Noto CJK, Noto emoji. (Cascadia Nerd, Rubik, Material Symbols were removed in the caelestia cascade — **Material Symbols matters if you want icon glyphs**)
- **Needs:** mono (terminal/code) · UI/sans (bar, menus) · display (clock, big text) · **icon font** (Material Symbols / Nerd Font glyphs) · CJK · emoji
>>> WANT:

<<< END


---

# 24. Desktop Widgets & Extras

- **Options:** desktop clock overlay · calendar · todo/notes widget · weather · system stats · music/album art · sticky notes · dock (⚪ `nwg-dock-hyprland` installed) · conky
- **Note:** caelestia had a dashboard (media/performance/weather) and desktop clock
>>> WANT:

<<< END


---

# 25. Dotfile Management & Reproducibility

**How the config itself is stored — this is what made the last setup unmaintainable.**
- **Have now:** ⚠️ configs live loose in `~/.config`, plus `~/temp_dots` (a stale upstream clone that VSCode symlinks into — load-bearing, do not delete)
- **Options:**
  - **bare git repo** (`git --git-dir=$HOME/.dotfiles`) — classic, no symlinks
  - **GNU stow** — symlink farm, simple
  - **chezmoi** — templating, secrets, multi-machine
  - **yadm** — git + encryption
  - **Nix/home-manager** — fully declarative, steepest curve
- **Strong recommendation:** whatever we build, it goes in **version control with an upstream remote** so updates are merges, not manual re-copies. This is the single fix for "caelestia is hard to modify."
>>> WANT:

<<< END


---

# 26. Open Questions For You

1. **Aesthetic direction** — reference screenshot was dark/anime/rounded. Fixed palette (Catppuccin etc.) or wallpaper-generated Material You?
2. **Bar technology** — waybar (fast, limited) or quickshell/AGS (unlimited, real code)? This decides how much is buildable.
3. **Effort/maintenance budget** — plugins + custom shell need rebuilding on updates. Low-maintenance or maximum-rice?
4. **Battery vs eye-candy** — live wallpapers/blur/animations cost real battery on a laptop.
5. **Fingerprint reader / IR camera** — does your Legion have them? (decides lock-screen auth options)
6. **What did caelestia NOT provide that you needed?** You said it "doesn't provide everything" — that list is the most valuable input here.

---

# 27. Checkpoint & Change Log

Every change gets logged here: what, where, why, how to revert.

| Date | Component | Change | Files touched | Revert |
|---|---|---|---|---|
| 2026-08-25 | Baseline | Stripped caelestia → minimal stack | `~/.config/hypr/*`, new `waybar`/`mako`/`hypridle` configs | `~/dotfiles-archive-20260825/hypr-caelestia-era/` |
| 2026-08-25 | nvidia | Enabled suspend/resume services (wake hang fix) | systemd symlinks | `systemctl disable nvidia-{suspend,resume,hibernate}` |
| 2026-08-25 | hyprland | Fixed 0.56 breakage: `misc:vfr` removed, `splitratio`→`layoutmsg` | `misc.conf`, `keybinds.conf` | `.bak` files alongside |
| 2026-08-25 | session | Removed stale `caelestia.desktop` login entry | `/usr/share/wayland-sessions/` | reinstall caelestia-shell |
| 2026-08-27 | spec | Locked: quickshell / top bar / generated palette / PIN-only auth; added §28 booru, §29 ambient ws, §30 settings | `~/rice/COMPONENTS.md` | git history |
| 2026-08-27 | **lock screen** | **REMOVED ENTIRELY** after 4 lockouts — swaylock-effects uninstalled, keybinds commented, hypridle stripped of `lock_cmd`/`before_sleep_cmd` | `hypridle.conf`, `keybinds.conf` | §34; `.bak-lockfix` files |
| 2026-08-27 | faillock | `deny 3→10`, `unlock_time 600→60` (a typo cost 10 min lockout) | `/etc/security/faillock.conf` | `/etc/security/faillock.conf.bak-20260827` |
| 2026-08-27 | palette | 🔒 CONFIRMED: **matugen** for Material You palette + **gowall** for image ops | — | — |
| 2026-08-27 | repo | Pushed to private GitHub `Haise-727/rice` | — | `gh repo delete` |

## Where everything lives
- **Active configs:** `~/.config/{hypr,waybar,mako,fuzzel}/`
- **Archive (pre-strip):** `~/dotfiles-archive-20260825/`
  - `hypr-caelestia-era/` — full original hypr config (229 keybind lines)
  - `CAELESTIA-KEYBIND-MAP.md` — every old binding → replacement
  - `CUSTOM-SHELL-PLAN.md` — tiered approach to a maintainable custom shell
  - `caelestia-shell-fork-1.3.4/` — the original fork (old API, reference only)
- **This spec:** `~/rice/COMPONENTS.md`
- **Backups:** `*.bak` / `*.bak-*` files next to each edited config

---

# 28. Booru Image Searcher 🔒 NEW

Search/browse booru sites from inside the shell, preview results, download, set as wallpaper.
- **Have now:** ❌ nothing. Named as gap #1.
- **Buildable in quickshell:** yes — JSON REST APIs + image grid + download. No external tool needed.
- **Design surface:**
  - **Sites:** Danbooru · Gelbooru · Safebooru · Konachan · yande.re · e621 · multi-site aggregate
  - **Search:** tag autocomplete (the APIs expose tag endpoints), AND/OR/exclude, rating filter, sort by score/date
  - **Results:** infinite-scroll thumbnail grid, hover preview, full-res view
  - **Actions:** download to `~/Pictures/Wallpapers` · **set as wallpaper directly** · copy URL · favourite/save tag searches
  - **Integration:** feeds §10.1 (new wallpaper → regenerate palette) and §9.3 (wallpaper picker)
- ⚠️ **Rating filter matters** — most booru APIs default to including explicit content. Needs an
  explicit default (`rating:safe`?) and a settings toggle. Also: some sites need an API key for full access.
>>> WANT:

<<< END
 💬 **No rating filter needed** — user is fine with explicit content, so no
  safe-mode default. Sites + UI surface still open.
  → Reference for the browse/preview UI: **Aino-Chan/wallpaper-selector** (§33 ref 7), which
  already does grid + **live preview while choosing**.

---

# 29. Ambient / Startup Workspace 🔒 NEW — needs a design decision

**Your requirement:** at login you land on ws1. A "combo" lives on ws2 — **cava + background
music + clock + misc widgets**. You can slide to it like any normal workspace. But if you open
or move an app there, the combo should relocate to ws3 (or behave as if it had) — **without the
cost of physically moving windows every time.** Must be disableable.

### The key insight that makes this cheap
If the widgets are **quickshell layer-shell surfaces instead of real windows**, there is nothing
to move. "Which workspace the dashboard lives on" becomes a single variable the shell renders
against. Relocating it is free and instant — no window management at all. Cava can be drawn
natively in QML from the cava data stream (caelestia did exactly this), and "background music"
can be an mpv/mpd instance the shell controls and draws UI for — so neither needs a window.

### Three implementations

**Option A — Floating dashboard (auto-shift) ★ recommended**
- Dashboard renders on *the lowest workspace ≥ 2 that has no windows*
- Open something on ws2 → dashboard is simply drawn on ws3 instead, instantly, zero cost
- Matches your literal ask ("all the stuff should go to 3") with none of the weight
- Feels like the dashboard "gets out of the way" on its own

**Option B — Pinned dashboard + new-window redirect**
- Dashboard is fixed to ws2 permanently
- Any window that would open/move onto ws2 is silently redirected to ws3
  (via a Hyprland IPC `openwindow` listener — cheap, no polling)
- ws2 becomes a true reserved space that apps can never occupy
- Closest to "no new app can be brought in"

**Option C — Hybrid (Option A + a lock toggle)**
- Default: auto-shift (A). A settings switch converts it to reserved/pinned (B).
- Costs one extra config flag; gives both behaviours.

### Either way
- Fully disableable (§30 settings toggle)
- Configurable which workspace it prefers (default 2)
- Widget set configurable: cava · music player · clock · date · weather · system stats · notes · media art
- ⚠️ Cava + music running from login is a constant background cost — small, but real on battery

>>> WANT:

<<< END
 🔒 **Option A (floating dashboard, auto-shift)** — but on **workspace 6**, not 2.
  Plus: **the workspace-number indicator in the bar must highlight** the ambient workspace so
  it's visually distinct from ordinary workspaces.
  💬 Widget set still open — confirmed so far: **cava + background music + clock**.
  Strong candidates from user's references: **player disc/vinyl UI** (§33 ref 6), weather
  dashboard (§33 ref 5). Cava style ref: **snglrTTY** black-hole visualiser (§33 ref 1).

---

# 30. Settings Platform 🔒 NEW — required

**Your requirement:** everything integrated and modifiable from one settings surface.
- **Have now:** ❌ nothing (caelestia 2.x shipped a `Settings` module; we removed it with the rest)
- **Approach:** a quickshell settings app writing to a single JSON config the shell watches
  and hot-reloads. Same pattern caelestia used (`shell.json`), but **we design the schema**, so
  every feature we build gets a settings entry by construction rather than as an afterthought.
- **Must cover, at minimum:** bar (modules/position/behaviour) · palette source & overrides ·
  wallpaper + live-wallpaper settings · lock screen · ambient workspace (§29, incl. on/off) ·
  booru (sites, rating filter, API keys) · overview · notifications · OSD · keybind display ·
  idle timeouts
- **Design questions:** single window or bar-popout? Category sidebar? Live-preview as you change
  values? Import/export profiles?
- ⚠️ **Scope warning:** a good settings GUI is often as much work as the features it configures.
  Worth deciding early whether v1 is "settings for everything" or "settings for the things
  you actually retune often, with JSON for the rest."
>>> WANT:

<<< END
 🔒 **NOT everything.** User: "if we do for EVERYTHING then it just becomes
  overloaded, so JSON for some is fine, just keep good documentation for it."
  → **Rule:** settings GUI covers what you retune often (wallpaper, palette, bar modules,
  ambient workspace on/off, live-wallpaper toggle). Everything else = documented JSON.
  → **Every JSON key must be documented** in a generated `CONFIG-REFERENCE.md`.
  💬 Single window vs bar-popout still open.

---

# 31. Open Questions — Round 2

1. **Palette reference link** — you mentioned sharing one that "does a lot of stuff". Send it and
   I'll evaluate it against matugen. This gates Phase 1.
2. **Ambient workspace:** Option A, B, or C from §29? Which widgets?
3. **Live wallpaper type:** video loop (mpvpaper) · GLSL shader · Wallpaper Engine scenes
   (needs Steam content) · audio-reactive. These are different builds — could support more than
   one, but pick a primary.
4. **Overview:** live window *thumbnails* (needs a compositor plugin or screencopy — heavier)
   or *app icons* per workspace (much cheaper)?
5. **Booru:** which sites, and what default rating filter?
6. **GRUB theme:** existing theme (Catppuccin/Vimix/etc.) or custom-designed to match the palette?
   ⚠️ Secure Boot re-signing needed either way — I will ask before touching the boot chain.
7. **Settings scope:** everything in v1, or the frequently-retuned subset first?
8. **Bar modules** (§4.2) and **launcher modes** (§5.2) — those checklists are still unfilled.
9. **Aesthetic reference** — any screenshots/videos of rices you like? Worth more than descriptions.

---

# 32. Explainer — live wallpaper technologies

Asked 2026-08-27. **Decision: GLSL shaders, no audio sync.**

- **GLSL shader** 🔒 CHOSEN — a small program the GPU runs for every pixel, every frame.
  Colour comes from math (time, position, noise), so animation never loops or repeats and the
  whole thing is a few KB of text. Flowing gradients, starfields, plasma, fluid. Thousands of
  ready-made ones on Shadertoy. **Cost:** GPU runs continuously — real battery drain on a laptop.
- **Video loop** — an actual video file played as the background (`mpvpaper`). Simplest, works
  with anything you can film or download. Loops visibly. Decoding cost is lower than a shader.
- **Wallpaper Engine scenes** — runs real WE workshop content via `linux-wallpaperengine`.
  Confirmed viable (§33 ref 2 uses it). Needs the Steam content on disk.
- **Audio-reactive** ❌ NOT WANTED for wallpaper — taps the PipeWire output, runs an FFT to split
  sound into frequency bands, drives visuals from those numbers. (This is still how **cava in the
  ambient workspace** works — that's a separate widget, still wanted.)

---

# 33. Reference projects — researched 2026-08-27

### ref 1 — snglrTTY (visualiser look for the ambient workspace)
https://github.com/the-unknown/snglrtty · Rust, MIT
- Reads default PulseAudio **monitor** source via `pactl` (works on PipeWire), 200 samples @
  44100 Hz, splits into **64 frequency bands**, draws a circle + radial bars, maps amplitude to
  ASCII `#+*.` with ANSI colour. Themes: default/fire/ocean/forest/mono; configurable bar count,
  decay, radius, "ghost mode".
- ⚠️ **Terminal ASCII only — no spectrum data export**, so it can't feed our shell directly.
- ✅ **But the approach is trivially reimplementable in QML**: same idea (audio → FFT → 64 bands →
  radial bars), drawn natively instead of as text. caelestia did exactly this via `libcava`.
  → **Plan: rebuild the *look* in QML driven by cava's raw output.** Cleaner and sharper than
  embedding a terminal, and it inherits our palette.

### ref 2 — Aino-Chan/wallpaper-selector (wallpaper picker + live preview)
https://github.com/Aino-Chan/wallpaper-selector · quickshell + QML
- Grid browser, arrow/mouse/scroll navigation, **playlist** (shift-click to queue), **command mode**
  (`:`), double-click to apply, Escape/click-outside to close.
- Deps: `ffmpeg`, **`linux-wallpaper-engine`**, `quickshell`, `pywal`, `swww`.
- ✅ **Confirms linux-wallpaperengine + quickshell works** — this is the proof-of-concept for
  running your Wallpaper Engine content.
- ⚠️ Author states the scripts are "as is… don't expect them to work out of box" →
  **use as reference, don't depend on it.**

### ref 3 — gowall (image toolkit) 🔒 ADOPTED, but not as the palette engine
https://github.com/Achno/gowall · docs https://achno.github.io/gowall-docs/
- **Upscaling:** Real-ESRGAN **ncnn Vulkan**. Needs a **Vulkan GPU** (your RTX 4060 ✅,
  `vulkan-icd-loader` already installed). Auto-downloads the model on first run.
  Scales **x2/x3/x4 only**. Models: `realesr-animevideov3` (default, anime), `realesrgan-x4plus`
  (generic), `realesrgan-x4plus-anime`.
  → **The anime models are ideal for booru wallpapers.**
  `gowall upscale <img> -s <2|3|4> -m <model>` · also `--batch` and `--dir`
- ⚠️ **VIDEO UPSCALING: the author explicitly recommends against it.** It's images-only; the
  anime-video model *could* be driven frame-by-frame through ffmpeg, but the docs say
  "I really recommend against doing that." → **Not planned. Revisit only if you insist.**
- **Other adopted features:** palette extraction (pywal-style dominant colours), recolour image
  to a theme (Catppuccin/Dracula/Gruvbox/Nord/20+, custom via `~/.config/gowall/config.yml`),
  **icon theme conversion** (svg/ico recolour), background removal, pixel-art conversion,
  compression, format conversion, OCR, GIF creation. **Supports unix pipes → scriptable.** ✅

### ⚠️ Key finding — gowall is NOT a Material You generator
gowall extracts **dominant colours, "like pywal"** — a flat set of colours.
**Material You** (what caelestia used, and what makes a UI feel coherent) is different: it derives
a full *tonal system* — primary/secondary/tertiary/surface/on-surface at many tone steps — with
guaranteed contrast pairings. A flat pywal palette can't fill that role without a lot of manual
mapping.
→ **Recommendation: use both, they're complementary.**
  - **matugen** → the Material You UI palette (bar, launcher, notifications, lock, shell)
  - **gowall** → image operations (upscale, recolour wallpapers, icon theming, bg removal)
>>> CONFIRM:

<<< END
 OK to use matugen for the palette and gowall for image ops?

### ref 4 — Shanu-Kumawat/quickshell-overview ★ DIRECT HIT for §11.1
https://github.com/Shanu-Kumawat/quickshell-overview
- **Live window thumbnails — exactly what you asked for.** Not icons.
- **Drag-and-drop windows between workspaces** onto workspace tiles
- Wayland **screencopy** for capture; `previewMode` is configurable:
  **`live`** (best visuals, more RAM) vs **`event`** (lower RAM, refreshes on window events)
  → gives us a direct performance dial if `live` proves heavy at 144Hz
- Also exposes `previewsEnabled`, `previewRecaptureDelayMs`
- **matugen integration already built in** — generates Material You into
  `Appearance.colors.qml`. Validates the matugen decision (§10.1).
- Launch: `exec-once = qs -c overview`, toggle via `Super+Tab` →
  `qs ipc -c overview call overview toggle`
- **Standalone module**, extracted from illogical-impulse specifically to be usable without
  the whole shell → **best starting point for our overview; study it, don't vendor it**
- ⚠️ Known issue upstream: "Wayland screencopy buffer management"
- Deps: Hyprland, quickshell, Qt6 (QtQuick, Quickshell.Wayland, Quickshell.Hyprland)

### ref 5 — Darkkal44/qylock ★ has BOTH lockscreens you liked
https://github.com/Darkkal44/qylock
- **30+ themes in one repo**, including the **pixel-art set** (Coffee, Dusk City, Hollow Knight,
  Minecraft, Genshin, osu!) *and* **NieR: Automata** — the two you singled out
- Two separate systems: **SDDM themes** (Qt6 declarative, video backgrounds) and a
  **quickshell lockscreen** launched via `~/.local/share/quickshell-lockscreen/lock.sh`
- Uses **`ext-session-lock-v1`** (the reason it doesn't work on Plasma)
- Deps: sddm, qt6-declarative, qt6-5compat, qt6-svg; video needs qt6-multimedia + gstreamer
- ⚠️⚠️ **NO documented crash failsafe, and no documented PAM/visual-feedback behaviour.**
  `ext-session-lock-v1` is *precisely* the protocol that stranded you on 2026-08-27 — when the
  locker dies still holding the lock, the session is unusable. **Adopting qylock as-is would
  reproduce that risk.** See §34 hard requirements before we touch any lockscreen.
  → Escape hatch to remember: `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'`

### ref 6 — doannc2212/quickshell-config (theme switcher reference)
https://github.com/doannc2212/quickshell-config
- Status bar, launcher, notification daemon, **theme picker overlay with 206 themes**,
  selection persists across restarts, syncs kitty + system dark/light
- Uses **matugen or wallust** to generate a palette from an image and repaint bar, launcher,
  notifications, kitty and Hyprland borders — the "theme switcher" pattern you liked
- Explicitly modular: "each piece works on its own, take what you like"

### ref 7 — bgibson72/yahr-quickshell (unified theming reference)
https://github.com/bgibson72/yahr-quickshell
- Hyprland + quickshell with a **theme creator** (build a palette from background + accent)
  and one theme synced across **Hyprland, GTK, Kitty, Firefox, VSCodium, Discord**
- Good reference for §10.2 (what gets themed) — the breadth we want

### still unlocated
- The **OmniSearch popup** (theme-switcher post) — user: "the pop up screen here is cool"
- The **player disc / vinyl UI + equalizer** from the matugen+quickshell post
- Weather-dashboard rice (§29 widget candidate)
→ User: these are *inspiration, not requirements* — "we don't HAVE to use them."

---

# 34. ⚠️ Lock screen — REMOVED 2026-08-27

**Four accidental lockouts in one day.** Removed entirely at user request.

**Root causes (all three compounded):**
1. `Super+M` was bound to `swaylock -f` while `$kbMusic = Super, M` — reaching for music locked
   the screen. This is why it locked "without going idle".
2. **swaylock had no config** → flat grey/white screen, no clock, no ring, no keystroke feedback.
   It was working and invisible; user typed blind into what looked like a crash.
3. **`pam_faillock` deny=3 / unlock_time=600** → three blind typos locked the account for
   10 minutes, during which *the correct password also fails*.
4. Final incident: swaylock **died while holding the session lock**, leaving Hyprland's
   "lockscreen app died" screen. Required `hyprctl --instance 0 dispatch exit` (killed the session).

**Current state:** `swaylock-effects` uninstalled · all lock keybinds commented ·
hypridle has **no `lock_cmd` and no `before_sleep_cmd`** (that dbus listener was the invisible
trigger) · screen-off at 15 min only, no password.

### 🔒 Hard requirements for any future lock screen
- **Must not be able to crash and strand the session.** A watchdog or auto-unlock-on-crash path.
- **Must show unmistakable visual feedback** — clock, password field, per-keystroke indicator,
  failed-attempt counter.
- **faillock must be made forgiving first** (still `deny=3/600` — needs a decision) or the same
  trap returns.
- Test only with a second TTY already logged in as an escape hatch.
- PIN/typed password only — no biometrics.
