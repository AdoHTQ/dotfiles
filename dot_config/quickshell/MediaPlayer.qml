import QtQuick
import Quickshell.Services.Mpris

// mpris -> now-playing chip for whatever's active over MPRIS (Spotify,
// browser tabs, mpv, etc). Prefers a currently-playing player if there are
// several, otherwise falls back to the first one Quickshell knows about.
// Hidden entirely when nothing is available, so it costs zero bar space
// at rest instead of sitting there empty.
//
// Left click: play/pause. Scroll: next/previous track.
//
// NOTE: property/enum names below (trackTitle, trackArtist, playbackState,
// MprisPlaybackState.Playing, canGoNext/Previous) match Quickshell's Mpris
// service at the time this was written. If your Quickshell version renamed
// any of these, `qmlls`/the Quickshell docs for Quickshell.Services.Mpris
// will show the current names to swap in.
Chip {
    id: root

    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: {
        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Playing) return p;
        }
        return players.length > 0 ? players[0] : null;
    }
    readonly property bool playing: player !== null && player.playbackState === MprisPlaybackState.Playing

    visible: player !== null

    onClicked: if (root.player) root.player.togglePlaying()
    onWheelUp: if (root.player && root.player.canGoNext) root.player.next()
    onWheelDown: if (root.player && root.player.canGoPrevious) root.player.previous()

    Text {
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        font.weight: Theme.iconWeight
        color: Theme.text
        text: root.playing ? "\uf04c" : "\uf04b" // pause / play
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
        // Cap the width so a long track name can't push the rest of the
        // bar's right-hand modules off toward the middle.
        width: Math.min(implicitWidth, 200)
        text: {
            if (!root.player) return "";
            const title = root.player.trackTitle || "";
            const artist = root.player.trackArtist || "";
            return artist ? (artist + "  -  " + title) : title;
        }
    }
}
