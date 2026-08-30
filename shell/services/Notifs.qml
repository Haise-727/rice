pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

// Owns org.freedesktop.Notifications. This REPLACES mako - both cannot hold the
// DBus name, so mako must be stopped or the server silently fails to register.
//
// `tracked` is the persistent list shown in the sidebar; `popups` is the subset
// currently on screen as toasts.
Singleton {
    id: root

    readonly property alias list: server.trackedNotifications
    property var popups: []
    property bool dnd: false

    function dismiss(n) { if (n) n.dismiss(); }
    function dismissAll() {
        const all = [...server.trackedNotifications.values];
        for (const n of all) n.dismiss();
        popups = [];
    }
    function expirePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;                  // keep it in the list until dismissed
            if (root.dnd) return;              // still recorded, just not shown
            root.popups = [...root.popups, n];
            // Critical expires too, just slower - a toast that never leaves is
            // worse than one you might miss. Set criticalNeverExpires to keep it.
            const crit = n.urgency === NotificationUrgency.Critical;
            if (!(crit && Config.options.notifications.criticalNeverExpires)) {
                expiry.createObject(root, { notif: n, crit: crit });
            }
        }
    }

    property Component expiry: Component {
        Timer {
            property var notif: null
            property bool crit: false
            interval: {
                if (notif && notif.expireTimeout > 0) return notif.expireTimeout;
                return crit ? Config.options.notifications.criticalTimeoutMs
                            : Config.options.notifications.timeoutMs;
            }
            running: true
            onTriggered: { root.expirePopup(notif); destroy(); }
        }
    }
}
