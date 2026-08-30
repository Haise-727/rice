pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.common
import qs.config
import qs.services
import qs.zones

// Lock screen.
//
// DESIGN CHOICE: this is a normal overlay with an exclusive keyboard grab, NOT
// ext-session-lock-v1. That protocol keeps the session locked when the locker
// dies, which is exactly how this user got stranded twice and had to hard-power-off.
// An overlay FAILS OPEN: if the shell crashes, the lock simply disappears.
//
// For a laptop whose threat model is "someone walks past", failing open is the
// right trade. Set lock.useSessionLock true for the stricter behaviour once it
// has been trusted for a while.
Scope {
    id: root

    property bool locked: false
    property string entry: ""
    property string message: ""
    property bool failed: false
    property int attempts: 0

    function lock() { entry = ""; message = ""; failed = false; locked = true; ZoneManager.dashboardMode = true; }
    function unlock() { locked = false; entry = ""; message = ""; failed = false; attempts = 0; ZoneManager.dashboardMode = false; }

    PamContext {
        id: pam
        config: "ashura-lock"
        user: Quickshell.env("USER")
        // responseRequired is a PROPERTY, so this is a change handler, not a signal
        onResponseRequiredChanged: if (responseRequired) respond(root.entry)
        onCompleted: res => {
            if (res === PamResult.Success) root.unlock();
            else {
                root.attempts++;
                root.failed = true;
                root.message = "incorrect";
                root.entry = "";
                clearFail.restart();
            }
        }
        onError: e => { root.message = "auth error: " + e; root.failed = true; }
    }
    Timer { id: clearFail; interval: 1400; onTriggered: root.failed = false }

    function submit() {
        if (entry === "") return;
        message = "checking…";
        pam.active = false;
        pam.active = true;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: root.locked
            WlrLayershell.namespace: "ashura:lock"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.locked ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                // opaque: a lock you can read the screen through is not a lock
                color: Colours.background

                // clock
                Column {
                    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: parent.height * 0.18 }
                    spacing: -12
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(lc.date, "HH:mm")
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 150; font.bold: true
                        color: Colours.primary
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(lc.date, "dddd, dd MMMM")
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                        color: Colours.on.surfaceVariant
                    }
                }
                SystemClock { id: lc; precision: SystemClock.Seconds }

                // entry
                Column {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 110
                    spacing: 14

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 340; height: 46; radius: 23
                        color: Colours.surfaceContainer
                        border.width: 2
                        border.color: root.failed ? Colours.error : Colours.outline
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        TextField {
                            id: pw
                            anchors { fill: parent; leftMargin: 18; rightMargin: 18 }
                            background: null
                            echoMode: TextInput.Password
                            color: Colours.on.surface
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                            horizontalAlignment: TextInput.AlignHCenter
                            placeholderText: "password"
                            placeholderTextColor: Colours.on.surfaceVariant
                            text: root.entry
                            onTextChanged: root.entry = text
                            onAccepted: root.submit()
                            focus: root.locked
                            Connections {
                                target: root
                                function onLockedChanged() { if (root.locked) pw.forceActiveFocus(); }
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.message
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        color: root.failed ? Colours.error : Colours.on.surfaceVariant
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.attempts >= 2
                        text: "stuck?  Ctrl+Alt+F2 for a TTY, then:  ashura-unlock"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                        color: Colours.on.surfaceVariant; opacity: 0.55
                    }
                }

                // battery + media, bottom
                Text {
                    anchors { bottom: parent.bottom; left: parent.left; margins: 40 }
                    text: "BAT " + (Config.ready ? "" : "") +
                          (Notifs.list.values.length > 0 ? Notifs.list.values.length + " notifications" : "")
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    color: Colours.on.surfaceVariant; opacity: 0.7
                }
            }
        }
    }
}
