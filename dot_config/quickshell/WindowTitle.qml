import QtQuick
import Quickshell.Hyprland

// hyprland/window -> "{class} || {title}" of the focused window, centered.
Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    readonly property HyprlandToplevel active: Hyprland.activeToplevel
    // lastIpcObject mirrors `hyprctl clients -j`, which is where the class
    // name lives; it refreshes whenever the toplevel is re-fetched (e.g. on
    // focus change), which is often enough for a bar label.
    readonly property string windowClass: active && active.lastIpcObject ? (active.lastIpcObject.class || "") : ""

    Text {
        id: label
        anchors.centerIn: parent
        color: Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        text: {
            if (!root.active) return "";
            return root.windowClass ? (root.windowClass + "  ||  " + root.active.title) : root.active.title;
        }
    }
}
