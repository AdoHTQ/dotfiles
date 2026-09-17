import Quickshell
import QtQuick

// Entry point. `qs` loads this file from ~/.config/quickshell/shell.qml.
// A Bar is created (and destroyed) for every connected screen, matching
// waybar's default multi-monitor behavior.
ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Bar {}
    }
}
