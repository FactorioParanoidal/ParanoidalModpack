data:extend{
    {
        type = "int-setting",
        name = "milestones_check_frequency",
        setting_type = "runtime-global",
        minimum_value = 1,
        default_value = 60
    },
    {
        type = "string-setting",
        name = "milestones_initial_preset",
        setting_type = "runtime-global",
        allow_blank = true,
        default_value = "",
        auto_trim = true
    },
    {
        type = "bool-setting",
        name = "milestones_compact_list",
        setting_type = "runtime-per-user",
        default_value = false,
    },
    {
        type = "bool-setting",
        name = "milestones_list_by_group",
        setting_type = "runtime-per-user",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = "milestones_show_estimations",
        setting_type = "runtime-per-user",
        default_value = true,
    }
}
