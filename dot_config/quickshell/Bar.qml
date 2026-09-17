pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: bar

    required property ShellScreen modelData
    screen: modelData

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: Theme.gap
        left: Theme.gap
        right: Theme.gap
    }
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.bg

        Item {
            anchors.fill: parent
            anchors.leftMargin: Theme.sectionSpacing
            anchors.rightMargin: Theme.sectionSpacing

            // modules-left
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.sectionSpacing

                Workspaces { monitor: bar.monitor; anchors.verticalCenter: parent.verticalCenter }
                Submap { anchors.verticalCenter: parent.verticalCenter }
            }

            // modules-center
            WindowTitle {
                anchors.centerIn: parent
            }

            // modules-right
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing

                Volume {}
                Battery {}
                ClockWidget {}
                // Notifications {} // disabled to match the commented-out custom/notification in config.jsonc
                PowerButton {}
            }
        }
    }
}
