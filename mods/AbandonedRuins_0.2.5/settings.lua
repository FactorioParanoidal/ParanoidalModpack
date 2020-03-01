data:extend({
        {
            type = "int-setting",
            name = "ruins-min-distance-from-spawn",
            setting_type = "runtime-global",
            default_value = 200,
            order = "a",
        },
        {
            type = "double-setting",
            name = "ruins-large-ruin-chance",
            setting_type = "runtime-global",
            default_value = 0.0005,
            minimum_value = 0.0,
            maximum_value = 1.0,
            order = "d",
        },
        {
            type = "double-setting",
            name = "ruins-medium-ruin-chance",
            setting_type = "runtime-global",
            default_value = 0.002,
            minimum_value = 0.0,
            maximum_value = 1.0,
            order = "c",
        },
        {
            type = "double-setting",
            name = "ruins-small-ruin-chance",
            setting_type = "runtime-global",
            default_value = 0.005,
            minimum_value = 0.0,
            maximum_value = 1.0,
            order = "b",
        }
})
