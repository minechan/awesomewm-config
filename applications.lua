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
