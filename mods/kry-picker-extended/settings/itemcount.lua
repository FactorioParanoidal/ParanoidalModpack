-- disable Item Count functionality if yemtositemcount is detected
-- (it works better than this one, specifically with belt brush mod)
if not mods["yemtositemcount"] then
data:extend {
    {
        name = 'picker-item-count',
        type = 'bool-setting',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a[Picker]-d[ItemCount]-a'
    },
}
end