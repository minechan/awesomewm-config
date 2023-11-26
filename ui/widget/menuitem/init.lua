----------------------
-- メニューアイテム --
----------------------

local lgi       = require("lgi")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local M = {}

local theme = beautiful.menu

----------------------------
-- マスク用アイコンの更新 --
----------------------------

function M:update_icon_mask()
    local size = beautiful.menu.item_icon_size
    if not self._private.icon_mask then
        self._private.icon_mask = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, size, size)
    end
    local cr = lgi.cairo.Context(self._private.icon_mask)

    cr:set_operator(lgi.cairo.Operator.SOURCE)
    self._private.icon:draw(cr, 0, 0, size, size)
end

----------------
-- プロパティ --
----------------

for _, name in ipairs { "text", "icon", "symbolic_icon", "enabled" } do
    M["get_" .. name] = function (self) return self._private[name] end
end

function M:set_text(value)
    assert(type(value) == "string", "Invalid type.")

    self._private.text              = value
    self._private.pango_layout.text = value

    self:emit_signal("property::text")
    self:emit_signal("widget::layout_changed")
    self:emit_signal("widget::redraw_needed")
end

function M:set_icon(value)
    self._private.icon = value
    if value and self.symbolic_icon then
        self:update_icon_mask()
    else
        self._private.icon_mask = nil
    end

    self:emit_signal("property::icon")
    self:emit_signal("widget::layout_changed")
    self:emit_signal("widget::redraw_needed")
end

function M:set_symbolic_icon(value)
    assert(type(value) == "boolean", "Invalid type.")

    self._private.symbolic_icon = value
    if value and self._icon then
        self:update_icon_mask()
    else
        self._private.icon_mask = nil
    end

    self:emit_signal("property::symbolic_icon")
    self:emit_signal("widget::redraw_needed")
end

function M:set_enabled(value)
    assert(type(value) == "boolean", "Invalid type.")

    self._private.enabled = value

    self:emit_signal("property::enabled")
    self:emit_signal("widget::redraw_needed")
end

----------
-- 描画 --
----------

function M:fit(context, _, _)
    if self._private.dpi ~= context.dpi then
        self._private.dpi = context.dpi
        self._private.pango_context:set_resolution(context.dpi)
        self._private.pango_layout:context_changed()
    end

    self._private.pango_layout.width = -1
    self._private.text_size = select(2, self._private.pango_layout:get_pixel_extents())
    return self._private.text_size.width + theme.item_padding * (self.icon and 3 or 2) + (self.icon and theme.item_icon_size or 0), theme.item_height
end

function M:draw(context, cr, width, height)
    -- 文字列の省略
    local left = theme.item_padding + (self.icon and (theme.item_icon_size + theme.item_padding) or 0)
    self._private.pango_layout.width = (width - left - theme.item_padding) * lgi.Pango.SCALE

    local hover = gears.table.hasitem(self._private.parents, context.drawable)
    -- 背景
    if hover and self.enabled then
        cr:set_source(gears.color(theme.item_bg_hover))
        if theme.item_corner_radius > 0 then
            gears.shape.rounded_rect(cr, width, height, theme.item_corner_radius)
        else
            cr:rectangle(0, 0, width, height)
        end
        if theme.item_border_width >= 1 then
            cr:fill_preserve()
            cr:set_source(gears.color(theme.item_border_color))
            cr:set_line_width(theme.item_border_width)
            cr:stroke()
        else
            cr:fill()
        end
    end

    -- 文字列
    if self.enabled then
        if hover then
            cr:set_source(gears.color(theme.item_fg_hover or theme.item_fg or theme.fg))
        else
            cr:set_source(gears.color(theme.item_fg or theme.fg))
        end
    else
        cr:set_source(gears.color(theme.item_fg_disabled or theme.fg_disabled))
    end

    cr:move_to((self.icon and (theme.item_icon_size + theme.item_padding) or 0) + theme.item_padding, (theme.item_height - self._private.text_size.height) / 2)
    cr:show_layout(self._private.pango_layout)

    -- アイコン
    if self.icon then
        if self.symbolic_icon then
            -- cr:mask_surface(self._private.icon_mask, icon_x, icon_y)
            cr:mask_surface(self._private.icon_mask, theme.item_padding, (theme.item_height - theme.item_icon_size) / 2)
            cr:fill()
        else
            -- self.icon:draw(cr, icon_x, icon_y, theme.item_icon_size, theme.item_icon_size)
            self.icon:draw(cr, theme.item_padding, (theme.item_height - theme.item_icon_size) / 2, theme.item_icon_size, theme.item_icon_size)
        end
    end
end

--------------
-- シグナル --
--------------

local function mouse_enter(self, widget_info)
    self._private.parents[#self._private.parents+1] = widget_info.drawable
    print(tostring(widget_info.drawable))
    print(tostring(widget_info.drawable:get_widget()))

    self:emit_signal("widget::redraw_needed")
end

local function mouse_leave(self, widget_info)
    local i = gears.table.hasitem(self._private.parents, widget_info.drawable)
    if i then self._private.parents[i] = nil end

    self:emit_signal("widget::redraw_needed")
end

------------------------
-- インスタンスの生成 --
------------------------

local function new(text)
    local object = wibox.widget.base.make_widget(nil, nil, { enable_properties = true })
    gears.table.crush(object, M, true)

    -- 親ウィジェット
    object._private.parents = {}

    -- Pango
    object._private.dpi = -1
    object._private.pango_context = lgi.PangoCairo.font_map_get_default():create_context()
    -- object._private.pango_lauout  = lgi.Pango.Layout.new(object._private.pango_context)
    local result, message = pcall(lgi.Pango.Layout.new, object._private.pango_context)
    if result then
        object._private.pango_layout = message
        object._private.pango_layout:set_ellipsize(lgi.Pango.EllipsizeMode.END)
    else
        print(message)
    end

    object._private.pango_layout:set_font_description(beautiful.get_font(beautiful.menu.font))

    -- プロパティ
    if text then object.text = text end
    object.symbolic_icon = false
    object.enabled       = true

    -- イベント
    object:connect_signal("mouse::enter", mouse_enter)
    object:connect_signal("mouse::leave", mouse_leave)

    return object
end

local mt = {
    __call     = function (_, ...) return new(...) end,
    __tostring = function (_)      return gears.object.modulename() end
}

return setmetatable(M, mt)
