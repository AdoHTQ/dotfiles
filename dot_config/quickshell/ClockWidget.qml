import QtQuick

// clock -> "{:%a, %d. %b  %H:%M}", e.g. "Thu, 17. Sep  14:05"
Chip {
    id: root

    property string now: Qt.formatDateTime(new Date(), "ddd, dd. MMM  hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = Qt.formatDateTime(new Date(), "ddd, dd. MMM  hh:mm")
    }
    // Quickshell also exposes a lower-overhead `SystemClock` type if you'd
    // rather not poll every second; a plain Timer is used here to keep this
    // file dependency-free and easy to read.

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.now
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
