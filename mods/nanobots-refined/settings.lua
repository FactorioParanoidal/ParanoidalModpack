data:extend{
    {
        type = "bool-setting",
        name = "nanobots-auto",
        setting_type = "startup",
        default_value = false,
        order = "nanobots-aa[auto-bots-roll-out]"
    },
    {
        type = "bool-setting",
        name = "nanobots-nano-build-tiles",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "nanobots-ba[build-tiles]"
    },
    {
        type = "bool-setting",
        name = "nanobots-levelers-destroy-targeted-nature",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "nanobots-ca[tree-rock-targeting]"
    },
    {
        type = "bool-setting",
        name = "nanobots-levelers-only-targeted-cliffs",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "nanobots-cb[cliff-targeting]"
    },
    {
        type = "bool-setting",
        name = "nanobots-levelers-place-landfill",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "nanobots-cc[lake-filling]"
    },
    {
        type = "bool-setting",
        name = "nanobots-disable-nano-explosives",
        setting_type = "startup",
        default_value = true,
        order = "nanobots-da[disable-cheaty-bombs]"
    },
    {
        type = "string-setting",
        name = "nanobots-recipe-version",
        setting_type = "startup",
        allowed_values = {"legacy", "standard", "basic"},
        default_value = "standard",
        order = "nanobots-db[recipe-variants]"
    },
    {
        type = "int-setting",
        name = "nanobots-cell-queue-rate",
        setting_type = "runtime-global",
        default_value = 5,
        maximum_value = 60*60,
        minimum_value = 1,
        order = "nanobots-fa[cell-queue-rate]"
    },
    {
        type = "int-setting",
        name = "nanobots-free-bots-per",
        setting_type = "runtime-global",
        default_value = 50,
        maximum_value = 100,
        minimum_value = 1,
        order = "nanobots-fb[free-bots-per]"
    },
    {
        type = "bool-setting",
        name = "nanobots-mute-launcher",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "nanobots-ia[interface-mute]"
    }
}
