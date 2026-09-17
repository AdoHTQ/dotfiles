-- ~/.config/hypr/hyprland.lua
-- Converted from the old hyprlang hyprland.conf (Hyprland 0.55+ Lua config).
-- Docs: https://wiki.hypr.land/Configuring/Start/

------------------
---- MODULES ----
------------------
-- `source = ...` becomes `require`. package.path is set to
-- ~/.config/hypr/?.lua and ~/.config/hypr/?/init.lua, so dots are directories.

require("conf.keybindings")
require("conf.vars")
require("conf.monitor")

require("theme")

-------------------
---- AUTOSTART ----
-------------------
-- `exec-once` -> run once, on compositor start.
hl.on("hyprland.start", function()
    hl.exec_cmd("swaync")
    hl.exec_cmd("waypaper --restore")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("qs")
end)

-- `exec` -> runs on every config load. This file is re-executed on reload,
-- so a bare top-level exec_cmd is the direct equivalent.
-- Global dark theme
hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "YOUR_DARK_GTK3_THEME"') -- for GTK3 apps
hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')       -- for GTK4 apps

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
    name = "float-kicad",
    match = { class = "kicad" },
    float = true,
})

hl.window_rule({
    name = "float-spotify",
    match = { class = "spotify" },
    float = true,
})

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--     name = "fix-xwayland-drags",
--     match = {
--         class = "^$",
--         title = "^$",
--         xwayland = true,
--         float = true,
--         fullscreen = false,
--         pin = false,
--     },
--     no_focus = true,
-- })

-----------------
---- LAYOUTS ----
-----------------
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        -- pseudotile = true, -- Master switch for pseudotiling. Bound to mainMod + P in keybindings.lua
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

--------------
---- MISC ----
--------------
hl.config({
    misc = {
        force_default_wallpaper = 1,  -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})
