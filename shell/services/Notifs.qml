pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

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
            // urgency 2 (critical) never auto-expires
            if (n.urgency !== NotificationUrgency.Critical) {
                expiry.createObject(root, { notif: n });
            }
        }
    }

    property Component expiry: Component {
        Timer {
            property var notif: null
            interval: notif && notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            running: true
            onTriggered: { root.expirePopup(notif); destroy(); }
        }
    }
}
