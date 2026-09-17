import QtQuick

// A small rounded pill used to wrap every module's content. Give it
// `content` and optionally hook `clicked` / `rightClicked` / `wheel`.
Rectangle {
    id: root

    // Aliased to `data`, not `children`: `children` only accepts visual
    // Items, but several modules also drop non-visual helpers (Timer,
    // Connections, PwObjectTracker) directly inside a Chip. `data` accepts
    // both -- Items among them still lay out in `inner` as normal.
    default property alias content: inner.data
    property bool hoverable: true
    property bool active: false // draws with the accent tint instead of the neutral surface
    readonly property alias hovered: mouse.containsMouse

    signal clicked()
    signal rightClicked()
    signal wheelUp()
    signal wheelDown()

    implicitWidth: inner.implicitWidth + Theme.paddingH * 2
    implicitHeight: Theme.barHeight - Theme.paddingV * 2
    radius: Theme.chipRadius
    color: active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                  : (mouse.containsMouse && hoverable ? Theme.surfaceHover : Theme.surface)

    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: inner
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) root.wheelUp();
            else if (wheel.angleDelta.y < 0) root.wheelDown();
        }
    }
}
