-- Shortcut with keybind
local Data = require('__stdlib__/stdlib/data/data')

if not mods['BotPrioritizer'] and settings.get_startup('picker-bp-prioritizer') then
    Data{
        type = 'shortcut',
        name = 'picker-bp-prioritizer-shortcut',
        order = 'b[blueprints]-h[bot-prio]',
        action = 'lua',
        associated_control_input = 'picker-bp-prioritizer-input',
        toggleable = true,
        icon = {
            filename = '__PickerBlueprinter__/graphics/bot-prioritizer.png',
            priority = 'extra-high-no-scale',
            size = 64,
            icon_mipmaps = 4,
            scale = 1,
            flags = {'icon'}
        }
    }
    Data{type = 'custom-input', name = 'picker-bp-prioritizer-input', key_sequence = 'CONTROL + D', consuming = 'none'}
end
