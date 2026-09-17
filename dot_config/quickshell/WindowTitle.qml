import QtQuick
import Quickshell.Hyprland

// hyprland/window -> focused window's class + title, centered. Styled with
// a bit more hierarchy than a single plain label (bold accent app name,
// small separator dot, dimmed italic title) and a quick fade whenever the
// focused window changes, instead of just snapping to new text.
Item {
    id: root
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    readonly property HyprlandToplevel active: Hyprland.activeToplevel
    // lastIpcObject mirrors `hyprctl clients -j`, which is where the class
    // name lives; it refreshes whenever the toplevel is re-fetched (e.g. on
    // focus change), which is often enough for a bar label.
    readonly property string windowClass: active && active.lastIpcObject ? (active.lastIpcObject.class || "") : ""
    readonly property string windowTitle: active ? active.title : ""

    // Bumping this string re-triggers the fade below whenever the focused
    // window (or just its title) changes.
    readonly property string key: windowClass + "\u0000" + windowTitle

    onKeyChanged: fade.restart()

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6
        opacity: 0

        Text {
            visible: root.windowClass.length > 0
            text: root.windowClass
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        Rectangle {
            visible: root.windowClass.length > 0 && root.windowTitle.length > 0
            width: 3
            height: 3
            radius: 1.5
            color: Theme.textDim
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.windowTitle
            color: Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.italic: true
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 420)
        }
    }

    // Restarting a SequentialAnimation replays it from the start even if
    // it's already mid-flight, which is exactly what's wanted when the
    // window changes again before the previous fade finished.
    SequentialAnimation {
        id: fade
        PropertyAction { target: content; property: "opacity"; value: 0 }
        PauseAnimation { duration: 10 }
        NumberAnimation { target: content; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
        running: true
    }
}
