pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland

// hyprland/workspaces -> one small pill per workspace on this monitor,
// filled solid when active, outlined on hover.
Row {
    id: root

    required property HyprlandMonitor monitor
    spacing: Theme.spacing

    Repeater {
        model: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)

        Rectangle {
            id: dot
            required property HyprlandWorkspace modelData

            width: modelData.active ? 22 : 10
            height: 10
            radius: 5
            anchors.verticalCenter: parent.verticalCenter
            color: modelData.active ? Theme.accent
                 : (hover.containsMouse ? Theme.textDim : Qt.rgba(Theme.textDim.r, Theme.textDim.g, Theme.textDim.b, 0.4))

            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 120 } }

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -4 // slightly bigger hit target than the visible dot
                hoverEnabled: true
                onClicked: dot.modelData.activate()
            }
        }
    }
}
