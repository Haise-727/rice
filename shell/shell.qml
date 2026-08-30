//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import qs.config
import qs.zones
import qs.modules.bar
import qs.modules.desktop

ShellRoot {
    id: root
    Component.onCompleted: console.log("ashura: starting")

    LazyLoader { active: Config.ready; component: Bar {} }
    LazyLoader { active: Config.ready; component: DesktopClock {} }
}
