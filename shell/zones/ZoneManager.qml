pragma Singleton
import QtQuick
import Quickshell
import qs.config

// Owns which screen-edge zones are open.
//
// Rule (user, 2026-08-27): zones on DIFFERENT edges may be open at once
// (top + bottom is fine); zones sharing an edge are mutually exclusive
// (top-left and top-right are not). Set zones.perEdgeExclusive=false for
// fully independent zones.
//
// dashboardMode: while the startup workspace is focused every zone hides,
// giving it the full screen. One extra mode on the same machine.
Singleton {
    id: root

    // zone id -> which screen edge it belongs to
    readonly property var edgeOf: ({
        "topLeft":      "top",
        "topCentre":    "top",
        "topRight":     "top",
        "leftCentre":   "left",
        "rightCentre":  "right",
        "bottomCentre": "bottom",
        "bottomRight":  "bottom",
        "session":      "right",
        "overview":     "fullscreen"
    })

    // 0..1 while an edge drag is in progress, for surfaces that preview the pull
    property real dragProgress: 0

    property var openZones: ({})          // zone id -> true
    property bool dashboardMode: false    // startup workspace focused

    signal zoneOpened(string zone)
    signal zoneClosed(string zone)

    function isEnabled(zone) {
        // "session" is reached by dragging the right edge; it has no config entry
        // of its own and rides on rightCentre being enabled.
        if (zone === "session") return Config.options.zones.rightCentre.enabled === true;
        if (zone === "overview") return true;
        const z = Config.options.zones[zone];
        return z !== undefined && z.enabled === true;
    }

    function isOpen(zone) {
        return openZones[zone] === true;
    }

    function edge(zone) {
        return edgeOf[zone] !== undefined ? edgeOf[zone] : "";
    }

    // Zones are hidden entirely while the dashboard workspace is focused.
    readonly property bool zonesVisible: !dashboardMode

    function open(zone) {
        if (!isEnabled(zone) || dashboardMode) return;

        let next = JSON.parse(JSON.stringify(openZones));

        if (Config.options.zones.perEdgeExclusive) {
            const e = edge(zone);
            for (const other in next) {
                if (next[other] && other !== zone && edge(other) === e) {
                    delete next[other];
                    zoneClosed(other);
                }
            }
        }

        if (!next[zone]) {
            next[zone] = true;
            openZones = next;
            zoneOpened(zone);
        } else {
            openZones = next;
        }
    }

    function close(zone) {
        if (!openZones[zone]) return;
        let next = JSON.parse(JSON.stringify(openZones));
        delete next[zone];
        openZones = next;
        zoneClosed(zone);
    }

    function toggle(zone) {
        isOpen(zone) ? close(zone) : open(zone);
    }

    function closeAll() {
        for (const z in openZones) zoneClosed(z);
        openZones = ({});
    }

    onDashboardModeChanged: if (dashboardMode) closeAll()
}
