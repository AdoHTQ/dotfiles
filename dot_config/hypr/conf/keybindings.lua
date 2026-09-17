-- ~/.config/hypr/conf/keybindings.lua
-- Converted from conf/keybindings.conf

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        accel_profile = "flat",

        sensitivity = 0.0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Old `gestures { workspace_swipe = true }` is now hl.gesture:
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- MY PROGRAMS ----
---------------------
-- Hyprlang `$variables` become plain Lua locals.
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "wofi --show drun -I"
local browser     = "firefox"
local editor      = "codium"

---------------------
---- EXECUTABLES ----
---------------------
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind("ALT + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + CTRL + return", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("godot-mono"))

-- NOTE: the old config bound SUPER+SHIFT+W twice (hyprdynamicmonitors, then
-- waypaper). The second line silently won. Only the winner is kept here --
-- pick a different key for the other one if you want both.
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper"))
-- hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("kitty -e hyprdynamicmonitors tui"))

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("kitty -e wiremix"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("hyprshot -m region"))

-------------------------
---- TRACKPAD TOGGLE ----
-------------------------
-- The old version chained five shell `$vars` through a status file to keep
-- track of on/off. Lua holds the state directly, so the file is gone.
local touchpadEnabled = true

hl.bind(mainMod .. " + M", function()
    touchpadEnabled = not touchpadEnabled
    -- TODO: replace with your touchpad's name from `hyprctl devices` and this
    -- becomes a native hl.device({ name = "...", enabled = touchpadEnabled })
    -- call with no shell involved.
    hl.exec_cmd(string.format(
        [[dev=$(hyprctl devices | grep touchpad | xargs); ]] ..
        [[hyprctl keyword "device[$dev]:enabled" %s; ]] ..
        [[notify-send "Touchpad" "Enabled: %s"]],
        tostring(touchpadEnabled), tostring(touchpadEnabled)))
end)

-----------------
---- UTILITY ----
-----------------
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + return", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Resize the active window (`resizeactive` -> window.resize with relative = true)
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- The twenty hand-written lines collapse into one loop.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging (`bindm`)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------
---- MULTIMEDIA ----
-------------------
-- `bindel` -> { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- `bindl` -> { locked = true }. Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
