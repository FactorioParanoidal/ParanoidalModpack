data:extend({
    {
        type = "int-setting",
        name = "Interval",
        setting_type = "startup",
        default_value = 60,
        minimum_value = 1,
        order = "Interval"
    },
    {
        type = "int-setting",
        name = "TurbineSteam",
        setting_type = "startup",
        default_value = 200,
        minimum_value = 100,
        order = "TurbineSteam"
    },
    {
        type = "string-setting",
        name = "EasyWindTurbine",
        setting_type = "startup",
        default_value = "Upgrading",
        allowed_values = {"Upgrading", "Crafting"},
        order = "Upgrades"
    },
})