//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import qs.config
import qs.zones
import qs.modules.bar
import qs.modules.desktop
import qs.modules.sidebar
import qs.modules.notifications
import qs.modules.dashboard
import qs.modules.launcher
import qs.modules.booru
import qs.modules.startup
import Quickshell.Io

ShellRoot {
    id: root
    Component.onCompleted: console.log("ashura: starting")

    LazyLoader { active: Config.ready; component: Bar {} }
    LazyLoader { active: Config.ready; component: DesktopClock {} }
    LazyLoader { active: Config.ready; component: EdgeTrigger { zone: "rightCentre"; side: "right" } }
    LazyLoader { active: Config.ready; component: EdgeTrigger { zone: "leftCentre";  side: "left"  } }
    LazyLoader { active: Config.ready; component: Sidebar {} }
    LazyLoader { active: Config.ready; component: NotificationPopup {} }
    LazyLoader { active: Config.ready; component: Dashboard {} }
    LazyLoader { active: Config.ready; component: Launcher {} }
    LazyLoader { active: Config.ready; component: BooruPanel {} }
    LazyLoader { active: Config.ready; component: StartupWorkspace {} }

    // External control, for keybinds and for testing surfaces that are otherwise
    // only reachable by a mouse gesture:
    //   qs ipc call zone toggle rightCentre
    IpcHandler {
        target: "zone"
        function toggle(name: string): string { ZoneManager.toggle(name); return ZoneManager.isOpen(name) ? "open" : "closed"; }
        function open(name: string): string   { ZoneManager.open(name);   return ZoneManager.isOpen(name) ? "open" : "closed"; }
        function close(name: string): string  { ZoneManager.close(name);  return "closed"; }
        function state(): string              { return JSON.stringify(ZoneManager.openZones); }
    }
}
