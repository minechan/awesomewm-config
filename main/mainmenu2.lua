--------------------
-- メインメニュー --
--------------------

local ui        = require("ui")
local gears     = require("gears")
local wibox     = require("wibox")
local common    = require("common")
local beautiful = require("beautiful")

--------------------
-- メニューの生成 --
--------------------

local entries = {}

local menu_layout = wibox.layout.fixed.vertical()
local menu_wibox  = wibox {
    screen       = screen.primary,
    visible      = true,
    x            = 16,
    y            = 16,
    width        = (beautiful.menu.border_width + beautiful.menu.padding) * 2,
    height       = (beautiful.menu.border_width + beautiful.menu.padding) * 2,
    fg           = beautiful.menu.item_fg or beautiful.menu.fg,
    bg           = beautiful.menu.bg,
    border_color = beautiful.menu.border_color,
    border_width = beautiful.menu.border_width,
    shape        = function (cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.menu.corner_radius)
    end,
    widget = {
        menu_layout,
        margins = beautiful.menu.padding,
        widget  = wibox.container.margin
    }
}

for _, entry in pairs(common.xdg.desktop_entry.get_entries()) do
    if not entry.hidden then entries[#entries+1] = entry end
end
table.sort(entries, function (a, b) return a.name < b.name end)

for _, entry in ipairs(entries) do
    local menuitem = wibox.widget {
        text   = entry.name,
        widget = ui.widget.menuitem
    }
    if entry.icon then
        common.xdg.icon.find_icon(entry.icon, beautiful.menu.item_icon_size, "applications", function (path, _)
            if path then menuitem.icon = common.image(path) end
        end)
    end
    menu_layout:add(menuitem)
    local width, height = wibox.widget.base.fit_widget(menu_layout, { dpi = menu_wibox.screen.dpi }, menuitem, 1000, 1000)
    menu_wibox.width  = math.max(menu_wibox.width, width + (beautiful.menu.border_width + beautiful.menu.padding) * 2)
    menu_wibox.height = menu_wibox.height + height
end
