//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.config
import qs.zones
import qs.modules.bar

ShellRoot {
    id: root
    Component.onCompleted: console.log("ashura: starting")

    LazyLoader {
        active: Config.ready
        component: Bar {}
    }
}
