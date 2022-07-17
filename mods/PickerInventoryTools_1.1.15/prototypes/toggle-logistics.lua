data:extend {
    {
        type = 'shortcut',
        name = 'toggle-personal-logistic-requests',
        order = 'c[toggles]-b[personal-logistic-requests]',
        action = 'toggle-personal-logistic-requests',
        localised_name = {'shortcut.toggle-personal-logistic-requests'},
        associated_control_input = 'toggle-personal-logistic-requests',
        technology_to_unlock = 'personal-roboport-equipment',
        icon = {
            filename = '__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x32.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 0.5,
            mipmap_count = 2,
            flags = {'gui-icon'}
        },
        small_icon = {
            filename = '__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-request-x24.png',
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 0.5,
            mipmap_count = 2,
            flags = {'gui-icon'}
        },
        disabled_icon = {
            filename = '__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x32-white.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 0.5,
            mipmap_count = 2,
            flags = {'gui-icon'}
        },
        disabled_small_icon = {
            filename = '__base__/graphics/icons/shortcut-toolbar/mip/toggle-personal-logistics-x24-white.png',
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 0.5,
            mipmap_count = 2,
            flags = {'gui-icon'}
        }
    },
}
