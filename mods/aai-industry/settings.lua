data:extend{
    {
        type = "bool-setting",
        name = "start-with-basic-logistics",
        setting_type = "runtime-global",
        default_value = false,
        order = "a-b"
    },
    {
        type = "int-setting",
        name = "quick-start-science",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        order = "b"
    },
    {
        type = "bool-setting",
        name = "aai-fast-motor-crafting",
        setting_type = "startup",
        default_value = false,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "aai-wide-drill",
        setting_type = "startup",
        default_value = true,
        order = "d"
    },
    {
        type = "int-setting",
        name = "aai-burner-turbine-efficiency",
        setting_type = "startup",
        default_value = 85,
        minimum_value = 10,
        maximum_value = 100,
        order = "e"
    },
    {
        type = "int-setting",
        name = "aai-fuel-processor-efficiency",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 0,
        maximum_value = 100,
        order = "g"
    },
    {
        type = "bool-setting",
        name = "aai-stone-path",
        setting_type = "startup",
        default_value = true,
        order = "h"
    },
    {
        type = "bool-setting",
        name = "aai-fuel-processor",
        setting_type = "startup",
        default_value = true,
        order = "f"
    },
    {
        type = "bool-setting",
        name = "wide-flashlight",
        setting_type = "startup",
        default_value = true,
        order = "j"
    },
    {
        type = "bool-setting",
        name = "enhanced-nightvision",
        setting_type = "startup",
        default_value = true,
        order = "k"
    },
    {
        type = "string-setting",
        name = "night-lut-set",
        setting_type = "startup",
        default_value = "Dark",
        allowed_values = {"Dark", "Bright", "Vanilla"},
        order = "l"
    },
}

