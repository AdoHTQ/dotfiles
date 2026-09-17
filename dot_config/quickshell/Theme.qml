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

    // A hairline used to give the flush-mounted bar a bit of definition
    // against whatever is directly below it, since it no longer floats.
    readonly property color divider: "#1affffff" // 10% white

    // Metrics
    readonly property int barHeight: 32
    readonly property int gap: 0          // 0 = bar sits flush against the screen edges
    readonly property int radius: 0       // 0 = square corners, flush with the screen
    readonly property int chipRadius: 8   // individual chips keep their pill shape
    readonly property int spacing: 6      // gap between chips within a section
    readonly property int sectionSpacing: 14
    readonly property int paddingH: 10
    readonly property int paddingV: 4

    // Fonts
    // Confirmed installed via `fc-list | grep -i "font awesome"`: this
    // system has Font Awesome 7, family "Font Awesome 7 Free". All the
    // glyphs used across the modules (bell, volume, battery, power) are
    // from the "Solid" style, which only exists at weight 900 in that font
    // file -- using the regular weight renders empty boxes even with the
    // right family name, so iconWeight below matters as much as the family
    // name does. If you ever switch systems/fonts again, re-check with:
    //   fc-list | grep -i "font awesome"
    readonly property string fontFamily: "Roboto, Helvetica, Arial, sans-serif"
    readonly property string iconFont: "Font Awesome 7 Free"
    readonly property int iconWeight: Font.Black // required for FA7 "Solid" glyphs
    readonly property int fontSize: 13
    readonly property int iconSize: 13
}
