import QtQuick
import Quickshell
import Quickshell.Hyprland

// hyprland/mode -> only appears while a non-default keybind submap
// (resize mode, etc.) is active. Hyprland's IPC emits a `submap>>NAME`
// event; NAME is empty when the submap resets to default.
Chip {
    id: root
    visible: name.length > 0
    active: true

    property string name: ""

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap") {
                root.name = event.data === "reset" ? "" : event.data;
            }
        }
    }

    Text {
        text: root.name
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }
}
