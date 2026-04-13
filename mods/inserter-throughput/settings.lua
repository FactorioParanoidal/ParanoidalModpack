data:extend{
    {
        type = 'bool-setting',
        name = 'inserter-throughput-enabled',
        setting_type = 'runtime-per-user',
        default_value = true
    },
    {
        type = 'bool-setting',
        name = 'inserter-throughput-show-toggle',
        setting_type = 'runtime-per-user',
        default_value = true
    },
    {
        type = 'int-setting',
        name = 'inserter-throughput-rounding-precision',
        setting_type = 'runtime-per-user',
        default_value = 2,
        minimum_value = 0
    },
}