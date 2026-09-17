-- ~/.config/hypr/theme.lua
-- Converted from theme.conf

-- hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.90 0.90" })

hl.config({
    general = {
        border_size = 1,
        -- no_border_on_floating = true,

        gaps_in = 3,
        gaps_out = 5,

        col = {
            -- A gradient becomes a table of colors plus an angle.
            active_border = { colors = { "rgba(d5f0eaff)", "rgba(37403eff)" }, angle = 45 },
            inactive_border = "rgba(1c2120aa)",
        },

        resize_on_border = false,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 20,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
        },

        blur = {
            enabled = true,
            size = 8,
            passes = 1,

            ignore_opacity = false,
            contrast = 0.4,

            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

--------------------
---- ANIMATIONS ----
--------------------
-- `bezier = name, x1, y1, x2, y2` -> hl.curve with the control points paired up.
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

-- `animation = leaf, on/off, speed, curve, style`
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "wind" })
