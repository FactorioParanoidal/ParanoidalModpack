data:extend {
    {
        name = 'dolly-save-entity',
        setting_type = 'runtime-per-user',
        type = 'int-setting',
        default_value = 4,
        minimum_value = 0,
        maximum_value = 60,
    },
    {
        name = 'dolly-ignore-collisions',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = false
    },
    {
        name = 'dolly-allow-ignore-collisions',
        setting_type = 'runtime-global',
        type = 'bool-setting',
        default_value = false
    }
}
