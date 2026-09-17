pragma Singleton
import Quickshell
import QtQuick

// Central place for the bar's look. Change values here instead of hunting
// through every module. Palette is a dark, low-saturation slate with a
// single blue accent (swap `accent` for a different vibe).
Singleton {
    // Surfaces
    readonly property color bg: "#cc1a1c23"          // bar background (rgba(26,28,35,0.8))
    readonly property color surface: "#14ffffff"      // subtle chip background (8% white)
    readonly property color surfaceHover: "#22ffffff" // chip on hover (13% white)

    // Text
    readonly property color text: "#e6e9f0"
    readonly property color textDim: "#9aa1b1"

    // Semantic
    readonly property color accent: "#7aa2f7"   // focused workspace / links / highlights
    readonly property color good: "#9ece6a"     // charging / connected
    readonly property color warn: "#e0af68"     // mid battery
    readonly property color bad: "#f7768e"      // critical / muted / disconnected

    // Metrics
    readonly property int barHeight: 32
    readonly property int gap: 6          // distance from screen edges (floating bar look)
    readonly property int radius: 12
    readonly property int chipRadius: 8
    readonly property int spacing: 6      // gap between chips within a section
    readonly property int sectionSpacing: 14
    readonly property int paddingH: 10
    readonly property int paddingV: 4

    // Fonts
    // otf-font-awesome (FontAwesome 4) must be installed for the icon
    // glyphs used across the modules to render.
    readonly property string fontFamily: "Roboto, Helvetica, Arial, sans-serif"
    readonly property string iconFont: "FontAwesome"
    readonly property int fontSize: 13
    readonly property int iconSize: 13
}
