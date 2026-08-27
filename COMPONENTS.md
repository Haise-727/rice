# Linux Rice — Complete Component Catalog

**How to use this doc:** every component has a `>>> WANT:` line. Fill it in with either
a link (repo/screenshot/video) or a plain description and I'll pick the implementation.
Leave blank = skip it. Write `KEEP` = keep what's there now.

Baseline hardware/software this is written against:
- Lenovo Legion, RTX 4060 Max-Q (nvidia-open 610), single **eDP-1 1920x1080@144Hz**
- Arch, kernel 7.1.9, **Hyprland 0.56.2**, Secure Boot ON (sbctl), GRUB
- Login shell **fish** + starship; terminals kitty + foot
- Currently minimal: waybar / mako / awww / hypridle / fuzzel / swaylock-effects

Legend for "Have now": ✅ installed & running · ⚪ installed, unused · ❌ not installed
Legend for answers: 🔒 **LOCKED** (decided) · ❓ open · 💬 needs discussion

## 🔒 Locked decisions (2026-08-27)
| Decision | Choice |
|---|---|
| Shell technology | **quickshell (QML)** — Claude writes the code |
| Palette | **Wallpaper-generated** (Material You style); user sharing an additional reference link |
| Bar position | **TOP** (old setup was a side bar — a main complaint) |
| Lock auth | **PIN / typed password ONLY** — no fingerprint, no face/IR scanners |
| Secure Boot | May be disabled **if needed** — but ALWAYS ask first |
| Settings | **Everything must be modifiable in an integrated settings GUI** |

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
- `>>> WANT: 🔒 **Themed GRUB screen** — was missing before. ⚠️ Secure Boot is ON; user OK to disable if needed but **ASK FIRST**. See §1.3.`

### 1.2 Boot splash
Hides kernel text during boot with a logo/animation.
- **Have now:** ❌ none (you see raw kernel messages)
- **Options:** Plymouth (standard; themes: spinner, bgrt, custom), or leave text-mode (some prefer it)
- **Note:** needs an mkinitcpio hook; adds ~1s boot time
- `>>> WANT:`

### 1.3 Secure Boot / signing
- **Have now:** ✅ Secure Boot **enabled**, sbctl managing keys, GRUB+kernel signed
- **Constraint:** anything touching the boot chain (Plymouth, new kernel, bootloader swap) must be re-signed or you won't boot
- `>>> WANT:` (usually KEEP)

### 1.4 Silent boot / kernel params
- **Have now:** `loglevel=3 quiet`
- **Options:** full silent (`quiet splash loglevel=0 rd.systemd.show_status=false`), or verbose for debugging
- `>>> WANT:`

---

# 2. Display Manager (Login Screen)

### 2.1 The DM itself
First graphical thing you see; handles login + session choice.
- **Have now:** ✅ SDDM (from `sddm-git`), enabled
- **Options:** SDDM (Qt, very themeable — sugar-candy, corners, sddm-astronaut) · GDM · LightDM · **greetd + tuigreet** (minimal TTY-style, fast) · ly (TUI, animated) · **no DM** (autologin → `uwsm start hyprland` from shell profile)
- **Rice angle:** this is a big visual moment — themed SDDM vs minimal tuigreet is a real aesthetic fork
- `>>> WANT:`

### 2.2 Session entries
- **Have now:** `hyprland.desktop`, `hyprland-uwsm.desktop`, and a **stale `caelestia.desktop`** (dead, package removed — will clean)
- **Note:** `uwsm` (universal wayland session manager) is NOT installed but a session entry references it. uwsm gives proper systemd user-session integration (better app scoping, cleaner shutdown). Worth considering.
- `>>> WANT:`

### 2.3 Autologin / passwordless
- **Have now:** ❌ password each boot
- **Note:** with full-disk-encryption absent, autologin is a real security tradeoff on a laptop
- `>>> WANT:`

---

# 3. Compositor (Hyprland)

### 3.1 Compositor choice
- **Have now:** ✅ Hyprland 0.56.2
- **Options:** Hyprland (animations, plugins, most riced) · Sway (stable, i3-like) · river (tag-based) · niri (scrollable tiling — very different feel)
- `>>> WANT:` (assume KEEP unless you say otherwise)

### 3.2 Animations & curves
- **Have now:** ✅ your `animations.conf` (preserved from before)
- **Rice angle:** bezier curves, per-type durations, workspace slide vs fade, window open/close style
- `>>> WANT:`

