require('__stdlib__/stdlib/core')
data:extend {
    {
        type = 'custom-input',
        name = 'toggle-night-vision-equipment',
        key_sequence = 'CONTROL + SHIFT + N',
        linked_game_control = nil
    },
    {
        type = 'custom-input',
        name = 'toggle-active-defense-equipment',
        key_sequence = 'CONTROL + SHIFT + P',
        linked_game_control = nil
    },
    {
        type = 'shortcut',
        name = 'toggle-night-vision-equipment',
        order = 'c[toggles]-b[night-vision]',
        action = 'lua',
        toggleable = true,
        localised_name = {'shortcut.toggle-night-vision-equipment'},
        associated_control_input = 'toggle-night-vision-equipment',
        technology_to_unlock = 'night-vision-equipment',
        icon = {
            filename = '__base__/graphics/icons/night-vision-equipment.png',
            priority = 'extra-high-no-scale',
            size = 64,
            scale = 0.5,
            mipmap_count = 4,
            flags = {'gui-icon'}
        }
    },
    {
        type = 'shortcut',
        name = 'toggle-active-defense-equipment',
        order = 'c[toggles]-b[active-defense]',
        action = 'lua',
        toggleable = true,
        localised_name = {'shortcut.toggle-active-defense-equipment'},
        associated_control_input = 'toggle-active-defense-equipment',
        technology_to_unlock = 'personal-laser-defense-equipment',
        icon = {
            filename = '__base__/graphics/icons/personal-laser-defense-equipment.png',
            priority = 'extra-high-no-scale',
            size = 64,
            scale = 0.5,
            mipmap_count = 4,
            flags = {'gui-icon'}
        }
    }
}
