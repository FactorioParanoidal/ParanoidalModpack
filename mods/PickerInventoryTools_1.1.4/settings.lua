data:extend {
    {
        type = 'bool-setting',
        name = 'picker-auto-sort-inventory',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a'
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
