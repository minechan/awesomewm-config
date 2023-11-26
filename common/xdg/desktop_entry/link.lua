--------------------
-- リンクエントリ --
--------------------

local gears = require("gears")

local M     = {}
local super = require("common.xdg.desktop_entry.base")

----------------
-- プロパティ --
----------------

function M:get_type() return "link" end

function M:get_url() return self._private.url end
function M:set_url(value)
    assert(type(value) == "string", "Invalid type.")
    self._private.url = value
    self:emit_signal("property::url")
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(name, icon, categories, hidden, url)
    local object = super(name, icon, categories, hidden)
    gears.table.crush(object, M, true)

    object:set_url(url)
    return object
end

local mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function (_) return gears.object.modulename() end
}

return setmetatable(M, mt)
