--------------
-- 環境変数 --
--------------

local lgi   = require("lgi")
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

----------------------------------
-- 実行ファイルの絶対パスを返す --
----------------------------------

function M.find_full_path(name)
    if name:sub(1, 1) == "/" then return name end

    for _, env_path in ipairs(paths) do
        local path = env_path .. name
        if lgi.Gio.File.new_for_path(path):query_info("standard::name", "NONE") then
            return path
        end
    end
end

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
