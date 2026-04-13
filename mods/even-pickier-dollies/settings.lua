--
-- settings definitions
--

data:extend {
    {
        name = "dolly-save-entity",
        setting_type = "runtime-per-user",
        type = "int-setting",
        default_value = 4,
        minimum_value = 0,
        maximum_value = 60,
        order = 'aa',
    },
    {
        name = "dolly-clear-entity",
        setting_type = "runtime-per-user",
        type = "bool-setting",
        default_value = false,
        order = 'ab',
    },
    {
        name = "dolly-ignore-collisions",
        setting_type = "runtime-per-user",
        type = "bool-setting",
        default_value = false,
        order = 'ac',
    },
    {
        name = "dolly-allow-ignore-collisions",
        setting_type = "runtime-global",
        type = "bool-setting",
        default_value = false,
    },
    {
        name = "dolly-debug",
        setting_type = 'runtime-per-user',
        type = "bool-setting",
        default_value = false,
        order = 'ba',
    },
    {
        name = "dolly-remote-move",
        setting_type = 'startup',
        type = "bool-setting",
        default_value = false,
        order = 'ca',
    },
    {
        name = "dolly-ghost-move",
        setting_type = 'startup',
        type = "bool-setting",
        default_value = true,
        order = 'cb',
    },
    {
        name = "dolly-biter-move",
        setting_type = 'startup',
        type = "bool-setting",
        default_value = false,
        order = 'cc',
    },
    {
        name = "dolly-item-destroy",
        setting_type = 'startup',
        type = "bool-setting",
        default_value = false,
        order = 'cd',
    },
    {
        name = "dolly-transporter-mode",
        setting_type = 'startup',
        type = "bool-setting",
        default_value = false,
        order = 'ce',
    },
}
