pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.zones

// Top bar: always visible at full opacity (no auto-hide, no transparency),
// hidden only by dashboardMode on the startup workspace.
//
// Three zones, matching the spec's edge-zone model:
//   top-left   resource button + workspaces
//   top-centre clock + cava + media
//   top-right  battery + wifi
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
            color: Colours.surface

            // ---- top-left ----
            Row {
                anchors {
                    left: parent.left; leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                spacing: 10
                ResourceButton {
                    anchors.verticalCenter: parent.verticalCenter
                    onActivated: ZoneManager.toggle("topLeft")
                }
                Workspaces { anchors.verticalCenter: parent.verticalCenter }
            }

            // ---- top-centre ----
            Row {
                anchors.centerIn: parent
                spacing: 12
                ClockWidget {
                    anchors.verticalCenter: parent.verticalCenter
                    onDesktopClockToggled: console.log("ashura: desktop clock toggle (widget lands with the background zone)")
                }
                CavaBars   { anchors.verticalCenter: parent.verticalCenter }
                MediaWidget { anchors.verticalCenter: parent.verticalCenter }
            }

            // ---- top-right ----
            StatusIndicators {
                anchors {
                    right: parent.right; rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
