pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Always-on system-audio visualizer (via cava) that lives in the bar's
// left cluster. It reflects whatever's actually coming out of your
// speakers/headphones -- it isn't tied to a specific MPRIS player, so it
// keeps moving for anything (browser audio, games, etc), not just an
// open media player.
//
// Click it to drop down a small MPRIS control panel: track icon/art,
// title/artist, and previous/play-pause/next.
//
// REQUIRES `cava` installed and on PATH (e.g. `pacman -S cava`,
// `apt install cava`). If it's missing the bars just sit flat at their
// resting height -- nothing breaks, you just won't see movement.
//
// NOTE on the dropdown: rather than use Quickshell's popup-window APIs
// (which vary between versions and I can't test against your exact
// build), the dropdown below is implemented as a second small
// PanelWindow, positioned under this widget via mapToGlobal. That's the
// same PanelWindow type your Bar already uses successfully, so it's the
// lowest-risk way to get a working dropdown. The one trade-off: it closes
// when you click the visualizer again, not when you click elsewhere on
// the screen. Say the word if you'd rather have real click-outside
// dismissal and I'll look at wiring up HyprlandFocusGrab for it.
Item {
    id: root

    // Passed in from Bar.qml so this can put its dropdown on the right
    // screen without guessing at any window/screen lookup API.
    required property ShellScreen screen

    readonly property int barCount: 9
    readonly property int maxRange: 7
    property var levels: new Array(barCount).fill(0)

    implicitWidth: visualizerRow.implicitWidth + Theme.paddingH * 2
    implicitHeight: Theme.barHeight - Theme.paddingV * 2

    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: {
        for (const p of root.players) {
            if (p.playbackState === MprisPlaybackState.Playing) return p;
        }
        return root.players.length > 0 ? root.players[0] : null;
    }
    readonly property bool playing: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing

    property bool menuOpen: false

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.chipRadius
        color: (hoverArea.containsMouse || root.menuOpen) ? Theme.surfaceHover : Theme.surface
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Row {
        id: visualizerRow
        anchors.centerIn: parent
        spacing: 2
        height: root.implicitHeight

        Repeater {
            model: root.barCount

            Rectangle {
                id: bar
                required property int index
                anchors.bottom: parent.bottom
                width: 3
                radius: 1.5
                color: root.playing ? Theme.accent : Theme.textDim
                height: Math.max(2, root.levels[bar.index] * (root.implicitHeight - 2))
                Behavior on height { NumberAnimation { duration: 60 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.menuOpen = !root.menuOpen
    }

    // Writes a small cava config once on startup, then runs cava reading
    // raw ascii bar values off stdout, one frame (semicolon-separated
    // ints) per line.
    Process {
        id: cava
        running: true
        command: ["bash", "-c",
            "mkdir -p \"$HOME/.config/quickshell\" && cat > \"$HOME/.config/quickshell/.cava_bar.conf\" << 'CAVAEOF'\n" +
            "[general]\n" +
            "bars = " + root.barCount + "\n" +
            "framerate = 30\n\n" +
            "[output]\n" +
            "method = raw\n" +
            "raw_target = /dev/stdout\n" +
            "data_format = ascii\n" +
            "ascii_max_range = " + root.maxRange + "\n\n" +
            "[smoothing]\n" +
            "noise_reduction = 55\n" +
            "CAVAEOF\n" +
            "exec cava -p \"$HOME/.config/quickshell/.cava_bar.conf\""
        ]
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.split(";").filter(s => s.length > 0).map(Number);
                if (parts.length === root.barCount) {
                    root.levels = parts.map(v => Math.max(0, Math.min(1, v / root.maxRange)));
                }
            }
        }
    }

    // --- dropdown ---
    PanelWindow {
        id: menu
        screen: root.screen
        visible: root.menuOpen
        color: "transparent"
        exclusiveZone: 0

        readonly property point anchorPos: root.mapToGlobal(0, root.height)

        anchors { top: true; left: true }
        margins {
            top: menu.anchorPos.y + Theme.spacing
            left: menu.anchorPos.x
        }
        implicitWidth: 230
        implicitHeight: menuContent.implicitHeight + Theme.paddingV * 4

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.bg
            border.color: Theme.divider
            border.width: 1
        }

        Column {
            id: menuContent
            anchors.centerIn: parent
            width: parent.width - Theme.paddingH * 3
            spacing: 12

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: 40
                    height: 40
                    radius: Theme.chipRadius
                    color: Theme.surface
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: art
                        anchors.fill: parent
                        anchors.margins: 2
                        source: (root.player && root.player.trackArtUrl) ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: art.status !== Image.Ready
                        font.family: Theme.iconFont
                        font.weight: Theme.iconWeight
                        font.pixelSize: Theme.iconSize + 4
                        color: Theme.textDim
                        text: "\uf001" // music note
                    }
                }

                Column {
                    width: parent.width - 50
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: root.player ? (root.player.trackTitle || "Unknown title") : "Nothing playing"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        visible: root.player && root.player.trackArtist && root.player.trackArtist.length > 0
                        text: root.player ? root.player.trackArtist : ""
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 22

                // previous
                Text {
                    readonly property bool enabled_: root.player !== null && root.player.canGoPrevious
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize + 2
                    color: enabled_ ? Theme.text : Theme.textDim
                    opacity: enabled_ ? 1 : 0.4
                    text: "\uf048" // step-backward
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: parent.enabled_
                        onClicked: root.player.previous()
                    }
                }

                // play / pause
                Text {
                    readonly property bool enabled_: root.player !== null
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize + 4
                    color: enabled_ ? Theme.accent : Theme.textDim
                    opacity: enabled_ ? 1 : 0.4
                    text: root.playing ? "\uf04c" : "\uf04b" // pause / play
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: parent.enabled_
                        onClicked: root.player.togglePlaying()
                    }
                }

                // next
                Text {
                    readonly property bool enabled_: root.player !== null && root.player.canGoNext
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize + 2
                    color: enabled_ ? Theme.text : Theme.textDim
                    opacity: enabled_ ? 1 : 0.4
                    text: "\uf051" // step-forward
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: parent.enabled_
                        onClicked: root.player.next()
                    }
                }
            }
        }
    }
}
