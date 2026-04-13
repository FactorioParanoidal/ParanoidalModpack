-- taken from Picker Extended
--require('settings/tools')
require('settings/playeroptions')
require('settings/searchlight')
require('settings/reviver')
require('settings/itemcount')
require('settings/planners')

-- taken from Picker Inventory Tools
require('settings/zapper')
require('settings/copychest')
require('settings/chestlimit')
require('settings/inventorysort')

-- taken from Picker Belt Tools
require('settings/autocircuit')

--[[
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
        name = 'picker-allow-multiple-craft',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-b[multiplecraft]-a'
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
    }
}
]]--