----------------
-- スクリーン --
----------------

local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

-- 壁紙
screen.connect_signal("request::wallpaper", function (s)
    local wallpaper = beautiful.desktop.wallpaper
    if wallpaper.source == "file" then
        awful.wallpaper {
            screen = s,
            widget = {
                {
                    image                 = wallpaper[1],
                    resize                = not wallpaper.tiled,
                    horizontal_fit_policy = "fit",
                    widget                = wibox.widget.imagebox
                },
                valign = "center",
                halign = "center",
                tiled  = not wallpaper.tiled,
                widget = wibox.container.tile
            }
        }
    elseif wallpaper.source == "hex" then
        awful.wallpaper { screen = s, bg = wallpaper[1] }
    elseif wallpaper.source == "colorscheme" then
        awful.wallpaper { screen = s, bg = beautiful.palette[wallpaper[1]] }
    end
end)
