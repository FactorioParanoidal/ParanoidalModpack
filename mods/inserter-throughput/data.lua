local mod_gui = require('mod-gui')
local mod_button_style = mod_gui.button_style

data:extend{
    {
        type = 'sprite',
        name = 'inserter-throughput-toggle-button',
        layers = {
            {
                filename = '__base__/graphics/icons/inserter.png',
                size = 64,
                mipmap_count = 4,
                flags = {'gui-icon'},
            },
            {
                filename = '__inserter-throughput__/graphics/toggle-button.png',
                size = 64,
                flags = {'gui-icon'},
            },
        }
    },
    {
        type = 'custom-input',
        name = 'inserter-throughput-toggle',
        localized_name = 'inserter-throughput-toggle-keybind',
        key_sequence = '',
    }
}
