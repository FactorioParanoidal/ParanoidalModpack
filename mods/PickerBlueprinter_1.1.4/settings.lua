data:extend {
    {
        type = 'bool-setting',
        name = 'picker-bp-snap',
        setting_type = 'startup',
        default_value = true,
        order = 'picker[startup]-edge-snap'
    },
    {
        type = 'bool-setting',
        name = 'picker-tool-bp-updater',
        setting_type = 'startup',
        default_value = true,
        order = 'tool-bp-updater'
    }
}

data:extend {
    {
        type = 'bool-setting',
        name = 'picker-simple-blueprint',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-a[blueprint]-a'
    },
    {
        type = 'string-setting',
        name = 'picker-bp-updater-version-increment',
        setting_type = 'runtime-per-user',
        order = 'picker-f[1]',
        default_value = 'auto',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = 'string-setting',
        name = 'picker-bp-updater-alt-version-increment',
        setting_type = 'runtime-per-user',
        order = 'picker-f[2]',
        default_value = 'on',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = 'bool-setting',
        name = 'picker-bp-snap-cardinal-center',
        setting_type = 'runtime-per-user',
        order = 'picker-f[3]',
        default_value = true
    },
    {
        type = 'bool-setting',
        name = 'picker-bp-snap-horizontal-invert',
        setting_type = 'runtime-per-user',
        order = 'picker-f[4]',
        default_value = false
    },
    {
        type = 'bool-setting',
        name = 'picker-bp-snap-vertical-invert',
        setting_type = 'runtime-per-user',
        order = 'picker-f[5]',
        default_value = false
    }
}
