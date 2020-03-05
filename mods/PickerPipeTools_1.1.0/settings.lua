data:extend{
    {
        type = 'bool-setting',
        name = 'picker-find-orphans',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-b[find-orphans]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-tool-pipe-clamps',
        setting_type = 'startup',
        default_value = true,
        order = 'tool-pipe-cleaner'
    },
    {
        type = 'int-setting',
        name = 'picker-max-checked-pipes',
        setting_type = 'runtime-global',
        minimum_value = 100,
        maximum_value = 5000,
        default_value = 250,
        order = 'picker-b'
    },
    {
        type = 'int-setting',
        name = 'picker-max-distance-checked',
        setting_type = 'runtime-global',
        minimum_value = 50,
        maximum_value = 500,
        default_value = 80,
        order = 'picker-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-count-pipes-highlighted',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-b[find-orphans]-a'
    },
}
