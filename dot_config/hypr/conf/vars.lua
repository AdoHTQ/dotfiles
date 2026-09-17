-- ~/.config/hypr/conf/vars.lua
-- Converted from conf/vars.conf

local home = os.getenv("HOME")

hl.env("XCURSOR_SIZE", "12")
hl.env("HYPRCURSOR_SIZE", "12")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- hl.env does not expand `~`, so build the path explicitly.
hl.env("HYPRSHOT_DIR", home .. "/Documents/screenshots/")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")        -- for Qt apps
hl.env("GTK_THEME", "Orchis-Dark-Compact")     -- for GTK apps
