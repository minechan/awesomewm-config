------------
-- テーマ --
------------

local gears     = require("gears")
local beautiful = require("beautiful")

local M   = {}
local dpi = beautiful.xresources.apply_dpi

------------
-- テーマ --
------------

local theme = {
    general = {
        border_width = 1,
    },
    client = {
        corner_radius = dpi(8),
        bevel_width   = dpi(1)
    },
    titlebar = {
        size             = dpi(28),
        border_width     = dpi(1),
        button_icon_size = dpi(12)
    },
    menu = {
        corner_radius      = dpi(8),
        padding            = dpi(6),
        item_height        = dpi(24),
        item_icon_size     = dpi(16),
        item_padding       = dpi(6),
        item_corner_radius = dpi(4),
        item_border_width  = 1,
        separator_width    = 1,
        separator_margin   = dpi(4)
    },
    desktop = {}
}

--------------------
-- テーマの初期化 --
--------------------

function M.initialize(options)
    local colorscheme = require("theme.colorschemes." .. options.colorscheme)

    theme.palette            = colorscheme.palette
    theme.general.font       = options.font
    theme.titlebar.font      = options.titlebar_font
    theme.desktop.wallpaper  = options.wallpaper
    theme.desktop.icon_theme = options.icon_theme or "hicolor"
    theme.desktop.icon_scale = options.icon_scale or 1
    for name, keys in pairs(theme) do
        gears.table.crush(keys, colorscheme.colors[name] or {}, true)
        if name ~= "general" then
            setmetatable(keys, { __index = theme.general })
        end
    end

    beautiful.init(theme)
end

return M
