pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland

// hyprland/workspaces -> one small numbered pill per workspace on this
// monitor, filled solid when active, tinted on hover. Same surface/accent
// colors and chip radius as the rest of the bar, just sized down.
Row {
    id: root

    required property HyprlandMonitor monitor
    spacing: Theme.spacing

    Repeater {
        model: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor)

        Rectangle {
            id: dot
            required property HyprlandWorkspace modelData

            width: modelData.active ? 24 : 20
            height: 20
            radius: Theme.chipRadius
            anchors.verticalCenter: parent.verticalCenter
            color: modelData.active ? Theme.accent
                 : (hover.containsMouse ? Theme.surfaceHover : Theme.surface)

            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: dot.modelData.id
                color: dot.modelData.active ? Theme.bg
                     : (hover.containsMouse ? Theme.text : Theme.textDim)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: dot.modelData.active
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -2 // slightly bigger hit target than the visible pill
                hoverEnabled: true
                onClicked: dot.modelData.activate()
            }
        }
    }
}
