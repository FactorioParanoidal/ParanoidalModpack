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
        },
        {
            type = "bool-setting",
            name = "additional-paste-settings-paste-to-belt-enabled",
            setting_type = "runtime-per-user",
            default_value = false,
            order = "eb"
        },
        {
            type = "bool-setting",
            name = "additional-paste-settings-paste-clear-inserter-filter-on-paste-over",
            setting_type = "runtime-per-user",
            default_value = true,
            order = "ec"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-station_name_load",
            setting_type = "runtime-global",
            allow_blank = false,
            default_value = "Load __1__ (__2__)",
            order = "za"
        },
        {
            type = "string-setting",
            name = "additional-paste-settings-station_name_unload",
            setting_type = "runtime-global",
            allow_blank = false,
            default_value = "Unload __1__ (__2__)",
            order = "zb"
        },
        {
            type = "bool-setting",
            name = "additional-paste-settings-use_flib",
            setting_type = "runtime-global",
            default_value = false,
            order = "zc"
        },
    }
)

if mods["space-exploration-postprocess"] then
    data:extend({
        {
            type = "string-setting",
            name = "additional-paste-settings-se-rocket-landing-pad-name",
            setting_type = "runtime-global",
            allow_blank = false,
            default_value = "__1__ (__2__)",
            order = "zc"
        },
    })
end