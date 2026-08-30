pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.zones

// Right-MIDDLE edge trigger (not the full edge - the spec assigns the corners
// and other edges to other zones).
//
// Three ways in, because this user's touchpad cannot drag:
//   click       -> open the sidebar
//   hover dwell -> open after `dwellMs` of resting on the strip
//   drag        -> two-stage, short = session, full = sidebar
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: ZoneManager.isEnabled("rightCentre") && ZoneManager.zonesVisible
            WlrLayershell.namespace: "ashura:edge-right"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore

            // vertically centred strip covering only the middle band
            anchors { right: true }
            implicitWidth: Config.options.zones.rightCentre.edgeWidth
            implicitHeight: Math.round(modelData.height * Config.options.zones.rightCentre.edgeSpan)
            color: "transparent"

            readonly property int stage1: Config.options.zones.rightCentre.stage1
            readonly property int stage2: Config.options.zones.rightCentre.stage2

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor

                property real startX: 0
                property real travel: 0
                property bool dragging: false
                property bool didDrag: false

                onPressed: mouse => { startX = mouse.x; travel = 0; dragging = true; didDrag = false; }
                onPositionChanged: mouse => {
                    if (!dragging) return;
                    travel = Math.max(0, startX - mouse.x);
                    if (travel > 6) didDrag = true;
                    ZoneManager.dragProgress = Math.min(1, travel / win.stage2);
                }
                onReleased: {
                    dragging = false;
                    if (didDrag) {
                        if (travel >= win.stage2)      ZoneManager.open("rightCentre");
                        else if (travel >= win.stage1) Quickshell.execDetached(["wlogout"]);
                    } else {
                        // plain click/tap - the touchpad-friendly path
                        ZoneManager.toggle("rightCentre");
                    }
                    ZoneManager.dragProgress = 0;
                    travel = 0; didDrag = false;
                }
                onCanceled: { dragging = false; ZoneManager.dragProgress = 0; travel = 0; didDrag = false; }

                // hover dwell: rest on the strip and it opens itself
                Timer {
                    id: dwell
                    interval: Config.options.zones.rightCentre.dwellMs
                    running: area.containsMouse && !area.dragging
                        && Config.options.zones.rightCentre.dwellMs > 0
                        && !ZoneManager.isOpen("rightCentre")
                    onTriggered: ZoneManager.open("rightCentre")
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: area.containsMouse || area.dragging ? parent.height * 0.75 : parent.height * 0.34
                    radius: 2
                    color: Colours.primary
                    opacity: area.containsMouse || area.dragging ? 0.9 : 0.3
                    Behavior on height  { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                }
            }
        }
    }
}
