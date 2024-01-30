data:extend{
    {
        type = 'bool-setting',
        name = 'picker-tool-bp-updater',
        setting_type = 'startup',
        default_value = true,
        order = 'tool-bp-updater'
    }
}

data:extend{
    {
        type = 'string-setting',
        name = 'picker-bp-updater-version-increment',
        setting_type = 'runtime-per-user',
        order = 'picker-f[1]',
        default_value = 'auto',
        allowed_values = {'off', 'auto', 'on'}
    }, {
        type = 'string-setting',
        name = 'picker-bp-updater-alt-version-increment',
        setting_type = 'runtime-per-user',
        order = 'picker-f[2]',
        default_value = 'on',
        allowed_values = {'off', 'auto', 'on'}
    }
}
