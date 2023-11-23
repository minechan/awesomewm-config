--------------
-- アイコン --
--------------

local lgi         = require("lgi")
local gears       = require("gears")
local keyfile     = require("utilities.keyfile")
local environment = require("utilities.environment")

local M = {}

local themes          = {}
local icon_cache      = {}
local find_icon_queue = {}
local find_icon_ready = false

--------------------
-- アイコンの検索 --
--------------------

local function find_icon_main(name, size, context, callback)
    assert(type(name)     == "string"  , "Argument name isn't a string.")
    assert(type(size)     == "number"  , "Argument size isn't a number.")
    assert(type(context)  == "string"  , "Argument context isn't a string.")
    assert(type(callback) == "function", "Argument callback isn't a function.")

    -- テーマを探していないならキューに入れる
    if not find_icon_ready then
        find_icon_queue[#find_icon_queue+1] = { name = name, size = size, context = context, callback = callback }
        return
    end

    -- キャッシュからアイコンを探す
    if icon_cache[context] and icon_cache[context][name] then
        if icon_cache[context][name].not_found then return callback() end

        local path, temp_size
        for _, sub_dir in ipairs(icon_cache[context][name]) do
            if sub_dir.min_size <= size and size <= sub_dir.max_size then
                path      = sub_dir.path
                temp_size = size
                break
            else
                -- local is_right = size < sub_dir.min_size
                -- local dist = is_right and (size - sub_dir.min_size) or (sub_dir.max_size - size)
                local delta = size - (size < sub_dir.min_size and sub_dir.min_size or sub_dir.max_size)
                if temp_size then
                    local temp_dist = math.abs(size - temp_size)
                    if math.abs(delta) < temp_dist then
                        path      = sub_dir.path
                        -- temp_size = is_right and sub_dir.min_size or sub_dir.max_size
                        temp_size = size - delta
                    end
                else
                    path      = sub_dir.path
                    -- temp_size = is_right and sub_dir.min_size or sub_dir.max_size
                    temp_size = size - delta
                end
            end
        end

        return callback(path, temp_size)
    -- キャッシュになければファイルからアイコンを探す
    else
        local found_sub_dirs = {}

        for _, theme in ipairs(themes) do
            for _, scale in ipairs { options.icon_scale, options.icon_scale and 1 } do
                if not theme[context] or not theme[context][scale] then goto continue end
                for _, sub_dir in ipairs(theme[context][scale]) do
                    local found = false
                    for _, target_dir in ipairs(sub_dir) do
                        for _, ext in ipairs { ".svg", ".png", ".xpm" } do
                            local path = ("%s%s%s"):format(target_dir, name, ext)
                            if lgi.Gio.File.new_for_path(path):async_query_info("standard::name", "NONE") then
                                found_sub_dirs[#found_sub_dirs+1] = { path = path, min_size = sub_dir.min_size, max_size = sub_dir.max_size }
                                found = true
                                break
                            end
                        end
                        if found then break end
                    end
                end
                if #found_sub_dirs >= 1 then break end

                ::continue::
            end
            if #found_sub_dirs >= 1 then break end
        end

        -- キャッシュに追加
        found_sub_dirs.not_found = #found_sub_dirs == 0 or nil
        icon_cache[context] = icon_cache[context] or {}
        icon_cache[context][name] = found_sub_dirs

        return find_icon_main(name, size, context, callback)
    end
end

function M.find_icon(name, size, context, callback)
    lgi.Gio.Async.start(find_icon_main)(name, size, context, callback)
end

--------------------
-- テーマのパース --
--------------------

local theme_count = 0

local function parse_icon_theme(name)
    theme_count = theme_count + 1

    -- インデックスを探す
    local index_file_path
    for _, base in ipairs(environment.get_xdg_data_dirs()) do
        local temp_path = base .. "icons/" .. name .. "/index.theme"
        if lgi.Gio.File.new_for_path(temp_path):async_query_info("standard::name", "NONE") then
            index_file_path = temp_path
            break
        end
    end

    if index_file_path then
        local theme_index = #themes + 1
        themes[theme_index] = {}
        local groups = keyfile.async_parse(index_file_path)

        -- 継承元のテーマを探す
        if name ~= "hicolor" then
            lgi.Gio.Async.start(parse_icon_theme)(groups["Icon Theme"].Inherits or "hicolor")
        end

        -- ディレクトリの列挙
        for sub_dir in groups["Icon Theme"].Directories:gmatch("[^,]+") do
            if not groups[sub_dir].Size then goto continue end

            local found_dirs = {}
            for _, data_dir in ipairs(environment.get_xdg_data_dirs()) do
                local target = ("%sicons/%s/%s/"):format(data_dir, name, sub_dir)
                if lgi.Gio.File.new_for_path(target):async_query_info("standard::name", "NONE") then
                    found_dirs[#found_dirs+1] = target
                end
            end
            if #found_dirs == 0 then goto continue end

            local context  = (groups[sub_dir].Context or ""):lower()
            local scale    = tonumber(groups[sub_dir].Scale or 1)
            local size     = tonumber(groups[sub_dir].Size)

            if     groups[sub_dir].Type == "Fixed"    then
                found_dirs.min_size = size
                found_dirs.max_size = size
            elseif groups[sub_dir].Type == "Scalable" then
                found_dirs.min_size = groups[sub_dir].MinSize and tonumber(groups[sub_dir].MinSize) or size
                found_dirs.max_size = groups[sub_dir].MaxSize and tonumber(groups[sub_dir].MaxSize) or size
            else
                local threshold = (groups[sub_dir].threshold and tonumber(groups[sub_dir].threshold) or 2)
                found_dirs.min_size = size - threshold
                found_dirs.max_size = size + threshold
            end

            themes[theme_index][context]        = themes[theme_index][context] or {}
            themes[theme_index][context][scale] = themes[theme_index][context][scale] or {}
            themes[theme_index][context][scale][#themes[theme_index][context][scale]+1] = found_dirs

            ::continue::
        end
    end

    theme_count = theme_count - 1
    if theme_count == 0 then
        -- キューの消化
        find_icon_ready = true
        for i = 1, #find_icon_queue do
            M.find_icon(find_icon_queue[i].name, find_icon_queue[i].size, find_icon_queue[i].context, find_icon_queue[i].callback)
            find_icon_queue[i] = nil
        end
    end
end

lgi.Gio.Async.start(parse_icon_theme)(options.icon_theme)

return M
