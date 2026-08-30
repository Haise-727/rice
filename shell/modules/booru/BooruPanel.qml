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

// Left side panel: booru image search.
// Layout follows the reference: grid of thumbnails, tag input pinned to the
// bottom carrying the site selector and the blacklist toggle.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("leftCentre") && ZoneManager.zonesVisible
            visible: shown || panel.x > -panel.width

            WlrLayershell.namespace: "ashura:booru"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true }
            margins.top: Config.options.bar.enabled ? Config.options.bar.height : 0
            implicitWidth: Config.options.zones.leftCentre.width
            color: "transparent"

            HyprlandFocusGrab {
                active: win.shown
                windows: [win]
                onCleared: ZoneManager.close("leftCentre")
            }

            Rectangle {
                id: panel
                width: parent.width
                height: parent.height
                color: Colours.surfaceContainer
                topRightRadius: 18
                bottomRightRadius: 18
                x: win.shown ? 0 : -width
                Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                Column {
                    anchors { fill: parent; margins: 12 }
                    spacing: 10

                    Text {
                        text: "Booru"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true
                        color: Colours.on.surface
                    }

                    // ---- results grid ----
                    Rectangle {
                        width: parent.width
                        height: parent.height - 150
                        color: "transparent"

                        GridView {
                            id: gridView
                            anchors.fill: parent
                            clip: true
                            cellWidth: Math.floor(width / 2)
                            cellHeight: cellWidth
                            model: Booru.posts
                            delegate: Item {
                                required property var modelData
                                width: gridView.cellWidth - 6
                                height: gridView.cellHeight - 6
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: Colours.surfaceContainerHigh
                                    clip: true
                                    Image {
                                        anchors.fill: parent
                                        source: modelData.preview
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                    }
                                    Rectangle {
                                        anchors.fill: parent
                                        color: ma.containsMouse ? Qt.rgba(0,0,0,0.45) : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            visible: ma.containsMouse
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "set wallpaper"
                                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                                color: "#ffffff"
                                            }
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "right-click: save only"
                                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 8
                                                color: "#ccffffff"
                                            }
                                        }
                                    }
                                    MouseArea {
                                        id: ma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mouse => Booru.download(modelData, mouse.button === Qt.LeftButton)
                                    }
                                }
                            }
                            onAtYEndChanged: if (atYEnd && count > 0 && !Booru.loading) Booru.more()
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: Booru.posts.length === 0
                            width: parent.width - 20
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: Booru.loading ? "searching…"
                                 : Booru.error !== "" ? Booru.error
                                 : "enter tags below"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            color: Booru.error !== "" ? Colours.error : Colours.on.surfaceVariant
                            opacity: 0.7
                        }
                    }

                    // ---- tag input ----
                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: 10
                        color: Colours.surfaceContainerHigh
                        TextField {
                            id: tagInput
                            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                            background: null
                            color: Colours.on.surface
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                            placeholderText: "tags, space separated…"
                            placeholderTextColor: Colours.on.surfaceVariant
                            onAccepted: { Booru.query = text; Booru.search(true); }
                        }
                    }

                    // ---- site selector + blacklist toggle ----
                    Row {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: Config.options.booru.sites
                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool cur: Booru.site === modelData
                                readonly property bool locked: Booru.needsCreds.includes(modelData)
                                    && Booru.credsFor(modelData) === ""
                                width: t.implicitWidth + 14
                                height: 22
                                radius: 11
                                color: cur ? Colours.primary : Colours.surfaceContainerHigh
                                opacity: locked ? 0.45 : 1
                                Text {
                                    id: t
                                    anchors.centerIn: parent
                                    text: parent.modelData + (parent.locked ? " *" : "")
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                    color: parent.cur ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { Booru.site = modelData; if (Booru.query !== "") Booru.search(true); }
                                }
                            }
                        }
                        Item { width: 4; height: 1 }
                        Rectangle {
                            width: bl.implicitWidth + 14; height: 22; radius: 11
                            color: Config.options.booru.blacklistEnabled ? Colours.tertiary : Colours.surfaceContainerHigh
                            Text {
                                id: bl
                                anchors.centerIn: parent
                                text: Config.options.booru.blacklistEnabled ? "filter on" : "filter off"
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9
                                color: Config.options.booru.blacklistEnabled ? Colours.on.primary : Colours.on.surfaceVariant
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Config.options.booru.blacklistEnabled = !Config.options.booru.blacklistEnabled;
                                    if (Booru.query !== "") Booru.search(true);
                                }
                            }
                        }
                    }
                    Text {
                        visible: Booru.needsCreds.includes(Booru.site) && Booru.credsFor(Booru.site) === ""
                        width: parent.width
                        text: "* needs an API key in ~/.config/ashura/config.json"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 8
                        color: Colours.on.surfaceVariant; opacity: 0.6
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
