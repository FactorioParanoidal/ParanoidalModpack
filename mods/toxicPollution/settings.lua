data:extend(
{
    {
        type = "int-setting",
        name = "armor-absorb-multiplier",
        setting_type = "startup",
        default_value = 100,
        maximum_value = 100000,
        minimum_value = 100
    },
    {
        type = "double-setting",
        name = "min-pollution-to-damage",
        setting_type = "startup",
        default_value = 20,
        maximum_value = 1000,
        minimum_value = 1
    },
    {
        type = "bool-setting",
        name = "auto-equip-armor",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "equip-respirator-when-respawn",
        setting_type = "runtime-per-user",
        default_value = false
    }
}
)