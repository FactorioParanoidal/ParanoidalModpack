local settings_list = {
    {
        type = "int-setting",
        name = "valves-pump-speed",
        setting_type = "startup",
        order = "b[pump-speed]",
        minimum_value = 60,
        maximum_value = 24000,
        default_value = 1200,
    },
    {
        type = "string-setting",
        name = "valves-graphics",
        setting_type = "startup",
        order = "c[graphics]",
        allowed_values = { "reskins", "classic", "reskins-bobs" },
        default_value = "reskins",
        -- Keep saved choices valid; a look whose resource mod is absent falls back to classic.
        hidden = mods["reskins-angels"] == nil and mods["reskins-bobs"] == nil,
    },
}

for _, valve in ipairs(require("config")) do
    if valve.threshold then
        local name = "valves-default-threshold-" .. valve.type
        settings_list[#settings_list + 1] = {
            type = "int-setting",
            name = name,
            setting_type = "startup",
            order = "a[" .. name .. "]",
            minimum_value = 0,
            maximum_value = 100,
            default_value = valve.threshold,
        }
    end
end

data:extend(settings_list)
