data:extend {
    {
        type = "bool-setting",
        name = "fh-set-filter-on-inserter",
        setting_type = "runtime-global",
        default_value = true,
        order = "a",
    },
    {
        type = "string-setting",
        name = "fh-default-item-on-splitter",
        allow_blank = true,
        auto_trim = true,
        setting_type = "runtime-global",
        default_value = "deconstruction-planner,no-item",
        order = "b",
    },
    {
        type = "bool-setting",
        name = "fh-add-fuel-items",
        setting_type = "runtime-global",
        default_value = true,
        order = "c",
    },
    {
        type = "bool-setting",
        name = "fh-show-only-unlocked-qualities",
        setting_type = "runtime-global",
        default_value = false,
        order = "d",
    },
}
