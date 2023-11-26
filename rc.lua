-------------------
-- Awesomeの設定 --
-------------------

local awful  = require("awful")
local theme  = require("theme")
local common = require("common")

-- デバッグ用
function print_table(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. key .. ":")
            print_table(value, indent .. "    ")
        else
            print(indent .. key .. ": " .. tostring(value))
        end
    end
end

----------------
-- オプション --
----------------

local options = {
    -- 外観
    font          = "System-ui 8",
    titlebar_font = "System-ui Bold 8",
    icon_theme    = "Colloid-teal-nord-light",
    icon_scale    = 2,
    colorscheme   = "rose_pine_dawn",
    wallpaper     = { "highlight_high", source = "colorscheme" },
    -- 規定のアプリケーション
    default_apps = {
        terminal    = "kitty",
        web_browser = "firefox",
        editor      = os.getenv("EDITOR") or "nvim"
    },
    -- 固定されたアプリケーション
    pinned_apps = { "firefox", "discord", "thunar", "gimp", "inkscape", "minecraft-launcher", "steam", "kitty" }
}

------------
-- 初期化 --
------------

-- テーマとアイコン
theme.initialize(options)
common.xdg.icon.initialize()

-- レイアウト
tag.connect_signal("request::default_layouts", function ()
    awful.layout.append_default_layout(awful.layout.suit.floating)
end)

-- スクリーン
require("main.screen")

require("main.mainmenu2")
