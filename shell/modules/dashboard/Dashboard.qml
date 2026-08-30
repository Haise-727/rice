pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.services
import qs.zones

// Top-centre dropdown, opened by hovering the bar clock.
// Tabs inside the dropdown, per spec: Performance and Calendar for now.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property bool shown: ZoneManager.isOpen("topCentre") && ZoneManager.zonesVisible
            visible: shown || card.y > -card.height

            WlrLayershell.namespace: "ashura:dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; left: true; right: true }
            margins.top: Config.options.bar.enabled ? Config.options.bar.height : 0
            implicitHeight: 330
            color: "transparent"
            mask: Region { item: card }

            property int tab: 0

            Rectangle {
                id: card
                width: 520
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                y: win.shown ? 8 : -height
                radius: 18
                color: Colours.surfaceContainer
                border.width: 1
                border.color: Colours.outline
                Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

                // stay open while the pointer is inside; close when it leaves
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onExited: closeTimer.restart()
                    onEntered: closeTimer.stop()
                }
                Timer {
                    id: closeTimer
                    interval: 350
                    onTriggered: ZoneManager.close("topCentre")
                }

                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 12

                    // ---- tabs ----
                    Row {
                        spacing: 8
                        Repeater {
                            model: ["Performance", "Calendar"]
                            delegate: Rectangle {
                                required property int index
                                required property string modelData
                                width: label.implicitWidth + 22
                                height: 26
                                radius: 13
                                color: win.tab === index ? Colours.primary : Colours.surfaceContainerHigh
                                Behavior on color { ColorAnimation { duration: 140 } }
                                Text {
                                    id: label
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                    color: win.tab === index ? Colours.on.primary : Colours.on.surfaceVariant
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: win.tab = index
                                }
                            }
                        }
                    }

                    // ---- performance ----
                    Column {
                        visible: win.tab === 0
                        width: parent.width
                        spacing: 10

                        Component.onCompleted: SysStats.acquire()
                        Component.onDestruction: SysStats.release()

                        Repeater {
                            model: [
                                { k: "CPU",  v: Math.round(SysStats.cpuPct) + "%",
                                  sub: SysStats.cpuTemp >= 0 ? SysStats.cpuTemp + "°C" : "",
                                  f: SysStats.cpuPct / 100, c: Colours.primary },
                                { k: "RAM",  v: Math.round(SysStats.memPct) + "%",
                                  sub: SysStats.memUsed + " / " + SysStats.memTotal,
                                  f: SysStats.memPct / 100, c: Colours.secondary },
                                { k: "GPU",  v: SysStats.gpuPct >= 0 ? SysStats.gpuPct + "%" : "--",
                                  sub: (SysStats.gpuTemp >= 0 ? SysStats.gpuTemp + "°C  " : "") + SysStats.gpuMem,
                                  f: Math.max(0, SysStats.gpuPct) / 100, c: Colours.tertiary }
                            ]
                            delegate: Column {
                                required property var modelData
                                width: parent.width
                                spacing: 4
                                Row {
                                    width: parent.width
                                    Text {
                                        text: modelData.k + "  " + modelData.v
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                                        color: Colours.on.surface
                                    }
                                    Item { width: parent.width - 260; height: 1 }
                                    Text {
                                        text: modelData.sub
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                        color: Colours.on.surfaceVariant
                                    }
                                }
                                Rectangle {
                                    width: parent.width; height: 7; radius: 4
                                    color: Colours.surfaceContainerHigh
                                    Rectangle {
                                        width: parent.width * Math.max(0, Math.min(1, modelData.f))
                                        height: parent.height; radius: 4
                                        color: modelData.c
                                        Behavior on width { NumberAnimation { duration: 400 } }
                                    }
                                }
                            }
                        }
                    }

                    // ---- calendar ----
                    Column {
                        visible: win.tab === 1
                        width: parent.width
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(cal.date, "MMMM yyyy")
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true
                            color: Colours.primary
                        }
                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 7
                            spacing: 4
                            Repeater {
                                model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                                delegate: Text {
                                    required property string modelData
                                    width: 32; horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.bold: true
                                    color: Colours.on.surfaceVariant
                                }
                            }
                            Repeater {
                                model: {
                                    const d = cal.date;
                                    const y = d.getFullYear(), m = d.getMonth();
                                    const first = new Date(y, m, 1);
                                    // JS weeks start Sunday; shift so Monday is column 0
                                    const lead = (first.getDay() + 6) % 7;
                                    const days = new Date(y, m + 1, 0).getDate();
                                    const cells = [];
                                    for (let i = 0; i < lead; i++) cells.push(0);
                                    for (let i = 1; i <= days; i++) cells.push(i);
                                    return cells;
                                }
                                delegate: Rectangle {
                                    required property int modelData
                                    width: 32; height: 26; radius: 8
                                    readonly property bool today: modelData === cal.date.getDate()
                                    color: today ? Colours.primary : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.modelData > 0 ? parent.modelData : ""
                                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                        color: parent.today ? Colours.on.primary : Colours.on.surface
                                        opacity: parent.today ? 1 : 0.85
                                    }
                                }
                            }
                        }
                    }
                }
                SystemClock { id: cal; precision: SystemClock.Minutes }
            }
        }
    }
}
