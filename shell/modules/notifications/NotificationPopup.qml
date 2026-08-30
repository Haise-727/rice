pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.common
import qs.config
import qs.services

// Toast popups, top-right under the bar. Replaces mako.
Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property ShellScreen modelData
            screen: modelData

            visible: Notifs.popups.length > 0
            WlrLayershell.namespace: "ashura:notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; right: true }
            margins.top: (Config.options.bar.enabled ? Config.options.bar.height : 0) + 10
            margins.right: 10
            implicitWidth: Config.options.notifications.width
            implicitHeight: Math.max(1, col.implicitHeight)
            color: "transparent"

            Column {
                id: col
                width: parent.width
                spacing: 8

                Repeater {
                    model: Notifs.popups
                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        width: col.width
                        height: body.implicitHeight + 24
                        radius: 14
                        color: Colours.surfaceContainer
                        border.width: modelData.urgency === NotificationUrgency.Critical ? 2 : 1
                        border.color: modelData.urgency === NotificationUrgency.Critical
                            ? Colours.error : Colours.outline

                        // slide + fade in
                        opacity: 0
                        x: 30
                        Component.onCompleted: { opacity = 1; x = 0; }
                        Behavior on opacity { NumberAnimation { duration: 220 } }
                        Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

                        Column {
                            id: body
                            anchors { left: parent.left; right: parent.right; margins: 12; verticalCenter: parent.verticalCenter }
                            spacing: 3

                            Row {
                                width: parent.width
                                spacing: 6
                                Text {
                                    text: card.modelData.appName ?? ""
                                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                    color: card.modelData.urgency === NotificationUrgency.Critical
                                        ? Colours.error : Colours.primary
                                    elide: Text.ElideRight
                                    width: Math.min(implicitWidth, parent.width - 16)
                                }
                            }
                            Text {
                                width: parent.width
                                text: card.modelData.summary ?? ""
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.bold: true
                                color: Colours.on.surface
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                visible: (card.modelData.body ?? "") !== ""
                                text: card.modelData.body ?? ""
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                                color: Colours.on.surfaceVariant
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) Notifs.dismiss(card.modelData);
                                else Notifs.expirePopup(card.modelData);   // hide toast, keep in list
                            }
                        }
                    }
                }
            }
        }
    }
}
