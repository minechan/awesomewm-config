----------------------
-- 画像オブジェクト --
----------------------

local lgi   = require("lgi")
local gears = require("gears")

local M = {}

-- キャッシュ
local cache = {}

----------------
-- プロパティ --
----------------

for _, name in ipairs { "image", "type", "width", "height" } do
    M["set_" .. name] = function (_) error("Property " .. name .. " is read only.") end
end

function M:get_image() return self._private.image end

function M:get_type()
    local types = { RsvgHandle = "rsvg_handle", GdkPixbuf = "gdk_pixbuf" }
    return types[tostring(self.image):match("%((.+)%)$")]
end

function M:get_width()
    if self.type == "rsvg_handle" then
        return self._private.dimensions.width
    else
        return self.image:get_width()
    end
end

function M:get_height()
    if self.type == "rsvg_handle" then
        return self._private.dimensions.height
    else
        return self.image:get_height()
    end
end

----------------
-- 画像の描画 --
----------------

function M:draw(cr, x, y, width, height)
    if self.type == "rsvg_handle" then
        local rect = lgi.Rsvg.Rectangle()
        rect.x      = x
        rect.y      = y
        rect.width  = width
        rect.height = height

        self.image:render_document(cr, rect)
    else
        local width_scale  = width  / self.width
        local height_scale = height / self.height

        cr:save()
        cr:scale(width_scale, height_scale)
        lgi.Gdk.cairo_set_source_pixbuf(cr, self.image, x / width_scale, y / height_scale)
        cr:paint()
        cr:restore()
    end
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(path)
    assert(type(path) == "string", "Invalid type.")

    local object = gears.object { enable_properties = true }
    gears.table.crush(object, M, true)
    object._private = { path = path }

    -- 画像の読み込み
    if cache[path] then
        object._private.image = cache[path]
    else
        if path:find("%.svg$") then
            object._private.image      = lgi.Rsvg.Handle.new_from_file(path)
            object._private.dimensions = object._private.image:get_dimensions()
        else
            object._private.image = lgi.GdkPixbuf.Pixbuf.new_from_file(path)
        end
        cache[path] = object._private.image
    end

    return object
end

local mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function (_)      return gears.object.modulename() end
}

return setmetatable(M, mt)
