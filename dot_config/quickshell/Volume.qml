import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// wireplumber -> default sink volume/mute.
// Left click: toggle mute. Scroll: +/- 5% volume.
// (qpwgraph launching was removed -- this no longer shells out to anything.)
Chip {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.ready ? sink.audio.muted : true
    readonly property real volume: sink && sink.ready ? sink.audio.volume : 0

    // Required for sink.audio to actually stay bound/up to date.
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    onClicked: if (root.sink && root.sink.ready) root.sink.audio.muted = !root.sink.audio.muted
    onWheelUp: if (root.sink && root.sink.ready) root.sink.audio.volume = Math.min(1.0, root.sink.audio.volume + 0.05)
    onWheelDown: if (root.sink && root.sink.ready) root.sink.audio.volume = Math.max(0.0, root.sink.audio.volume - 0.05)

    Text {
        anchors.verticalCenter: parent.verticalCenter
        // Font Awesome draws this particular glyph noticeably higher in its
        // em-box than the battery/power glyphs do (icon fonts are designed
        // for baseline alignment, not vertical centering, so this varies
        // per-icon even within the same font). Nudge it down to compensate;
        // tweak this number to taste if it's not quite right for your
        // rendering, and check volume-down/-up (\uf027/\uf028) too since
        // they may need a slightly different value.
        anchors.verticalCenterOffset: 1
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        font.weight: Theme.iconWeight
        color: root.muted ? Theme.bad : Theme.text
        // volume-off / volume-down / volume-up
        text: root.muted ? "\uf026" : (root.volume < 0.5 ? "\uf027" : "\uf028")
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.volume * 100) + "%"
        color: root.muted ? Theme.bad : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
