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
    -- Map settings of a new game: read once when the map starts.
    {type = "bool-setting", name = "bnl-start-professions", setting_type = "runtime-global", default_value = true, order = "b-a"},
    {type = "bool-setting", name = "bnl-start-pause", setting_type = "runtime-global", default_value = true, order = "b-b"},
    {type = "bool-setting", name = "bnl-start-intro", setting_type = "runtime-global", default_value = true, order = "b-c"},
    {type = "bool-setting", name = "bnl-start-falling-debris", setting_type = "runtime-global", default_value = true, order = "b-d"},
    {type = "bool-setting", name = "bnl-start-wreck-fires", setting_type = "runtime-global", default_value = true, order = "b-e"},
    {type = "bool-setting", name = "bnl-start-debris-trail", setting_type = "runtime-global", default_value = true, order = "b-f"},
    {type = "bool-setting", name = "bnl-start-supply-pods", setting_type = "runtime-global", default_value = true, order = "b-g"},
    {
        type = "string-setting",
        name = "bnl-start-anomaly",
        setting_type = "runtime-global",
        default_value = "random",
        allowed_values = {"random", "none", "long-night", "magnetic-storm", "rich-vein", "quiet-planet", "dust-storms"},
        order = "b-h",
    },
    {type = "bool-setting", name = "bnl-start-mp-capsules", setting_type = "runtime-global", default_value = true, order = "b-i"},
    -- Per player: the goals of the start in the objectives window (scripts/goals.lua).
    {type = "bool-setting", name = "bnl-goals", setting_type = "runtime-per-user", default_value = true, order = "c-a"},
})
