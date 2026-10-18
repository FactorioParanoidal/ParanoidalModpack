local config = require("shipwreck-config")

data:extend({
    {
        type = "string-setting",
        name = config.setting,
        setting_type = "startup",
        default_value = config.default_level,
        allowed_values = config.level_order,
        order = "a",
    },
})
