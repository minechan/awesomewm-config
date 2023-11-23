-------------------
-- Awesomeの設定 --
-------------------

-- デバッグ用
function print_table(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. key .. ":")
            print_table(value, indent .. "    ")
        else
            print(indent .. key .. ": " .. tostring(value))
        end
    end
end

options = {
    -- アイコンテーマ
    icon_theme  = "Colloid-teal-nord-light",
    icon_scale  = 2,
    -- 固定されたアプリケーション
    pinned_apps = { "firefox", "kitty" }
}
