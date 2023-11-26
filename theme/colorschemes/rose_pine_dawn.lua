--------------------
-- Rosé Pine Dawn --
--------------------

local name = "Rosé Pine Dawn"

local palette = {
    base           = "#faf4ed",
    surface        = "#fffaf3",
    overlay        = "#f2e9e1",
    muted          = "#9893a5",
    subtle         = "#797593",
    text           = "#575279",
    love           = "#b4637a",
    gold           = "#ea9d34",
    rose           = "#d7827e",
    pine           = "#286983",
    foam           = "#56949f",
    iris           = "#907aa9",
    highlight_low  = "#f4ede8",
    highlight_med  = "#dfdad9",
    highlight_high = "#cecacd"
}

local colors = {
    general = {
        fg           = palette.text,
        fg_disabled  = palette.muted,
        bg           = palette.base,
        border_color = "#00000040",
        bevel_color  = "#ffffff80"
    },
    titlebar = {
        fg               = palette.subtle,
        fg_focus         = palette.text,
        bg               = palette.base,
        bg_focus         = palette.surface,
        border_color     = palette.highlight_high,
        button_bg_hover  = palette.overlay,
        button_bg_active = palette.highlight_high
    },
    menu = {
        bg                = palette.surface,
        item_bg_hover     = palette.overlay,
        item_border_color = palette.highlight_high,
        separator_color   = palette.highlight_high
    }
}

return { name = name, palette = palette, colors = colors }
