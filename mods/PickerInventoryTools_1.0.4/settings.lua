data:extend {
    {
        type = 'bool-setting',
        name = 'picker-auto-sort-inventory',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a'
    },
    {
        name = 'picker-fix-trash-filters',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        name = 'picker-auto-stock',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        type = 'bool-setting',
        name = 'picker-item-count',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-b[itemcount]-a'
    },
    {
        name = 'picker-copy-between-surfaces',
        setting_type = 'runtime-global',
        type = 'bool-setting',
        default_value = false
    }
}

require('settings/zapper')
require('settings/auto-deconstruct')