### 3.3 Decoration — blur, shadow, rounding, opacity
- **Have now:** ✅ `decoration.conf` + vars: rounding 20, border 3px, shadow on (range 20), **blur currently OFF** (`$blurEnabled = false`), opacity 1
- **Rice angle:** blur passes/size, xray blur, dim inactive, active/inactive border gradients (animated borders possible)
- `>>> WANT:`

### 3.4 Gaps & layout
- **Have now:** gaps in 10 / out 10 / single-window 15, **workspace gaps 150**
- **Options:** dwindle (default) · master · **hy3** (i3-like tabs/splits, plugin) · scroller plugin
- `>>> WANT:`

### 3.5 Hyprland plugins
- **Have now:** ❌ none
- **Options:** **hyprexpo** (workspace exposé grid) · **hyprspace** (overview w/ drag-drop) · hy3 (layout) · hyprbars (title bars) · hyprwinwrap (video wallpaper *behind* windows) · borders-plus-plus · hyprtrails
- **Note:** plugins must be rebuilt on every Hyprland update (`hyprpm update`) — a maintenance cost
- `>>> WANT:`

---

# 4. Bar / Panel / Status

### 4.1 The bar
- **Have now:** ✅ waybar 0.15 (minimal config I just wrote — top, 34px, plain text modules)
- **Options:** **waybar** (GTK, CSS, stable, huge module set) · **quickshell** (QML, what caelestia uses — most powerful, most work) · **AGS/Astal** (JS/TS + GTK, very flexible) · **eww** (Yuck/Lisp, widgets) · **HyprPanel** (AGS-based, batteries-included) · **fabric** (Python)
- **Tradeoff:** waybar = fast to configure, limited interactivity. quickshell/AGS = anything you can imagine, but it's real programming.
- `>>> WANT: 🔒 **quickshell** (QML). Claude writes the code. waybar stays installed as fallback until trusted.`

### 4.2 Bar modules — tick what you want
Workspaces (with window icons?) · window title · clock/date · calendar popup · system tray ·
audio (+ per-app mixer?) · mic · brightness · battery (+ time remaining) · network (wifi picker?) ·
bluetooth (device list?) · CPU · RAM · disk · temperature · **GPU (nvidia)** · media player (art/scrub) ·
weather · pending updates · notification bell + DND toggle · VPN · recording indicator ·
power profile switcher · idle-inhibitor toggle · custom scripts
- `>>> WANT:`

### 4.3 Bar behaviour
- Position (top/bottom/left) · auto-hide/reveal-on-hover · per-monitor · floating w/ margins · rounded · transparency · exclusive zone
- `>>> WANT: 🔒 **TOP bar** (explicit — the old side bar was a main complaint). Other behaviour ❓ open: auto-hide? floating w/ margins? rounded? transparency?`

---

# 5. Application Launcher

### 5.1 Launcher
- **Have now:** ✅ fuzzel (bound to tap-Super), `fuzzel.ini` exists from old setup
- **Options:** **fuzzel** (fast, native wayland, minimal) · **rofi** (wayland fork; most themeable, huge ecosystem) · wofi · **anyrun** (Rust, plugins) · **walker** (modern, many modules) · tofi (fastest) · custom (quickshell/AGS)
- **Rice angle:** centered vs top, icons, blur behind, animated, grid vs list, image previews
- `>>> WANT:`

### 5.2 Launcher modes wanted
apps (drun) · run command · window switcher · **clipboard history** · emoji picker · **calculator** ·
unit converter · file search · ssh hosts · power menu · web search · dictionary · color picker ·
kill process · wallpaper picker · project/repo jumper
- `>>> WANT:`

### 5.3 The "tap Super" behaviour
Old caelestia had tap-Super-to-launch **with interrupt** (typing/clicking cancels it, so Super+key combos still work). Currently approximated with `bindr` (fires on release) — slightly different feel.
- `>>> WANT:`

---

# 6. Notifications

### 6.1 Daemon
- **Have now:** ✅ mako 1.11 (config written: top-right, 8px radius, teal border, 5s timeout)
- **Options:** **mako** (light, INI config) · **dunst** (classic, very configurable) · **swaync** (notification *center* w/ history panel + DND toggle + widgets) · custom (quickshell/AGS)
- **Note:** if you want a notification **history panel**, that's swaync or a custom shell — mako has no UI
- `>>> WANT:`

