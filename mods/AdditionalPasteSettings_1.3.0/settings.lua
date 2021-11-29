data:extend(
    {
        {
            type = "string-setting",
            name = "additional-paste-settings-options-requester-multiplier-type",
            setting_type = "runtime-per-user",
            allow_blank = false,
            allowed_values = {
                "additional-paste-settings-per-stack-size",
                "additional-paste-settings-per-recipe-size",
                "additional-paste-settings-per-time-size"
            },
            default_value = "additional-paste-settings-per-recipe-size",
            order = "ba"
        },
        {
            type = "double-setting",
            name = "additional-paste-settings-options-requester-multiplier-value",
            setting_type = "runtime-per-user",
            minimum_value = 0,
            default_value = 1,
            order = "bb"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-options-inserter-multiplier-type",
            setting_type = "runtime-per-user",
            allow_blank = false,
            allowed_values = {
                "additional-paste-settings-per-stack-size",
                "additional-paste-settings-per-recipe-size",
                "additional-paste-settings-per-time-size"
            },
            default_value = "additional-paste-settings-per-recipe-size",
            order = "ca"
        },
        {
            type = "double-setting",
            name = "additional-paste-settings-options-inserter-multiplier-value",
            setting_type = "runtime-per-user",
            minimum_value = 0,
            default_value = 1,
            order = "cb"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-options-transport_belt-multiplier-type",
            setting_type = "runtime-per-user",
            allow_blank = false,
            allowed_values = {
                "additional-paste-settings-per-stack-size",
                "additional-paste-settings-per-recipe-size",
                "additional-paste-settings-per-time-size"
            },
            default_value = "additional-paste-settings-per-recipe-size",
            order = "cc"
        },
        {
            type = "double-setting",
            name = "additional-paste-settings-options-transport_belt-multiplier-value",
            setting_type = "runtime-per-user",
            minimum_value = 0,
            default_value = 1,
            order = "cd"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-options-combinator-multiplier-type",
            setting_type = "runtime-per-user",
            allow_blank = false,
            allowed_values = {
                "additional-paste-settings-per-stack-size",
                "additional-paste-settings-per-recipe-size",
                "additional-paste-settings-per-time-size"
            },
            default_value = "additional-paste-settings-per-recipe-size",
            order = "da"
        },
        {
            type = "double-setting",
            name = "additional-paste-settings-options-combinator-multiplier-value",
            setting_type = "runtime-per-user",
            minimum_value = 0,
            default_value = 1,
            order = "db"
        },
        {
            type = "bool-setting",
            name = "additional-paste-settings-options-sumup",
            setting_type = "runtime-per-user",
            default_value = false,
            order = "a"
        },
        {
            type = "bool-setting",
            name = "additional-paste-settings-options-invert-buffer",
            setting_type = "runtime-per-user",
            default_value = false,
            order = "ea"
        },
        {
            type = "double-setting",
            name = "additional-paste-settings-options-invert-buffer-multiplier-value",
            setting_type = "runtime-per-user",
            minimum_value = 0,
            default_value = 1,
            order = "eb"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-options-comparator-value",
            setting_type = "runtime-per-user",
            allow_blank = false,
            allowed_values = {
                ">",
                "<",
                "=",
                ">=",
                "<=",
                "!="
            },
            default_value = "<",
            order = "fa"
        }
    }
)
