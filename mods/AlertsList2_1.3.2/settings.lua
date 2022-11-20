data:extend(
    {
        {
            type = "string-setting",
            name = "alerts-list-display-mode",
            setting_type = "runtime-per-user",
            default_value = "alerts-list-display-mode-icon-only",
            allowed_values = {
                -- show only icon
                "alerts-list-display-mode-icon-only",
                -- show both icon and notification text
                "alerts-list-display-mode-icon-and-text"
                -- TODO: nice idea to implement LATER ON
                -- show both text and circuit condition that triggered it with both values
                -- "alerts-list-display-mode-condition-and-text"
            },
            order = "aa"
        },
        {
            type = "bool-setting",
            name = "alerts-list-show-percentage",
            setting_type = "runtime-per-user",
            default_value = false,
            order = "ab"
        },
        {
            type = "int-setting",
            name = "alerts-list-columns-for-compact-mode",
            setting_type = "runtime-per-user",
            default_value = 4,
            minimum_value = 1,
            maximum_value = 64,
            order = "ac"
        },
        {
            type = "int-setting",
            name = "alerts-list-refresh-rate",
            setting_type = "startup",
            default_value = 60,
            minimum_value = 1,
            maximum_value = 6000,
            order = "ad"
        }
    }
)
