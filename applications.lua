----------------------
-- アプリケーション --
----------------------

local lgi   = require("lgi")
local gears = require("gears")
local utils = require("utils")

-- エントリ
local entries = {}

--------------------
-- エントリの列挙 --
--------------------

-- 実行ファイルのフルパスを返す
local function get_full_path_executable(name)
    if name:sub(1, 1) == "/" then return name end

    for _, env_path in ipairs(utils.environment.get_paths()) do
        local path = env_path .. name
        if lgi.Gio.File.new_for_path(path):query_info("standard::name", "NONE") then
            return path
        end
    end
end

-- ベースディレクトリから探す
for _, data_dir in ipairs(utils.environment.get_xdg_data_dirs()) do
    local base = data_dir .. "applications/"
    local enumerator = lgi.Gio.File.new_for_path(base):enumerate_children("standard::name", "NONE")
    if enumerator then
        for info in function () return enumerator:next_file() end do
            local name      = info:get_name()
            local name_left = name:match("^(.+)%.")
            local path      = base .. name
            if name:match("%.desktop$") and not entries[name_left] then
                -- エントリのパース
                local groups = utils.keyfile.parse(path)

                -- ディレクトリなら飛ばす
                if groups["Desktop Entry"].Type   == "Directory" then goto continue end
                -- Hiddenがtrueなら飛ばす
                if groups["Desktop Entry"].Hidden == "true"      then goto continue end
                -- TryExec
                if groups["Desktop Entry"].TryExec then
                    local tryexec_info = lgi.Gio.File.new_for_path(get_full_path_executable(groups["Desktop Entry"].TryExec)):query_info("standard::content-type", "NONE")
                    -- ファイルが存在しないなら飛ばす
                    if not tryexec_info then goto continue end
                    -- 実行可能でないなら飛ばす
                    if not lgi.Gio.content_type_can_be_executable(tryexec_info:get_content_type()) then goto continue end
                end

                -- エントリのキー
                entries[name_left] = {
                    name             = groups["Desktop Entry"].Name,
                    icon             = groups["Desktop Entry"].Icon,
                    terminal         = groups["Desktop Entry"].Terminal and groups["Desktop Entry"].Terminal == "true" or nil,
                    exec             = groups["Desktop Entry"].Exec and groups["Desktop Entry"].Exec:gsub("%%[fFuU]", ""),
                    startup_wm_class = groups["Desktop Entry"].StartupWMClass,
                    url              = groups["Desktop Entry"].URL
                }
                if groups["Desktop Entry"].OnlyShowIn and not groups["Desktop Entry"].OnlyShowIn:find("awesome") or
                   groups["Desktop Entry"].NotShowIn  and     groups["Desktop Entry"].NotShowIn:find ("awesome") then
                    entries[name_left].hidden = true
                end
                if groups["Desktop Entry"].Categories then
                    entries[name_left].categories = {}
                    for category in groups["Desktop Entry"].Categories:gmatch("[^;]+") do
                        entries[name_left].categories[#entries[name_left].categories+1] = category
                    end
                end

                -- アクション
                if groups["Desktop Entry"].Actions then
                    entries[name_left].actions = {}
                    for action in groups["Desktop Entry"].Actions:gmatch("[^;]+") do
                        entries[name_left].actions[action] = {
                            name = groups["Desktop Action " .. action].Name,
                            icon = groups["Desktop Action " .. action].Icon,
                            exec = groups["Desktop Action " .. action].Exec and groups["Desktop Action " .. action].Exec:gsub("%%[fFuU]", "")
                        }
                    end
                end
            end

            ::continue::
        end
        enumerator:close()
    end
end

--[[
for _, entry in pairs(entries) do
    gears.table.crush(entry, utils.keyfile.parse(entry.path))

    if entry["Desktop Entry"].Exec then
        entry.full_path = get_full_path_executable(entry["Desktop Entry"].Exec:match("^([^%s]+)"))
        entry.real_path = lgi.Gio.File.new_for_path(entry.full_path):query_info("standard::symlink-target", "NONE"):get_symlink_target()
        entry.real_path = entry.real_path and get_full_path_executable(entry.real_path)
    end
end
]]
