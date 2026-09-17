import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// wireplumber -> default sink volume/mute.
// Left click: open qpwgraph (same as the original on-click).
// Right click: toggle mute. Scroll: +/- 5% volume. Both are small additions
// over the waybar version since the surface was already there for free.
Chip {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.ready ? sink.audio.muted : true
    readonly property real volume: sink && sink.ready ? sink.audio.volume : 0

    // Required for sink.audio to actually stay bound/up to date.
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    onClicked: Quickshell.execDetached(["qpwgraph"])
    onRightClicked: if (root.sink && root.sink.ready) root.sink.audio.muted = !root.sink.audio.muted
    onWheelUp: if (root.sink && root.sink.ready) root.sink.audio.volume = Math.min(1.0, root.sink.audio.volume + 0.05)
    onWheelDown: if (root.sink && root.sink.ready) root.sink.audio.volume = Math.max(0.0, root.sink.audio.volume - 0.05)

    Text {
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        color: root.muted ? Theme.bad : Theme.text
        // volume-off / volume-down / volume-up
        text: root.muted ? "\uf026" : (root.volume < 0.5 ? "\uf027" : "\uf028")
    }

    Text {
        text: Math.round(root.volume * 100) + "%"
        color: root.muted ? Theme.bad : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
