local default_threshold_settings = {
    overflow = 80,
    top_up = 50,
}

-- This still uses my old way of defining valve types to maintain
-- player's previous settings.
for _, my_valve_type in pairs({"overflow", "top_up"}) do
    local default_value = default_threshold_settings[my_valve_type]
    assert(default_value, "unexpected condition for valve type "..my_valve_type)
    local setting_name = "valves-default-threshold-"..my_valve_type
    data:extend({
        {
            type = "int-setting",
            name = setting_name,
            setting_type = "startup",
            order = "a["..setting_name.."]",
            minimum_value = 0,
            maximum_value = 100,
            default_value = default_value,
        },
    })
end

data:extend({
    {
        type = "bool-setting",
        name = "valves-disable-py-migration",
        setting_type = "startup",
        order = "z[migration]-a[py]",
        default_value = false,
        hidden = mods["pyindustry"] == nil
    },
})