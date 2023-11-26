---------------
-- Rosé Pine --
---------------

local name = "Rosé Pine"

local palette = {
    base           = "#191724",
    surface        = "#1f1d2e",
    overlay        = "#26233a",
    muted          = "#6e6a86",
    subtle         = "#908caa",
    text           = "#e0def4",
    love           = "#eb6f92",
    gold           = "#f6c177",
    rose           = "#ebbcba",
    pine           = "#31748f",
    foam           = "#9ccfd8",
    iris           = "#c4a7e7",
    highlight_low  = "#21202e",
    highlight_med  = "#403d52",
    highlight_high = "#524f67"
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
        bg              = palette.surface,
        item_bg_hover   = palette.overlay,
        separator_color = palette.highlight_high
    }
}

return { name = name, palette = palette, colors = colors }
