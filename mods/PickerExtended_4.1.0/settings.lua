require('settings/tools')
require('settings/playeroptions')

data:extend {
    {
        type = 'bool-setting',
        name = 'picker-transfer-settings-death',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-transfer-settings'
    },
    {
        type = 'bool-setting',
        name = 'picker-hide-minimap',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-b[minimap]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-allow-multiple-craft',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-b[multiplecraft]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-search-light',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-b[lights]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-alt-mode-default',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-d[alt-mode]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-camera-gui',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-f[screenshot]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-camera-aa',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-f[screenshot]-b'
    },
    {
        type = 'double-setting',
        name = 'picker-camera-zoom',
        setting_type = 'runtime-per-user',
        default_value = 1,
        minimum_value = 0,
        order = 'picker-f[screenshot]-c'
    },
    {
        type = 'bool-setting',
        name = 'picker-remember-planner',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-g[planner]-a'
    },
    {
        name = 'picker-use-groups',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        name = 'picker-use-subgroups',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        name = 'picker-revive-selected-ghosts-entity',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        name = 'picker-revive-selected-ghosts-tile',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    }
}
