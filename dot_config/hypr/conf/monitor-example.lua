-- ~/.config/hypr/conf/monitor-example.lua
-- Converted from conf/monitor-example.conf
-- Copy this to conf/monitor.lua -- hyprland.lua does require("conf.monitor").

-- Display Setup
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "1600x0", scale = 1.2 })
hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "0x0", scale = 1.2 })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Fix drawing tablet mapping.
-- Per-device settings are no longer a nested `input { tablet { ... } }` block;
-- they're a top-level hl.device call keyed by device name.
hl.device({
    name = "Weylus Stylus",
    output = "DP-1",
})
