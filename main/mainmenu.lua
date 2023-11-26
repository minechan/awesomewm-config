--------------------
-- メインメニュー --
--------------------

local gears         = require("gears")
local desktop_entry = require("desktop_entry")

local categories = {
    { name = "AudioVideo" , text = "マルチメディア", icon = "multimedia" , entries = {} },
    { name = "Development", text = "開発"          , icon = "entries"    , entries = {} },
    { name = "Education"  , text = "教育"          , icon = "education"  , entries = {} },
    { name = "Game"       , text = "ゲーム"        , icon = "games"      , entries = {} },
    { name = "Network"    , text = "インターネット", icon = "internet"   , entries = {} },
    { name = "Office"     , text = "オフィス"      , icon = "office"     , entries = {} },
    { name = "System"     , text = "システム"      , icon = nil          , entries = {} },
    { name = "Utility"    , text = "アクセサリ"    , icon = "accessories", entries = {} }
}
local settings_entries = {}
local default_entries  = {}
local menu_table       = {}

------------------------
-- カテゴリごとに分類 --
------------------------

-- カテゴリの並び替え
table.sort(categories, function (a, b) return a.text < b.text end)

-- エントリをカテゴリごとに分類
for _, entry in pairs(desktop_entry.get_entries()) do
    if entry.hidden then goto continue end

    local found = false
    for _, category in ipairs(entry.categories) do
        for _, target in ipairs(categories) do
            if target.name == category then
                target.entries[#target.entries+1] = entry
                found = true
            end
        end
        if category == "Settings" then
            settings_entries[#settings_entries+1] = entry
            found = true
        end
    end
    if not found then default_entries[#default_entries+1] = entry end

    ::continue::
end

----------------------------
-- メニューテーブルの生成 --
----------------------------

local function generate_entry_items(entries)
    local result = {}
    for _, entry in ipairs(entries) do
        result[#result+1] = {
            entry.name,
            type        = "action",
            icon        = entry.icon,
            icon_source = entry.icon and "icon",
            exec        = (entry.terminal and "kitty -e " or "") .. entry.exec
        }
    end
    table.sort(result, function (a, b) return a[1] < b[1] end)
    return result
end

if #settings_entries >= 1 then
    menu_table = {
        {
            "設定",
            type        = "submenu",
            icon        = "preferences-other-symbolic",
            icon_source = "icon",
            submenu     = generate_entry_items(settings_entries)
        },
        { type = "separator" }
    }
end

for _, category in ipairs(categories) do
    if #category.entries == 0 then goto continue end

    menu_table[#menu_table+1] = {
        category.text,
        type        = "submenu",
        icon        = category.icon and ("applications-" .. category.icon .. "-symbolic"),
        icon_source = category.icon and "icon",
        submenu     = generate_entry_items(category.entries)
    }

    ::continue::
end

print_table(menu_table)
