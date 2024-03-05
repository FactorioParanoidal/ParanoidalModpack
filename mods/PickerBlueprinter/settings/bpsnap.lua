data:extend{
    {
        type = 'bool-setting',
        name = 'picker-bp-snap',
        setting_type = 'startup',
        default_value = true,
        order = 'picker[startup]-edge-snap'
    }
}

data:extend{
    {
        type = 'bool-setting',
        name = 'picker-bp-snap-cardinal-center',
        setting_type = 'runtime-per-user',
        order = 'picker-f[3]',
        default_value = true
    }, {
        type = 'bool-setting',
        name = 'picker-bp-snap-horizontal-invert',
        setting_type = 'runtime-per-user',
        order = 'picker-f[4]',
        default_value = false
    }, {
        type = 'bool-setting',
        name = 'picker-bp-snap-vertical-invert',
        setting_type = 'runtime-per-user',
        order = 'picker-f[5]',
        default_value = false
    }
}
