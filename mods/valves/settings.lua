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
        allowed_values = { "reskins", "classic" },
        default_value = "reskins",
        -- Without reskins-angels only the classic look exists (data.lua falls back to it).
        hidden = mods["reskins-angels"] == nil,
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
