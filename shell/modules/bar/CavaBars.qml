import QtQuick
import qs.common
import qs.services
import qs.config

// Compact spectrum, sits right of the clock. Only asks cava to run while visible.
Row {
    id: root
    visible: Config.options.cava.enabled
    spacing: 2
    height: 16

    Component.onCompleted: if (visible) Cava.acquire()
    Component.onDestruction: if (visible) Cava.release()
    onVisibleChanged: visible ? Cava.acquire() : Cava.release()

    Repeater {
        model: Config.options.cava.bars
        delegate: Rectangle {
            required property int index
            width: 2
            radius: 1
            anchors.verticalCenter: parent.verticalCenter
            // cava reports 0..100; keep a 2px floor so the row never vanishes
            height: Math.max(2, (Cava.values[index] ?? 0) / 100 * root.height)
            color: Colours.primary
            opacity: 0.85
            Behavior on height { NumberAnimation { duration: 60 } }
        }
    }
}
