pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.Notifications
import Quickshell.Networking
import qs.common
import qs.services
import qs.config
import qs.zones

// Right-edge sidebar. Slides in when ZoneManager opens "rightCentre".
//
// Notifications are NOT here yet: taking the org.freedesktop.Notifications DBus
// name means replacing mako, which also means building the popup, or the user
// loses notifications entirely. That lands as its own change.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("rightCentre") && ZoneManager.zonesVisible
            visible: shown || panel.x < panel.width

            WlrLayershell.namespace: "ashura:sidebar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; bottom: true; right: true }
            margins.top: Config.options.bar.enabled ? Config.options.bar.height : 0
            implicitWidth: Config.options.zones.rightCentre.width
            color: "transparent"

            HyprlandFocusGrab {
                active: win.shown
                windows: [win]
                onCleared: ZoneManager.close("rightCentre")
            }


            Rectangle {
                id: panel
                width: parent.width
                height: parent.height
                color: Colours.surfaceContainer
                topLeftRadius: 18
                bottomLeftRadius: 18
                x: win.shown ? 0 : width
                Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

                Column {
                    anchors { fill: parent; margins: 20 }
                    spacing: 18

                    // ---------- header ----------
                    Row {
                        width: parent.width
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Uptime " + Uptime.pretty
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Item { width: parent.width - 210; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Icons.power
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
                            color: Colours.error
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["wlogout"])
                            }
                        }
                    }

                    // ---------- quick toggles ----------
                    Row {
                        spacing: 10
                        Repeater {
                            model: [
                                { glyph: Icons.wifi, on: (Networking.wifiEnabled ?? false), act: "wifi" },
                                { glyph: Icons.bluetooth, on: (Bluetooth.defaultAdapter?.enabled ?? false), act: "bt" },
                                { glyph: Audio.muted ? Icons.volMute : Icons.volHigh, on: !Audio.muted, act: "mute" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                width: 54; height: 40; radius: 20
                                color: modelData.on ? Colours.primary : Colours.surfaceContainerHigh
                                Behavior on color { ColorAnimation { duration: 160 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.glyph
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                                    color: modelData.on ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.act === "wifi")
                                            Quickshell.execDetached(["nmcli", "radio", "wifi",
                                                Networking.wifiEnabled ? "off" : "on"]);
                                        else if (modelData.act === "bt")
                                            Quickshell.execDetached(["bluetoothctl", "power",
                                                (Bluetooth.defaultAdapter?.enabled ?? false) ? "off" : "on"]);
                                        else Audio.toggleMute();
                                    }
                                }
                            }
                        }
                    }

                    // ---------- power profile ----------
                    Column {
                        width: parent.width
                        spacing: 6
                        Text {
                            text: "Power" + (Power.degraded !== "" ? "  (degraded)" : "")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Row {
                            width: parent.width
                            spacing: 6
                            Repeater {
                                model: Power.profiles
                                delegate: Rectangle {
                                    required property string modelData
                                    readonly property bool cur: Power.active === modelData
                                    width: (parent.width - 12) / 3
                                    height: 30
                                    radius: 15
                                    color: cur ? Colours.primary : Colours.surfaceContainerHigh
                                    Behavior on color { ColorAnimation { duration: 140 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: Power.labels[parent.modelData] ?? parent.modelData
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                        color: parent.cur ? Colours.on.primary : Colours.on.surfaceVariant
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Power.set(modelData)
                                    }
                                }
                            }
                        }
                    }

                    // ---------- volume ----------
                    Column {
                        width: parent.width; spacing: 6
                        Text {
                            text: "Volume  " + (!Audio.ready ? "--" : Audio.muted ? "muted" : Audio.percent + "%")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Audio.muted ? Colours.error : Colours.on.surfaceVariant
                        }
                        Rectangle {
                            id: volTrack
                            width: parent.width; height: 8; radius: 4
                            color: Colours.surfaceContainerHigh
                            Rectangle {
                                // Audio.effective is 0 while muted, so muting visibly
                                // collapses the slider instead of leaving a stale fill.
                                width: parent.width * Math.min(1, Audio.effective / Audio.maxVolume)
                                height: parent.height; radius: 4
                                color: Audio.muted ? Colours.error : Colours.primary
                                Behavior on width { NumberAnimation { duration: 140 } }
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -8
                                onPressed: mouse => setVol(mouse.x)
                                onPositionChanged: mouse => { if (pressed) setVol(mouse.x); }
                                function setVol(px) { Audio.setVolume(px / volTrack.width * Audio.maxVolume); }
                            }
                        }
                    }

                    // ---------- brightness ----------
                    Column {
                        width: parent.width; spacing: 6
                        Text {
                            text: "Brightness  " + (Brightness.percent >= 0 ? Brightness.percent + "%" : "--")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant
                        }
                        Rectangle {
                            id: briTrack
                            width: parent.width; height: 8; radius: 4
                            color: Colours.surfaceContainerHigh
                            Rectangle {
                                width: parent.width * Math.max(0, Brightness.percent) / 100
                                height: parent.height; radius: 4
                                color: Colours.tertiary
                            }
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -8
                                onPressed: mouse => setBri(mouse.x)
                                onPositionChanged: mouse => { if (pressed) setBri(mouse.x); }
                                function setBri(px) { Brightness.setPercent(px / briTrack.width * 100); }
                            }
                        }
                    }

                    // ---------- per-app volume mixer ----------
                    Column {
                        width: parent.width
                        spacing: 8
                        visible: Audio.streams.length > 0

                        Text {
                            text: "Volume mixer"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                            color: Colours.on.surface
                        }
                        Repeater {
                            model: Audio.streams
                            delegate: Column {
                                required property var modelData
                                width: parent.width
                                spacing: 4
                                Text {
                                    width: parent.width
                                    text: Audio.appName(modelData) + "  " + Math.round((modelData.audio?.volume ?? 0) * 100) + "%"
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    color: (modelData.audio?.muted ?? false) ? Colours.error : Colours.on.surfaceVariant
                                    elide: Text.ElideRight
                                }
                                Rectangle {
                                    id: appTrack
                                    width: parent.width; height: 6; radius: 3
                                    color: Colours.surfaceContainerHigh
                                    Rectangle {
                                        width: parent.width * ((modelData.audio?.muted ?? false)
                                               ? 0 : (modelData.audio?.volume ?? 0))
                                        height: parent.height; radius: 3
                                        color: (modelData.audio?.muted ?? false) ? Colours.error : Colours.secondary
                                        Behavior on width { NumberAnimation { duration: 120 } }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; anchors.margins: -6
                                        onPressed: mouse => set(mouse.x)
                                        onPositionChanged: mouse => { if (pressed) set(mouse.x); }
                                        function set(px) {
                                            const a = modelData.audio;
                                            if (!a) return;
                                            a.volume = Math.max(0, Math.min(1, px / appTrack.width));
                                            if (a.muted && a.volume > 0) a.muted = false;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ---------- notifications ----------
                    Row {
                        width: parent.width
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Notifications"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                            color: Colours.on.surface
                        }
                        Item { width: parent.width - 240; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Notifs.dnd ? "DND on" : "DND off"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                            color: Notifs.dnd ? Colours.error : Colours.on.surfaceVariant
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifs.dnd = !Notifs.dnd
                            }
                        }
                        Item { width: 12; height: 1 }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Clear"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                            color: Colours.primary
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifs.dismissAll()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 200
                        color: "transparent"

                        ListView {
                            id: nList
                            anchors.fill: parent
                            clip: true
                            spacing: 8
                            model: Notifs.list
                            delegate: Rectangle {
                                required property var modelData
                                width: nList.width
                                height: nCol.implicitHeight + 18
                                radius: 12
                                color: Colours.surfaceContainerHigh
                                // urgency tag: a coloured spine, matching the popup border
                                Rectangle {
                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                    width: 3
                                    topLeftRadius: 12; bottomLeftRadius: 12
                                    visible: modelData.urgency !== NotificationUrgency.Normal
                                    color: modelData.urgency === NotificationUrgency.Critical
                                        ? Colours.error : Colours.outline
                                }
                                Column {
                                    id: nCol
                                    anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 2
                                    Text {
                                        width: parent.width
                                        text: (modelData.urgency === NotificationUrgency.Critical ? "! " : "")
                                            + (modelData.appName ?? "")
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                        color: modelData.urgency === NotificationUrgency.Critical
                                            ? Colours.error : Colours.primary
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.summary ?? ""
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.bold: true
                                        color: Colours.on.surface; elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        visible: (modelData.body ?? "") !== ""
                                        text: modelData.body ?? ""
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                        color: Colours.on.surfaceVariant
                                        wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
                                        textFormat: Text.PlainText
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Notifs.dismiss(modelData)
                                }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: nList.count === 0
                            text: "No notifications"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Colours.on.surfaceVariant; opacity: 0.5
                        }
                    }
                }
            }


        }
    }
}
