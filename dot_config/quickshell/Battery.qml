import QtQuick
import Quickshell.Services.UPower

// battery -> hidden entirely on desktops with no battery, instead of
// showing a meaningless module.
Chip {
    id: root

    readonly property UPowerDevice dev: UPower.displayDevice
    readonly property bool present: dev && dev.ready && dev.isLaptopBattery
    readonly property int pct: present ? Math.round(dev.percentage * 100) : 0
    readonly property bool charging: present && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool critical: present && !charging && pct <= 15

    visible: present

    readonly property color fg: critical ? Theme.bad : (charging ? Theme.good : Theme.text)

    Text {
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        color: root.fg
        // battery-full / three-quarters / half / quarter / empty
        text: {
            const p = root.pct;
            if (p > 85) return "\uf240";
            if (p > 60) return "\uf241";
            if (p > 35) return "\uf242";
            if (p > 10) return "\uf243";
            return "\uf244";
        }
    }

    Text {
        text: root.pct + "%"
        color: root.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
