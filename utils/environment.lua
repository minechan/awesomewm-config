--------------
-- 環境変数 --
--------------

local gears = require("gears")

local M = {}

----------
-- PATH --
----------

local paths = {}
for path in os.getenv("PATH"):gmatch("[^:]+") do
    paths[#paths+1] = path .. "/"
end

function M.get_paths() return paths end

--------------
-- ロケール --
--------------

local locale_matches = {}
local env_locale     = os.getenv("LANG")

if env_locale then
    local locale_lang     = env_locale:match("^(%l+)")
    local locale_country  = env_locale:match("_(%u+)")
    local locale_modifier = env_locale:match("@(.+)")

    if locale_country and locale_modifier then
        locale_matches[#locale_matches+1] = ("%s_%s@%s"):format(locale_lang, locale_country, locale_modifier)
    end
    if locale_country then
        locale_matches[#locale_matches+1] = ("%s_%s"):format(locale_lang, locale_country)
    end
    if locale_modifier then
        locale_matches[#locale_matches+1] = ("%s@%s"):format(locale_lang, locale_modifier)
    end
    locale_matches[#locale_matches+1] = locale_lang
end

function M.get_locale_matches() return locale_matches end

-----------------------------
-- XDGのデータディレクトリ --
-----------------------------

function M.get_xdg_data_dirs()
    return gears.table.join({ gears.filesystem.get_xdg_data_home() }, gears.filesystem.get_xdg_data_dirs())
end

return M
