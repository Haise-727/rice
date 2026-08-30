pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.zones

// The top bar. Per spec it is ALWAYS visible at full opacity - no auto-hide,
// no transparency - so it reserves an exclusive zone and never animates away,
// except on the startup workspace where dashboardMode hides every zone.
Scope {
    id: bar

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: Config.options.bar.enabled && ZoneManager.zonesVisible
            WlrLayershell.namespace: "ashura:bar"
            WlrLayershell.layer: WlrLayer.Top

            anchors { top: true; left: true; right: true }
            implicitHeight: Config.options.bar.height
            exclusiveZone: Config.options.bar.height
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Colours.surface
                opacity: Config.options.bar.opacity

                // ---- top-left zone ----
                Row {
                    id: leftZone
                    anchors {
                        left: parent.left; leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    ResourceButton {
                        anchors.verticalCenter: parent.verticalCenter
                        onActivated: ZoneManager.toggle("topLeft")
                    }
                    Workspaces {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ---- top-centre / top-right land next ----
                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "ddd dd MMM  HH:mm")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    color: Colours.primary
                }
                SystemClock { id: clock; precision: SystemClock.Minutes }
            }
        }
    }
}
