import QtQuick
import Quickshell

// custom/power -> opens wlogout, same as the original. Turns red on hover,
// matching style.css's `#custom-power:hover { color: red; }`.
Chip {
    id: root
    hoverable: false // don't tint the whole pill on hover, just the icon below

    onClicked: Quickshell.execDetached(["wlogout", "-b", "2"])

    Text {
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize + 1
        color: root.hovered ? Theme.bad : Theme.text
        text: "\uf011" // power-off
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
