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

for _, data_dir in ipairs(utils.environment.get_xdg_data_dirs()) do
    local base = data_dir .. "applications/"
    local enumerator = lgi.Gio.File.new_for_path(base):enumerate_children("standard::name", "NONE")
    if enumerator then
        for info in function () return enumerator:next_file() end do
            local name = info:get_name()
            if name:match("%.desktop$") then
                entries[name] = entries[name] or { path = base .. name }
            end
        end
        enumerator:close()
    end
end

----------------------
-- エントリのパース --
----------------------

-- 実行ファイルのフルパスを返す
local function get_executable_full_path(name)
    if name:sub(1, 1) == "/" then return name end

    for _, env_path in ipairs(utils.environment.get_paths()) do
        local path = env_path .. name
        if lgi.Gio.File.new_for_path(path):query_info("standard::name", "NONE") then
            return path
        end
    end
end

for _, entry in pairs(entries) do
    gears.table.crush(entry, utils.keyfile.parse(entry.path))

    if entry["Desktop Entry"].Exec then
        entry.full_path = get_executable_full_path(entry["Desktop Entry"].Exec:match("^([^%s]+)"))
        entry.real_path = lgi.Gio.File.new_for_path(entry.full_path):query_info("standard::symlink-target", "NONE"):get_symlink_target()
        entry.real_path = entry.real_path and get_executable_full_path(entry.real_path)
    end
end