### 6.2 Features
history/center · DND toggle · grouping · inline replies · action buttons · images/album art ·
per-app rules · urgency styling · sounds · on-screen position
- `>>> WANT:`

---

# 7. Lock Screen

### 7.1 Locker
- **Have now:** ✅ swaylock-effects (called by hypridle at 5min, and Super+M / Super+Alt+L)
- **Options:** **hyprlock** (Hyprland-native, most riceable — widgets, shaders, per-monitor) · **swaylock-effects** (blur/pixelate, no widgets) · gtklock (GTK modules) · custom (quickshell)
- **Rice angle:** blurred/dimmed wallpaper, big clock, date, user avatar, **media player controls**, weather, battery, failed-attempt feedback, fade-in animation
- `>>> WANT: 🔒 **Custom quickshell lock screen** (quickshell supports `WlSessionLock`). Was missing entirely before. Design ❓ open — see questions in §31.`

### 7.2 Auth methods
- **Have now:** password only
- **Options:** password · **fingerprint** (fprintd — does your Legion have a reader?) · **face unlock** (Howdy, uses IR/webcam) · YubiKey
- `>>> WANT: 🔒 **PIN / typed password ONLY.** No fingerprint reader, no face/IR unlock. Do not build biometric paths.`

---

# 8. Idle, Power & Thermal

### 8.1 Idle daemon
- **Have now:** ✅ hypridle — lock at 5min, screen off at 10min, **no auto-suspend** (deliberately, while nvidia resume is unproven)
- **Rice angle:** dim-before-lock, different timeouts on AC vs battery, inhibit while fullscreen/video
- `>>> WANT:`

### 8.2 Power management
- **Have now:** ✅ power-profiles-daemon (just restored)
- **Options:** power-profiles-daemon (simple 3 profiles) · TLP (deep control) · auto-cpufreq (adaptive)
- **Relevant:** ⚠️ nvidia suspend/resume services just enabled to fix your wake hang — **needs testing**
- `>>> WANT:`

### 8.3 Battery / thermal
- Low-battery notification + critical action · charge limit (Legion supports conservation mode via `lenovolegionlinux`) · fan curves · thermal throttle alerts
- **Note:** you had `lenovolegionlinux-git-debug` (removed as orphan); the main package may be worth having for fan/charge control
- `>>> WANT:`

### 8.4 GPU mode switching
- **Have now:** ⚪ envycontrol installed (hybrid/integrated/nvidia switching)
- **Note:** on a Max-Q laptop, integrated-only mode massively improves battery
- `>>> WANT:`

---

# 9. Wallpaper

### 9.1 Static wallpaper daemon
- **Have now:** ✅ awww (a swww fork — binaries are `awww`/`awww-daemon`), 30 wallpapers in `~/Pictures/Wallpapers`
- **Options:** swww/awww (animated transitions, per-output) · hyprpaper (light, Hyprland-native) · swaybg (bare)
- **Rice angle:** transition types (wipe/grow/outer), random cycling on timer, per-workspace wallpapers
- `>>> WANT:`

