require('lib.init')

local const = require('lib.constants')

data:extend({
    {
        type = 'bool-setting',
        name = const.settings.loader_snapping,
        order = 'aa',
        setting_type = 'runtime-global',
        default_value = true,
    },
    {
        -- Debug mode (framework dependency)
        type = "bool-setting",
        name = Framework.PREFIX .. 'debug-mode',
        order = "az",
        setting_type = "startup",
        default_value = false,
    },
    {
        type = 'bool-setting',
        name = const.settings.chute_loader,
        order = 'aa',
        setting_type = 'startup',
        default_value = false,
    },
    {
        type = 'bool-setting',
        name = const.settings.double_recipes,
        order = 'ab',
        setting_type = 'startup',
        default_value = false,
    },
    {
        type = 'bool-setting',
        name = const.settings.no_power,
        order = 'ac',
        setting_type = 'startup',
        default_value = false,
    },
    {
        type = 'bool-setting',
        name = const.settings.sanitize_loaders,
        order = 'ax',
        setting_type = 'startup',
        default_value = false,
    },
    {
        type = 'bool-setting',
        name = const.settings.migrate_loaders,
        order = 'ay',
        setting_type = 'startup',
        default_value = false,
    },
})

--------------------------------------------------------------------------------

Framework.post_settings_stage()
