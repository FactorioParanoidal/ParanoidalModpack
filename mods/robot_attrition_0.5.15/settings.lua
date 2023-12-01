data:extend{
    {
        type = "double-setting",
        name = "robot-attrition-factor",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.001,
        maximum_value = 1000,
        order = "a",
    },
    {
        type = "string-setting",
        name = "robot-attrition-repair",
        setting_type = "startup",
        default_value = "Disabled",
        allowed_values = {"Disabled", "Repair75"},
        order = "b",
    },
}
