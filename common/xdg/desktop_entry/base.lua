--------------------------
-- エントリオブジェクト --
--------------------------

local gears = require("gears")

local M = {}

----------------
-- プロパティ --
----------------

function M:set_type(_) error("Property type is read only.") end

local properties = { name = "string", icon = "string", categories = "table", hidden = "boolean" }
for name, valid_type in pairs(properties) do
    M["get_" .. name] = function (self) return self._private[name] end
    M["set_" .. name] = function (self, value)
        if name == "name" then
            assert(type(value) == "string", "Invalid type.")
        else
            assert(type(value) == valid_type or not value, "Invalid type.")
        end
        self._private[name] = value
        self:emit_signal("property::" .. name)
    end
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(name, icon, categories, hidden)
    local object = gears.object { enable_properties = true }
    gears.table.crush(object, M, true)

    object._private = { mt = {} }
    object:set_name      (name)
    object:set_icon      (icon)
    object:set_categories(categories)
    object:set_hidden    (hidden)

    return object
end

M.mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function (_) return gears.object.modulename() end
}

return setmetatable(M, M.mt)
