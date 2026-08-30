pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.config
import qs.zones

// A screen-edge strip that opens its zone. Reusable for any side.
//
// Three ways in, because this machine's touchpad cannot drag:
//   click/tap   -> toggle the zone
//   hover dwell -> open after dwellMs (0 disables; off by default)
//   drag inward -> two-stage where the zone defines stage1/stage2
Scope {
    id: root
    required property string zone
    required property string side          // "left" | "right"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            readonly property var cfg: Config.options.zones[root.zone]
            visible: ZoneManager.isEnabled(root.zone) && ZoneManager.zonesVisible

            WlrLayershell.namespace: `ashura:edge-${root.side}`
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore

            anchors { left: root.side === "left"; right: root.side === "right" }
            implicitWidth: cfg?.edgeWidth ?? 8
            implicitHeight: Math.round(modelData.height * (cfg?.edgeSpan ?? 0.42))
            color: "transparent"

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
                    // inward = leftwards from the right edge, rightwards from the left
                    travel = Math.max(0, root.side === "right" ? startX - mouse.x : mouse.x - startX);
                    if (travel > 6) didDrag = true;
                    ZoneManager.dragProgress = Math.min(1, travel / (win.cfg?.stage2 ?? 190));
                }
                onReleased: {
                    dragging = false;
                    if (didDrag) {
                        if (travel >= (win.cfg?.stage2 ?? 190)) ZoneManager.open(root.zone);
                        else if (win.cfg?.stage1 !== undefined && travel >= win.cfg.stage1
                                 && root.side === "right") Quickshell.execDetached(["wlogout"]);
                    } else {
                        ZoneManager.toggle(root.zone);
                    }
                    ZoneManager.dragProgress = 0;
                    travel = 0; didDrag = false;
                }
                onCanceled: { dragging = false; ZoneManager.dragProgress = 0; travel = 0; didDrag = false; }

                Timer {
                    interval: win.cfg?.dwellMs ?? 0
                    running: area.containsMouse && !area.dragging
                        && (win.cfg?.dwellMs ?? 0) > 0 && !ZoneManager.isOpen(root.zone)
                    onTriggered: ZoneManager.open(root.zone)
                }

                Rectangle {
                    anchors.right: root.side === "right" ? parent.right : undefined
                    anchors.left: root.side === "left" ? parent.left : undefined
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
