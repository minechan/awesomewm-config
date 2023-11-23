----------------------------
-- アプリケーションクラス --
----------------------------

local lgi           = require("lgi")
local gears         = require("gears")
local utilities     = require("utilities")
local desktop_entry = require("desktop_entry")

local M = {}

local applications = {}

----------------
-- プロパティ --
----------------

function M:get_name() return self._private.name end
function M:set_name(value)
    assert(type(value) == "string", "Invalid type.")
    self._private.name = value
    self:emit_signal("property::name")
end

function M:get_icon() return self._private.icon end
function M:set_icon(value)
    assert(type(value) == "string" or not value, "Invalid type.")
    self._private.icon = value
    self:emit_signal("property::icon")
end

function M:get_exec() return self._private.exec end
function M:set_exec(value)
    assert(type(value) == "string" or not value, "Invalid type.")
    self._private.exec = value
    self:emit_signal("property::exec")

    -- リンク元の取得
    if value then
        local full_path = utilities.environment.find_full_path(self._private.exec:match("^([^%s]+)"))
        local real_path = lgi.Gio.File.new_for_path(full_path):query_info("standard::symlink-target", "NONE"):get_symlink_target()
        self._private.real_path = real_path and utilities.environment.find_full_path(real_path) or full_path
    else
        self._private.real_path = nil
    end
end

function M:get_real_path()  return self._private.real_path end
function M:set_real_path(_) error("Property real_path is read only.") end

for property, valid_type in pairs { actions = "table", wm_class = "string" } do
    M["get_" .. property] = function (self) return self._private[property] end
    M["set_" .. property] = function (self, value)
        assert(type(value) == valid_type or not value, "Invalid type.")
        self._private[property] = value
        self:emit_signal("property::" .. property)
    end
end

------------------
-- クライアント --
------------------

function M:get_clients() return self._private.clients end

function M:add_client(c)
    self._private.clients[#self._private.clients+1] = c
end

function M:remove_client(c)
    for i = 1, #self._private.clients do
        if self._private.clients[i] == c then
            self._private.clients[i] = nil
            break
        end
    end
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(name, icon, exec, actions, wm_class)
    local object = gears.object { enable_properties = true }
    gears.table.crush(object, M, true)

    object._private = { clients = {} }
    object:set_name     (name)
    object:set_icon     (icon)
    object:set_exec     (exec)
    object:set_actions  (actions)
    object:set_wm_class (wm_class)

    return object
end

------------------------------
-- アプリケーションのリスト --
------------------------------

for name, entry in pairs(desktop_entry.get_entries()) do
    if entry.type == "application" then
        applications[name] = new(entry.name, entry.icon, entry.exec, entry.actions, entry.startup_wm_class)
    end
end

function M.get_applications() return applications end

local mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function(_) return gears.object.modulename() end
}

return setmetatable(M, mt)
