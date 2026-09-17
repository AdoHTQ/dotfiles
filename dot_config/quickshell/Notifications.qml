import QtQuick
import Quickshell
import Quickshell.Io

// custom/notification -> swaync toggle. This mirrors the module that was
// commented out in your waybar config.jsonc; it isn't included in Bar.qml
// by default either (see the commented-out line there). Add it to Bar's
// right-hand Row to enable it.
//
// NOTE: unlike waybar's "return-type": "json" long-poll, this version
// doesn't stream swaync's live dnd/notification-count state -- it just
// gives you a working toggle. Wiring up the live badge would mean keeping
// a persistent Process reading swaync-client -swb line by line; ask if you
// want that added.
Chip {
    id: root

    onClicked: Quickshell.execDetached(["swaync-client", "-t", "-sw"])
    onRightClicked: Quickshell.execDetached(["swaync-client", "-d", "-sw"])

    Text {
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        color: Theme.text
        text: "\uf0f3" // bell
    }
}
