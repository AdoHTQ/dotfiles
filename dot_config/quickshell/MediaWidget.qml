pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Always-on system-audio visualizer (via cava) that lives in the bar's
// left cluster. It reflects whatever's actually coming out of your
// speakers/headphones -- it isn't tied to a specific MPRIS player, so it
// keeps moving for anything (browser audio, games, etc), not just an
// open media player. When there's genuinely no signal it settles into a
// slow idle wave instead of sitting dead flat.
//
// Click it to drop down a Spotify-style now-playing panel that slides
// down from directly under the bar (see the PanelWindow below).
//
// REQUIRES `cava` installed and on PATH (e.g. `pacman -S cava`). The
// cava config below explicitly sets `[input] method = pulse` + `source =
// auto`: without an explicit input method, cava's autodetection has been
// known to grab a silent capture device (e.g. an idle mic) instead of
// the monitor of your default output on some pipewire-pulse setups --
// which reads exactly like "MPRIS says playing, bars don't move", since
// the color is driven by MPRIS state but the bar heights are driven by
// whatever cava actually captured. If bars still never react to real
// audio after this, run `cava -p ~/.config/quickshell/.cava_bar.conf` in
// a terminal directly to see its own error output -- this file also logs
// cava's stderr and exit code to Quickshell's own console for the same
// reason.
//
// NOTE on the dropdown: implemented as a second small PanelWindow, sized
// to its final content height and positioned flush against the bottom
// edge of the bar itself (not the widget) -- computed the same way
// Bar.qml positions the bar, and screen-relative rather than using raw
// global coordinates, so it lines up correctly on a secondary monitor
// too. It closes when you click the visualizer again, not on
// click-outside.
Item {
    id: root

    // Passed in from Bar.qml so this can put its dropdown on the right
    // screen without guessing at any window/screen lookup API.
    required property ShellScreen screen

    readonly property int barCount: 24
    readonly property int maxRange: 6
    property var levels: new Array(barCount).fill(0)

    // Set true if cava fails to launch or exits abnormally -- see the
    // Process below. Surfaced as a small red dot rather than only a
    // console warning, since console output is easy to miss.
    property bool cavaFailed: false

    // Slow looping phase driving the idle wave, always running.
    property real idleT: 0
    NumberAnimation on idleT {
        from: 0
        to: Math.PI * 2
        duration: 2600
        loops: Animation.Infinite
        running: true
    }

    readonly property bool idle: levels.every(l => l < 0.04)

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

    // menuOpen flips immediately on click; menuVisible stays true a bit
    // longer on close so the fade/scale-out animation gets to finish
    // before the PanelWindow is actually torn down.
    property bool menuOpen: false
    property bool menuVisible: false

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) seconds = 0;
        const total = Math.floor(seconds);
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.chipRadius
        color: (hoverArea.containsMouse || root.menuOpen) ? Theme.surfaceHover : Theme.surface
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Failure indicator -- only visible if cava never started/crashed.
    Rectangle {
        visible: root.cavaFailed
        width: 5
        height: 5
        radius: 2.5
        color: Theme.bad
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 2
    }

    Row {
        id: visualizerRow
        anchors.centerIn: parent
        spacing: 1
        height: root.implicitHeight

        Repeater {
            model: root.barCount

            Rectangle {
                id: bar
                required property int index
                anchors.bottom: parent.bottom
                width: 2
                radius: 1
                // Bright and uniform, matching the reference look, rather
                // than dimming when nothing's marked "playing" over MPRIS
                // -- this widget reflects real system audio, which can be
                // present (a browser tab, a game) with no MPRIS player at
                // all.
                color: root.idle ? Theme.textDim : Theme.text
                height: root.idle
                    ? (5 + Math.sin(root.idleT + bar.index * 0.5) * 2.5)
                    : Math.max(2, root.levels[bar.index] * (root.implicitHeight - 2))
                Behavior on height { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.menuOpen = !root.menuOpen;
            if (root.menuOpen) root.menuVisible = true;
        }
    }

    // Writes the cava config via Quickshell's own file API (not a bash
    // heredoc -- one less layer of shell-quoting that can silently break)
    // to /tmp, then starts cava directly with no shell wrapper at all.
    // `[input] method = pulse` + `source = auto` pins capture to your
    // default output's monitor via pipewire-pulse, rather than letting
    // cava's own autodetection pick a device (a common cause of "MPRIS
    // says playing, bars don't move": cava quietly listening to a silent
    // mic instead of your speakers).
    FileView {
        id: cavaConfigFile
        path: "/tmp/quickshell-media-widget-cava.conf"
        printErrors: true
    }

    // Small delay after writing the config before starting cava, so the
    // write has definitely landed on disk first.
    Timer {
        id: cavaStartDelay
        interval: 100
        onTriggered: cava.running = true
    }

    Component.onCompleted: {
        cavaConfigFile.setText(
            "[general]\n" +
            "bars = " + root.barCount + "\n" +
            "framerate = 30\n\n" +
            "[input]\n" +
            "method = pulse\n" +
            "source = auto\n\n" +
            "[output]\n" +
            "method = raw\n" +
            "raw_target = /dev/stdout\n" +
            "data_format = ascii\n" +
            "ascii_max_range = " + root.maxRange + "\n\n" +
            "[smoothing]\n" +
            "noise_reduction = 30\n"
        );
        cavaStartDelay.start();
    }

    Process {
        id: cava
        running: false
        command: ["cava", "-p", cavaConfigFile.path]
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.split(";").filter(s => s.length > 0).map(Number);
                if (parts.length === root.barCount) {
                    root.cavaFailed = false;
                    root.levels = parts.map(v => Math.max(0, Math.min(1, v / root.maxRange)));
                }
            }
        }
        stderr: SplitParser {
            onRead: (line) => console.warn("[cava]", line)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.cavaFailed = true;
                console.warn("[cava] exited with code", exitCode,
                    "-- run `cava -p " + cavaConfigFile.path + "` in a terminal to see why " +
                    "(most likely: cava isn't installed, e.g. `pacman -S cava`).");
            }
        }
    }

    // Keeps `player.position` actually updating while the popup is open
    // and something is playing -- see MprisPlayer.position docs: reading
    // it is always accurate, but bindings only refresh on positionChanged().
    Timer {
        interval: 1000
        repeat: true
        running: root.menuVisible && root.playing
        onTriggered: if (root.player) root.player.positionChanged()
    }

    // --- dropdown: Spotify-style now-playing panel ---
    PanelWindow {
        id: menu
        screen: root.screen
        visible: root.menuVisible
        color: "transparent"
        exclusiveZone: 0

        readonly property int panelWidth: 270
        // X: centered under the widget. mapToGlobal returns *desktop*
        // coordinates (spanning every monitor), but margins.left is
        // relative to this window's own screen -- so on any monitor
        // that isn't at desktop-origin (e.g. a second display to the
        // right of a laptop panel), the un-adjusted value pointed well
        // off to the side. Subtracting root.screen.x converts it back
        // to screen-local before we clamp it.
        readonly property real localAnchorX: root.mapToGlobal(root.width / 2, 0).x - root.screen.x
        readonly property int clampedLeft: Math.max(
            Theme.gap,
            Math.min(menu.localAnchorX - menu.panelWidth / 2, root.screen.width - menu.panelWidth - Theme.gap)
        )
        // Y: flush against the *bar's* actual bottom edge. Deliberately
        // NOT recomputed from Theme.gap + Theme.barHeight -- that
        // duplicated the bar's own positioning formula here, and drifted
        // out of sync the moment Bar.qml/Theme.qml's real values changed
        // without this file being updated to match (exactly what caused
        // the visible gap). Reading the enclosing window's own geometry
        // via the Window attached property means this is correct no
        // matter what Bar.qml currently does. Uses contentItem (not
        // root) for the top-edge measurement, since root itself sits
        // vertically centered within the taller bar -- root's own (0,0)
        // is partway down the bar, not the bar's actual top edge.
        readonly property var barWindow: root.Window.window
        readonly property real barWindowTop: (menu.barWindow && menu.barWindow.contentItem)
            ? menu.barWindow.contentItem.mapToGlobal(0, 0).y - root.screen.y
            : 0
        readonly property real barWindowHeight: menu.barWindow ? menu.barWindow.height : Theme.barHeight

        anchors { top: true; left: true }
        margins {
            top: menu.barWindowTop + menu.barWindowHeight
            left: menu.clampedLeft
        }
        implicitWidth: menu.panelWidth
        implicitHeight: menuContent.implicitHeight + Theme.paddingV * 4

        // Clips the sliding card so it can animate in/out from above
        // without resizing the window itself.
        Item {
            id: clipMask
            anchors.fill: parent
            clip: true

            Rectangle {
                id: card
                width: parent.width
                height: parent.height
                // Explicit, not Theme.radius -- this should visibly round
                // regardless of what the bar's own current radius is set
                // to.
                radius: 16
                // Fully opaque -- unlike the bar itself, this panel
                // shouldn't let anything behind it show through.
                color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 1)
                border.color: Theme.divider
                border.width: 1

                // Slides down from hidden-above into place on open, and
                // back up on close. menuVisible lags menuOpen by this
                // animation's duration on the way out (see closeDelay).
                y: root.menuOpen ? 0 : -height
                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                Column {
                    id: menuContent
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: Theme.paddingV * 2
                    width: parent.width - Theme.paddingH * 3
                    spacing: 12

            // Header: collapse chevron / app identity / decorative menu
            Item {
                width: parent.width
                height: 20

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize
                    color: Theme.textDim
                    text: "\uf078" // chevron-down, closes the popup

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: root.menuOpen = false
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.identity ? root.player.identity : ""
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }
            }

            // Large art
            Rectangle {
                id: artFrame
                width: parent.width
                height: width
                radius: 16
                color: Theme.surface
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: art
                    anchors.fill: parent
                    anchors.margins: 2
                    source: (root.player && root.player.trackArtUrl) ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    layer.enabled: true
                    layer.smooth: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: 40
                    color: Theme.textDim
                    text: "\uf001" // music note
                }
            }

            // Title
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: root.player ? (root.player.trackTitle || "Unknown title") : "Nothing playing"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
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

            // Seek bar + times (elapsed / remaining, Spotify-style)
            Column {
                id: seekColumn
                width: parent.width
                spacing: 4
                visible: root.player !== null && root.player.length > 0

                readonly property real ratio: (root.player && root.player.length > 0)
                    ? Math.min(1, Math.max(0, root.player.position / root.player.length))
                    : 0

                Rectangle {
                    id: track
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Theme.surface

                    Rectangle {
                        id: fill
                        width: track.width * seekColumn.ratio
                        height: parent.height
                        radius: 2
                        color: Theme.text
                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
                    }

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: Theme.text
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(track.width - width, Math.max(0, fill.width - width / 2))
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: root.player !== null && root.player.canSeek && root.player.positionSupported
                        onClicked: (mouse) => {
                            const ratio = Math.min(1, Math.max(0, mouse.x / track.width));
                            root.player.position = ratio * root.player.length;
                        }
                    }
                }

                Row {
                    width: parent.width

                    Text {
                        width: parent.width / 2
                        text: root.player ? root.formatTime(root.player.position) : "0:00"
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    Text {
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignRight
                        text: root.player ? ("-" + root.formatTime(root.player.length - root.player.position)) : "0:00"
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }
                }
            }

            // Transport controls: shuffle - prev - play/pause - next - repeat
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                // shuffle
                Text {
                    readonly property bool supported: root.player !== null && root.player.shuffleSupported
                    readonly property bool active: supported && root.player.shuffle
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize - 1
                    color: active ? Theme.accent : Theme.textDim
                    opacity: supported ? 1 : 0.35
                    text: "\uf074" // shuffle
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        enabled: parent.supported
                        onClicked: root.player.shuffle = !root.player.shuffle
                    }
                }

                // previous
                Text {
                    readonly property bool enabled_: root.player !== null && root.player.canGoPrevious
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize + 3
                    color: enabled_ ? Theme.text : Theme.textDim
                    opacity: enabled_ ? 1 : 0.4
                    text: "\uf048" // step-backward
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        enabled: parent.enabled_
                        onClicked: root.player.previous()
                    }
                }

                // play / pause -- large filled circle, mobile-FAB style
                Rectangle {
                    width: 52
                    height: 52
                    radius: 26
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.player !== null ? Theme.text : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: root.playing ? 0 : 2 // optically center the play glyph
                        font.family: Theme.iconFont
                        font.weight: Theme.iconWeight
                        font.pixelSize: Theme.iconSize + 6
                        color: root.player !== null ? Theme.bg : Theme.textDim
                        text: root.playing ? "\uf04c" : "\uf04b" // pause / play
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.player !== null
                        onClicked: root.player.togglePlaying()
                    }
                }

                // next
                Text {
                    readonly property bool enabled_: root.player !== null && root.player.canGoNext
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize + 3
                    color: enabled_ ? Theme.text : Theme.textDim
                    opacity: enabled_ ? 1 : 0.4
                    text: "\uf051" // step-forward
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        enabled: parent.enabled_
                        onClicked: root.player.next()
                    }
                }

                // repeat / loop
                Text {
                    readonly property bool supported: root.player !== null && root.player.loopSupported
                    readonly property bool active: supported && root.player.loopState !== MprisLoopState.None
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.iconFont
                    font.weight: Theme.iconWeight
                    font.pixelSize: Theme.iconSize - 1
                    color: active ? Theme.accent : Theme.textDim
                    opacity: supported ? 1 : 0.35
                    text: "\uf363" // repeat
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        enabled: parent.supported
                        onClicked: {
                            // Cycle None -> Playlist -> Track -> None
                            if (root.player.loopState === MprisLoopState.None) root.player.loopState = MprisLoopState.Playlist;
                            else if (root.player.loopState === MprisLoopState.Playlist) root.player.loopState = MprisLoopState.Track;
                            else root.player.loopState = MprisLoopState.None;
                        }
                    }
                } // repeat Text
            } // transport Row
        } // menuContent Column
            } // card Rectangle
        } // clipMask Item

        // Tears the window down only after the close animation finishes.
        Timer {
            id: closeDelay
            interval: 220
            running: !root.menuOpen && root.menuVisible
            onTriggered: root.menuVisible = false
        }
    } // menu PanelWindow
}
