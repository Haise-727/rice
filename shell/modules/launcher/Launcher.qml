pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.config
import qs.zones
import qs.services

// Bottom-centre launcher.
//   plain text          -> fuzzy app search
//   leading '>' or '/'  -> command mode (wallpaper, settings, clipboard, power...)
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("bottomCentre") && ZoneManager.zonesVisible
            visible: shown || panel.opacity > 0.01

            WlrLayershell.namespace: "ashura:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"

            property string query: ""
            readonly property bool cmdMode: query.startsWith(">") || query.startsWith("/")
            readonly property string term: cmdMode ? query.slice(1).trim().toLowerCase()
                                                   : query.trim().toLowerCase()
            property int sel: 0

            // ---- commands ----
            readonly property var commands: [
                { name: "Wallpaper — random",   hint: "new wallpaper + palette", act: () => Quickshell.execDetached([`${Quickshell.env("HOME")}/.config/ashura/bin/set-theme`, "--random"]) },
                { name: "Wallpaper — pick",     hint: "choose a file",           act: () => Quickshell.execDetached(["waypaper"]) },
                { name: "Clipboard history",    hint: "cliphist",                act: () => Quickshell.execDetached(["sh","-c","cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"]) },
                { name: "Overview",             hint: "workspaces",              act: () => Quickshell.execDetached(["qs","ipc","-c","overview","call","overview","toggle"]) },
                { name: "Sidebar",              hint: "controls + notifications", act: () => deferOpen.restart() },
                { name: "Screenshot — region",  hint: "grim + swappy",           act: () => Quickshell.execDetached(["sh","-c","grim -g \"$(slurp)\" - | swappy -f -"]) },
                { name: "Screenshot — screen",  hint: "to clipboard",            act: () => Quickshell.execDetached(["sh","-c","grim - | wl-copy"]) },
                { name: "Colour picker",        hint: "hyprpicker",              act: () => Quickshell.execDetached(["hyprpicker","-a"]) },
                { name: "Audio settings",       hint: "pavucontrol",             act: () => Quickshell.execDetached(["pavucontrol"]) },
                { name: "Network",              hint: "nm-connection-editor",    act: () => Quickshell.execDetached(["nm-connection-editor"]) },
                { name: "Bluetooth",            hint: "blueman-manager",         act: () => Quickshell.execDetached(["blueman-manager"]) },
                { name: "Power menu",           hint: "wlogout",                 act: () => Quickshell.execDetached(["wlogout"]) },
                { name: "Reload shell",         hint: "restart ashura",          act: () => Quickshell.execDetached(["sh","-c","pkill -x qs; sleep 1; qs -p ~/rice/shell/shell.qml & qs -c overview &"]) }
            ]

            // ---- results ----
            readonly property var results: {
                if (cmdMode) {
                    const t = term;
                    return commands.filter(c => t === "" || c.name.toLowerCase().includes(t)
                                                        || c.hint.toLowerCase().includes(t))
                                   .slice(0, 9);
                }
                const t = term;
                if (t === "") return [];
                const apps = DesktopEntries.applications?.values ?? [];
                const scored = [];
                for (const a of apps) {
                    if (a.noDisplay) continue;
                    const n = (a.name ?? "").toLowerCase();
                    const g = (a.genericName ?? "").toLowerCase();
                    const k = (a.keywords ?? []).join(" ").toLowerCase();
                    let s = -1;
                    if (n.startsWith(t)) s = 0;
                    else if (n.includes(t)) s = 1;
                    else if (g.includes(t) || k.includes(t)) s = 2;
                    if (s >= 0) scored.push({ e: a, s: s });
                }
                scored.sort((x, y) => x.s - y.s || (x.e.name ?? "").localeCompare(y.e.name ?? ""));
                return scored.slice(0, 9).map(x => ({ name: x.e.name, hint: x.e.genericName ?? x.e.comment ?? "",
                                                      icon: x.e.icon, entry: x.e }));
            }
            onResultsChanged: sel = 0

            function run(i) {
                const r = results[i];
                if (!r) return;
                ZoneManager.close("bottomCentre");
                query = "";
                if (r.act) r.act();
                else if (r.entry) r.entry.execute();
            }

            onShownChanged: if (shown) { query = ""; sel = 0; input.forceActiveFocus(); }

            // Opening another zone from inside run() races with closing the
            // launcher, so defer it by a frame.
            Timer {
                id: deferOpen
                interval: 60
                onTriggered: ZoneManager.open("rightCentre")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ZoneManager.close("bottomCentre")
            }

            Rectangle {
                id: panel
                width: 620
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: win.shown ? 90 : 40
                height: content.implicitHeight + 24
                radius: 18
                color: Colours.surfaceContainer
                border.width: 1
                border.color: win.cmdMode ? Colours.tertiary : Colours.outline
                opacity: win.shown ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on anchors.bottomMargin { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: 160 } }

                Column {
                    id: content
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                    spacing: 8

                    // input row
                    Row {
                        width: parent.width
                        spacing: 8
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: win.cmdMode ? Icons.cog : ""
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                            color: win.cmdMode ? Colours.tertiary : Colours.primary
                        }
                        TextField {
                            id: input
                            width: parent.width - 40
                            anchors.verticalCenter: parent.verticalCenter
                            background: null
                            color: Colours.on.surface
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                            placeholderText: win.cmdMode ? "command…" : "search apps…  (> or / for commands)"
                            placeholderTextColor: Colours.on.surfaceVariant
                            text: win.query
                            onTextChanged: win.query = text
                            Keys.onDownPressed: win.sel = Math.min(win.sel + 1, win.results.length - 1)
                            Keys.onUpPressed: win.sel = Math.max(win.sel - 1, 0)
                            Keys.onReturnPressed: win.run(win.sel)
                            Keys.onEnterPressed: win.run(win.sel)
                            Keys.onEscapePressed: ZoneManager.close("bottomCentre")
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 1
                        color: Colours.outline; opacity: 0.4
                        visible: win.results.length > 0
                    }

                    Repeater {
                        model: win.results
                        delegate: Rectangle {
                            required property int index
                            required property var modelData
                            width: content.width
                            height: 40
                            radius: 10
                            color: index === win.sel ? Colours.primaryContainer : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Row {
                                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10;
                                          verticalCenter: parent.verticalCenter }
                                spacing: 10
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 130
                                    text: modelData.name ?? ""
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                                    color: index === win.sel ? Colours.on.primaryContainer : Colours.on.surface
                                    elide: Text.ElideRight
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.hint ?? ""
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                    color: Colours.on.surfaceVariant
                                    elide: Text.ElideRight
                                    width: content.width - 180
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: win.sel = index
                                onClicked: win.run(index)
                            }
                        }
                    }

                    Text {
                        visible: win.results.length === 0 && win.term !== ""
                        text: "no matches"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: Colours.on.surfaceVariant; opacity: 0.6
                    }
                }
            }
        }
    }
}
