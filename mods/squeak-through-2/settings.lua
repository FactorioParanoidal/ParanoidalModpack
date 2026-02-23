local const = require("const")

for group in pairs(const.groups) do
    data:extend{{
        type = "bool-setting",
        name = "sqt-disable-modify-" .. group,
        setting_type = "startup",
        default_value = false,
        localised_name = {"sqt-setting-name.disable-setting", {"sqt-setting-name." .. group}},
        localised_description = {"sqt-setting-description." .. group},
        order = "a"
    }}
end

data.raw["bool-setting"]["sqt-disable-modify-misc"].order = "aa"

data:extend{{
    type = "string-setting",
    name = "sqt-blacklist-types",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    order = "ba",
}, {
    type = "string-setting",
    name = "sqt-blacklist-names",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    order = "bb",
}, {
    type = "bool-setting",
    name = "sqt-remove-collision",
    setting_type = "startup",
    default_value = false,
    order = "ca",
}, {
    type = "string-setting",
    name = "sqt-remove-collision-types",
    setting_type = "startup",
    default_value = "tree",
    allow_blank = true,
    order = "cb",
}, {
    type = "string-setting",
    name = "sqt-remove-collision-names",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    order = "cc",
}}