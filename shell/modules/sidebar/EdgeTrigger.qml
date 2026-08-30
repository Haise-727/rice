import qs.common
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.zones

// A thin invisible strip down the right edge that turns a mouse drag into the
// sidebar. Two stages, per spec:
//   short drag  -> session/logout options
//   full  drag  -> the whole sidebar
// Release below the first threshold cancels.
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

            anchors { top: true; bottom: true; right: true }
            implicitWidth: Config.options.zones.rightCentre.edgeWidth
            color: "transparent"

            readonly property int stage1: Config.options.zones.rightCentre.stage1
            readonly property int stage2: Config.options.zones.rightCentre.stage2

            MouseArea {
                id: drag
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.SizeHorCursor

                property real startX: 0
                property real travel: 0
                property bool dragging: false

                onPressed: mouse => { startX = mouse.x; travel = 0; dragging = true; }
                onPositionChanged: mouse => {
                    if (!dragging) return;
                    // dragging leftwards from the right edge = positive travel
                    travel = Math.max(0, startX - mouse.x);
                    ZoneManager.dragProgress = Math.min(1, travel / win.stage2);
                }
                onReleased: {
                    dragging = false;
                    if (travel >= win.stage2)      ZoneManager.open("rightCentre");
                    else if (travel >= win.stage1) ZoneManager.open("session");
                    ZoneManager.dragProgress = 0;
                    travel = 0;
                }
                onCanceled: { dragging = false; ZoneManager.dragProgress = 0; travel = 0; }

                // hovering the edge hints the sidebar exists
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: drag.containsMouse || drag.dragging ? 90 : 46
                    radius: 2
                    color: Colours.primary
                    opacity: drag.containsMouse || drag.dragging ? 0.85 : 0.28
                    Behavior on height  { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                }
            }
        }
    }
}
