--------------------------
-- デスクトップエントリ --
--------------------------

local lgi       = require("lgi")
local gears     = require("gears")
local utilities = require("utilities")

local M = {
    base        = require("desktop_entry.base"),
    link        = require("desktop_entry.link"),
    application = require("desktop_entry.application")
}

local entries = {}

----------------------
-- エントリのパース --
----------------------

-- 実行ファイルのフルパスを返す
local function get_full_path_executable(name)
    if name:sub(1, 1) == "/" then return name end

    for _, env_path in ipairs(utilities.environment.get_paths()) do
        local path = env_path .. name
        if lgi.Gio.File.new_for_path(path):query_info("standard::name", "NONE") then
            return path
        end
    end
end

-- オブジェクトの生成
local function create_class(path, async)
    local prefix = async and "async_" or ""
    local groups = utilities.keyfile[prefix .. "parse"](path)

    -- ディレクトリなら飛ばす
    if groups["Desktop Entry"].Type   == "Directory" then return end
    -- Hiddenがtrueなら飛ばす
    if groups["Desktop Entry"].Hidden == "true"      then return end
    -- TryExec
    if groups["Desktop Entry"].TryExec then
        local file = lgi.Gio.File.new_for_path(utilities.environment.find_full_path(groups["Desktop Entry"].TryExec))
        local info = file[prefix .. "query_info"](file, "standard::content-type", "NONE")
        -- ファイルが存在しないなら飛ばす
        if not info then return end
        -- 実行可能でないなら飛ばす
        if not lgi.Gio.content_type_can_be_executable(info:get_content_type()) then return end
    end

    -- カテゴリ
    local categories = {}
    if groups["Desktop Entry"].Categories then
        for category in groups["Desktop Entry"].Categories:gmatch("[^;]+") do
            categories[#categories+1] = category
        end
    end

    -- アクション
    local actions
    if groups["Desktop Entry"].Actions then
        actions = {}
        for action in groups["Desktop Entry"].Actions:gmatch("[^;]+") do
            actions[#actions+1] = {
                name = groups["Desktop Action " .. action].Name,
                icon = groups["Desktop Action " .. action].Icon,
                exec = groups["Desktop Action " .. action].Exec and groups["Desktop Action " .. action].Exec:gsub("%%[fFuU]", "")
            }
        end
    end

    local hidden = false
    if groups["Desktop Entry"].OnlyShowIn and not groups["Desktop Entry"].OnlyShowIn:find("awesome") or
       groups["Desktop Entry"].NotShowIn  and     groups["Desktop Entry"].NotShowIn:find ("awesome") then
        hidden = true
    end

    -- オブジェクトの生成
    local object
    if groups["Desktop Entry"].Type == "Application" then
        object = M.application(
            groups["Desktop Entry"].Name,
            groups["Desktop Entry"].Icon,
            categories,
            hidden,
            groups["Desktop Entry"].Exec and groups["Desktop Entry"].Exec:gsub("%%[fFuU]", ""),
            groups["Desktop Entry"].Terminal and groups["Desktop Entry"].Terminal == "true" or false,
            groups["Desktop Entry"].StartupWMClass,
            actions
        )
    else
        object = M.link(groups["Desktop Entry"].Name, groups["Desktop Entry"].Icon, categories, hidden, groups["Desktop Entry"].URL)
    end

    return object
end

function M.parse(path)       return create_class(path)       end
function M.async_parse(path) return create_class(path, true) end

--------------------
-- エントリの列挙 --
--------------------

for _, data_dir in ipairs(utilities.environment.get_xdg_data_dirs()) do
    local base = data_dir .. "applications/"
    local enumerator = lgi.Gio.File.new_for_path(base):enumerate_children("standard::name", "NONE")
    if enumerator then
        for info in function () return enumerator:next_file() end do
            local name      = info:get_name()
            local name_left = name:match("^(.+)%.")
            local path      = base .. name
            if name:match("%.desktop$") and not entries[name_left] then
                entries[name_left] = M.parse(path)
            end
        end

        enumerator:close()
    end
end

function M.get_entries() return entries end

return M
