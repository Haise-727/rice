//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.config
import qs.zones

ShellRoot {
    id: root

    Component.onCompleted: console.log("ashura: starting")

    // Surfaces load only once config is ready and the zone is enabled,
    // so every zone is switchable from settings by construction.
    component ZoneLoader: LazyLoader {
        required property string zone
        active: Config.ready && ZoneManager.isEnabled(zone) && ZoneManager.zonesVisible
    }
}
