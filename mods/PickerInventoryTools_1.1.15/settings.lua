data:extend {
    {
        type = 'bool-setting',
        name = 'picker-auto-sort-inventory',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a'
    },
    {
        type = 'bool-setting',
        name = 'picker-filter-requests',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'ab'
    },
    {
        type = 'bool-setting',
        name = 'picker-filter-filters',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'ac'
    },
        {
        type = 'bool-setting',
        name = 'picker-use-bar-limit',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'ad'
    },
    {
        name = 'picker-item-count',
        type = 'bool-setting',
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

require('settings/auto-deconstruct')
require('settings/cursor-carousel')
require('settings/item-zapper')
require('settings/packing-tape')
require('settings/toggle-groups')
require('settings/toggle-minimap')
