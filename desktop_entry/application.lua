------------------------------
-- アプリケーションエントリ --
------------------------------

local gears = require("gears")

local M = {}

----------------
-- プロパティ --
----------------

function M:get_type() return "application" end

local properties = { exec = "string", terminal = "boolean", startup_wm_class = "string", actions = "table" }
for name, valid_type in pairs(properties) do
    M["get_" .. name] = function (self) return self._private[name] end
    M["set_" .. name] = function (self, value)
        assert(type(value) == valid_type or not value, "Invalid type.")
        self._private[name] = value
        self:emit_signal("property::" .. name)
    end
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(name, icon, categories, hidden, exec, terminal, startup_wm_class, actions)
    local object = require("desktop_entry.base")(name, icon, categories, hidden)
    gears.table.crush(object, M, true)

    object:set_exec            (exec)
    object:set_terminal        (terminal)
    object:set_startup_wm_class(startup_wm_class)
    object:set_actions         (actions)

    return object
end

local mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function (_) return gears.object.modulename() end
}

return setmetatable(M, mt)
