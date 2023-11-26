-------------
-- Keyfile --
-------------

local lgi         = require("lgi")
local gears       = require("gears")
local environment = require("common.environment")

local M = {}

---------------------
-- Keyfileのパース --
---------------------

local function generate_table(iterator)
    local locale_matches = environment.get_locale_matches()
    local groups         = {}
    local current_group, key_locales

    for line in iterator do
        -- グループ
        local group_name = line:match("^%[([%g%s]+)%]")
        if group_name then
            current_group = {}
            groups[group_name] = current_group
            key_locales = {}
        end

        -- キー
        local left, value = line:match("^([%g%s]+)%s*=%s*(.+)")
        if left and value then
            local key, locale = left:match("^([%w%-]+)%[([%g%s]+)%]")
            key = key or left

            -- グループが存在しないならデフォルトにフォールバック
            if not current_group then
                current_group = {}
        groups.default = current_group
                key_locales = {}
            end

            if locale then
                local locale_index = gears.table.hasitem(locale_matches, locale)
                if locale_index and ((key_locales[key] and locale_index < key_locales[key]) or not key_locales[key]) then
                    current_group[key] = value
                    key_locales[key]   = locale_index
                end
            else
                current_group[key] = current_group[key] or value
            end
        end
    end

    return groups
end

function M.parse(path)
    local file = io.open(path, "r")
    assert(file, "Couldn't read a file.")

    local result = generate_table(file:lines())
    file:close()
    return result
end

function M.async_parse(path)
    local file = lgi.Gio.File.new_for_path(path)
    local size = file:async_query_info("standard::size", "NONE"):get_size()

    local stream = file:async_read()
    local result = generate_table((stream:async_read_bytes(size).data):gmatch("[^\n]*"))
    stream:async_close()

    return result
end

return M