### 9.2 LIVE / animated wallpaper — pick which kind
This is several very different technologies:
- **Video loop:** `mpvpaper` (mpv as wallpaper — any video/GIF; pauses when covered)
- **Shader:** `glpaper` / `shaderbg` (GLSL shaders, Shadertoy-style)
- **Wallpaper Engine (Windows) scenes:** `linux-wallpaperengine` (runs actual WE workshop items — you'd need the Steam content)
- **Behind-windows video:** `hyprwinwrap` plugin (any app becomes the wallpaper layer)
- **Audio-reactive:** cava-driven visualiser as background (caelestia had this)
- ⚠️ **All of these cost GPU + battery continuously.** On a laptop this is a real tradeoff.
- `>>> WANT: 🔒 **YES — live wallpaper required** (was entirely missing). ❓ Which kind? See §31 Q3 — video loop vs shader vs Wallpaper Engine scenes are very different builds.`

### 9.3 Wallpaper picker UI
- **Have now:** ⚪ waypaper installed (GTK picker), plus Super+W = random
- **Options:** waypaper · rofi/fuzzel with image previews · custom shell module
- `>>> WANT:`

---

# 10. Colour Scheme & Theming Engine

### 10.1 Colour generation
The thing that makes a rice feel *cohesive* — one palette across bar, terminal, GTK, Qt, apps.
- **Have now:** ❌ nothing (caelestia did this via `python-materialyoucolor`, now removed). Your `~/.config/hypr/scheme/` still holds a static colour conf.
- **Options:** **matugen** (Material You from wallpaper — what caelestia used, Rust, template-based) · **wallust** (fast pywal successor, actively maintained) · pywal (classic, unmaintained-ish) · **fixed hand-picked palette** (Catppuccin/Gruvbox/Rose Pine/Tokyo Night/Nord — no generation, total control)
- **Big decision:** auto-generated-from-wallpaper (changes with every wallpaper, cohesive but unpredictable) vs fixed palette (consistent, predictable, you control every hex)
- `>>> WANT: 🔒 **Wallpaper-generated.** caelestia already did this (`python-materialyoucolor`). User is sharing **an additional reference link** that 'does a lot of stuff' — waiting on that before choosing matugen vs custom.`

### 10.2 What gets themed by it
hyprland borders · waybar · launcher · notifications · lock screen · **terminal** · **GTK apps** ·
**Qt apps** · btop · cava · fish/starship · **VSCode** · **Firefox** · **Discord** · **Spotify** · mako · thunar
- `>>> WANT:`

### 10.3 GTK theming
- **Have now:** ⚪ nwg-look + lxappearance installed; papirus-icon-theme
- **Needs:** GTK3 + GTK4/libadwaita theme, icon theme, cursor theme, font
- **Note:** GTK4/libadwaita resists theming; needs `gtk4/gtk.css` overrides
- `>>> WANT:`

### 10.4 Qt theming
- **Have now:** ⚪ qt6ct installed (qt5ct was removed as orphan — may need re-adding for Qt5 apps)
- **Options:** qt5ct/qt6ct (palette + style) · **Kvantum** (SVG-based, much prettier) · adwaita-qt
- `>>> WANT:`

### 10.5 Cursor & icons & fonts
- **Have now:** cursor `sweet-cursors` @24 (referenced in your vars — verify installed), Papirus icons, **JetBrainsMono Nerd Font** (Cascadia Nerd was removed in the caelestia cascade)
- **Rice angle:** icon theme (Papirus/Tela/Colloid/Reversal), cursor (Bibata/Sweet/Phinger), UI font vs mono font vs display font
- `>>> WANT:`

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
- `>>> WANT: 🔒 **YES — required.** 'Between-workspace app switcher.' ❓ Live thumbnails vs app icons — see §31 Q4.`

### 11.2 Alt-Tab / window switcher
- **Have now:** ✅ `Alt+Tab` cycles within group (`changegroupactive`) — not a global window switcher
- **Options:** hyprswitch (GUI switcher w/ previews) · rofi window mode · sway-style `focus next`
- `>>> WANT:`

### 11.3 Special workspaces / scratchpads
- **Have now:** ✅ `Super+S` toggles special ws; vars exist for music/comms/todo/sysmon scratchpads (bindings were caelestia's, now commented out)
- **Rice angle:** dropdown terminal (quake-style), floating music player, notes scratchpad
- `>>> WANT:`

### 11.4 Window rules
- **Have now:** ✅ `rules.conf` preserved (opacity, float, blur rules — caelestia layerrules commented out)
- `>>> WANT:`

### 11.5 Gestures (touchpad)
- **Have now:** ✅ Hyprland native: 4-finger workspace swipe, 3-finger gestures configured
- **Options:** native hyprland gestures · hyprgrass plugin (more gestures) · libinput-gestures
- `>>> WANT:`

---

# 12. Terminal & Shell

### 12.1 Terminal emulator
- **Have now:** ✅ kitty 0.48 (primary, `$terminal`), ✅ foot (panic-button terminal)
- **Options:** kitty (GPU, tabs/splits, images, ligatures) · foot (tiny, fast, native wayland) · alacritty (GPU, minimal) · wezterm (Lua config, multiplexer built in) · ghostty (new, fast)
- **Rice angle:** padding, opacity/blur, background image, font + ligatures, cursor trail, tab bar styling
- `>>> WANT:`

### 12.2 Shell + prompt
- **Have now:** ✅ fish 4.8 (login shell) + starship 1.26
- **Rice angle:** starship prompt design (powerline/minimal/two-line), git status, language versions, command duration, exit status styling
- `>>> WANT:`

### 12.3 Terminal extras
- **Have now:** ✅ tmux, ✅ fastfetch (has config), ✅ btop, ✅ fzf, ✅ krabby (pokemon fetch)
- **Options:** zellij (modern multiplexer) · eza/lsd (ls) · bat (cat) · zoxide (cd) · ripgrep · fd · yazi (file manager) · atuin (shell history) · cava (audio visualiser)
- `>>> WANT:`

---

# 13. File Management

### 13.1 GUI file manager
- **Have now:** ✅ thunar (+ archive plugin, tumbler thumbnails, ffmpegthumbnailer)
- **Options:** thunar (light, XFCE) · nautilus (GNOME, modern) · dolphin (KDE, feature-rich) · nemo · **cosmic-files**
- `>>> WANT:`

### 13.2 TUI file manager
- **Have now:** ❌ none
- **Options:** **yazi** (fast, image previews in kitty) · ranger · lf · nnn
- `>>> WANT:`

### 13.3 Disk / mounts
- NTFS `/media/Data` + `/media/Windows` auto-mounted via fstab · udiskie for USB automount · gvfs (installed)
- `>>> WANT:`

---

# 14. Clipboard, Screenshot, Recording

### 14.1 Clipboard
- **Have now:** ✅ cliphist + wl-clipboard (Super+C → cliphist via fuzzel)
- **Options:** cliphist (history, images) · clipse (TUI) · copyq (GUI, most features)
- **Rice angle:** image previews in history, pinned entries, per-type filtering
- `>>> WANT:`

### 14.2 Screenshot
- **Have now:** ✅ grim + slurp + swappy — `Print` full→clipboard, `Super+S` region→swappy, `Super+Shift+S` region→clipboard, `Super+Shift+Alt+S` region→file
- **Options:** grim/slurp (primitive, scriptable) · grimblast · hyprshot · **satty** (nicer annotation than swappy) · flameshot
- **Rice angle:** freeze-screen-while-selecting (caelestia had this — grim alone doesn't), annotation UI, auto-upload, OCR
- `>>> WANT:`

### 14.3 Screen recording
- **Have now:** ✅ wf-recorder (Super+Alt+R w/ audio, Ctrl+Alt+R, Super+Shift+Alt+R region)
- **Options:** wf-recorder (simple) · **gpu-screen-recorder** (NVENC, replay buffer — was removed in cascade, was installed before) · wl-screenrec (fast, VAAPI) · OBS (full production)
- **Rice angle:** instant-replay hotkey, recording indicator in bar, GIF output
- `>>> WANT:`

### 14.4 Colour picker / magnifier / OCR
- **Options:** hyprpicker (colour pick) · woomer/wl-zoom (magnify) · `grim+tesseract` (OCR screenshot to text)
- `>>> WANT:`

---

# 15. On-Screen Display (OSD)

Volume/brightness/caps-lock popups.
- **Have now:** ❌ **none** — brightness/volume keys work but show no feedback (caelestia provided the OSD)
- **Options:** **swayosd** (volume/brightness/caps, themeable) · avizo · custom (quickshell/AGS) · waybar tooltip only
- **Note:** this is the most-noticed missing piece right now — you press brightness and see nothing
- `>>> WANT:`

---

# 16. Audio & Media

### 16.1 Audio stack
- **Have now:** ✅ pipewire + wireplumber + pipewire-pulse/alsa/jack, pamixer, pavucontrol
- **Options add-on:** **easyeffects** (EQ, noise suppression, autogain) · noise-suppression-for-voice
- `>>> WANT:`

### 16.2 Music & players
- **Have now:** ✅ Spotify (spotify-launcher) + ⚪ spicetify-cli (theming), ✅ mpv, ✅ vlc, ✅ playerctl
- **Options:** spicetify themes (Comfy/Text/Dribbblish) · mpd + ncmpcpp/rmpc · YouTube Music (th-ch client) · feishin
- **Rice angle:** media widget in bar w/ album art + scrubber, lyrics display, **cava visualiser**, lock-screen media controls
- `>>> WANT:`

### 16.3 Audio visualiser
- **Have now:** ❌ (`libcava` was removed in the caelestia cascade)
- **Options:** cava (terminal/bar bars) · in-shell visualiser (caelestia had one) · glava (GL, desktop)
- `>>> WANT:`

---

# 17. Network, Bluetooth, VPN

- **Have now:** ✅ NetworkManager + nm-applet + nm-connection-editor, ✅ bluez + blueman, ⚪ cloudflared
- **Options:** GUI picker in bar (waybar network module w/ menu, or custom) · iwd (lighter wifi) · bluetuith (TUI)
- **Rice angle:** wifi picker popup from the bar rather than launching nm-connection-editor
- `>>> WANT:`

---

# 18. System Monitoring

- **Have now:** ✅ btop
- **Options:** btop (TUI, themeable) · **nvtop** (GPU — relevant, you have a 4060) · bottom · macchina/fastfetch · **conky**-style desktop widgets · mission-center (GUI)
- **Rice angle:** desktop widget overlay (CPU/GPU/RAM/temp), bar modules, dedicated scratchpad monitor workspace (`Ctrl+Shift+Esc` var already defined)
- `>>> WANT:`

---

# 19. Session, Power Menu, Logout

- **Have now:** ✅ wlogout (bound to `Ctrl+Alt+Del`)
- **Options:** wlogout (grid of buttons, themeable) · wleave (maintained fork) · rofi power menu · custom shell session screen
- **Rice angle:** blurred backdrop, icon grid, confirmation dialogs, hibernate/suspend/lock/logout/reboot/shutdown
- `>>> WANT:`

---

# 20. Portals, Polkit, Keyring, Session Services

Plumbing — invisible when right, very broken when wrong.
- **Have now:** ✅ xdg-desktop-portal-hyprland + -gtk (screenshare/file pickers), ✅ polkit-gnome agent, ✅ gnome-keyring (secrets — **your git/gh/VSCode creds depend on this**)
- **Options:** consider **uwsm** for proper systemd user-session scoping (app2unit already in use for app launching)
- `>>> WANT:`

---

# 21. Input

- **Have now:** ✅ Hyprland native input config (`input.conf`), touchpad disable-while-typing, libinput-tools
- **Options:** **keyd**/kanata (remap at kernel level — caps→esc/ctrl, home-row mods) · fcitx5 (IME, CJK input) · emoji picker · `hyprctl` per-device configs
- `>>> WANT:`

---

# 22. Per-App Theming

### 22.1 Browser
- **Have now:** ✅ Firefox 154
- **Options:** userChrome.css (hide tab bar, vertical tabs, match palette) · **Sidebery**/Tree Style Tab · Zen Browser (pre-riced Firefox fork) · **Note:** you have `~/.cache/zen` — Zen was installed at some point
- `>>> WANT:`

### 22.2 Editor
- **Have now:** ✅ VSCode 1.134 (settings symlinked from `~/temp_dots/vscode/`), ✅ neovim 0.12
- **Options:** VSCode theme matching palette · neovim distro (LazyVim/NvChad/AstroNvim/kickstart) · transparent background
- `>>> WANT:`

### 22.3 Discord
- **Have now:** ✅ vesktop (just installed) — Vencord built in
- **Options:** Vencord themes, custom CSS matching palette
- `>>> WANT:`

### 22.4 Spotify
- **Have now:** ✅ spotify-launcher + ⚪ spicetify-cli
- **Note:** spicetify needs re-applying after every Spotify update
- `>>> WANT:`

---

# 23. Fonts

- **Have now:** ✅ JetBrainsMono Nerd Font, Noto CJK, Noto emoji. (Cascadia Nerd, Rubik, Material Symbols were removed in the caelestia cascade — **Material Symbols matters if you want icon glyphs**)
- **Needs:** mono (terminal/code) · UI/sans (bar, menus) · display (clock, big text) · **icon font** (Material Symbols / Nerd Font glyphs) · CJK · emoji
- `>>> WANT:`

---

# 24. Desktop Widgets & Extras

- **Options:** desktop clock overlay · calendar · todo/notes widget · weather · system stats · music/album art · sticky notes · dock (⚪ `nwg-dock-hyprland` installed) · conky
- **Note:** caelestia had a dashboard (media/performance/weather) and desktop clock
- `>>> WANT:`

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
- `>>> WANT:`

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
- `>>> WANT:` ❓ Which sites? Default rating filter? Launcher-mode, bar-widget, or standalone window?

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

- `>>> WANT:` ❓ **A, B, or C?** And which widgets in the combo?

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
- `>>> WANT:` ❓ Single window or popout? Everything in v1, or the frequently-changed subset?

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
