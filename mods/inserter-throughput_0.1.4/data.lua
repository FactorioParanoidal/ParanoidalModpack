local mod_gui = require('mod-gui')
local mod_button_style = mod_gui.button_style

data:extend{
    {
        type = 'sprite',
        name = 'inserter-throughput-toggle-button',
        filename = '__inserter-throughput__/graphics/toggle-button.png',
        size = 64,
        flags = {'gui-icon'},
    },
    {
        type = 'custom-input',
        name = 'inserter-throughput-toggle',
        localized_name = 'inserter-throughput-toggle-keybind',
        key_sequence = '',
    }
}

local styles = data.raw['gui-style'].default
local button_style = styles[mod_button_style]
local clicked_graphics = button_style.clicked_graphical_set
local default_graphics = button_style.default_graphical_set
while not (clicked_graphics and default_graphics) do
    button_style = styles[button_style.parent]
    clicked_graphics = clicked_graphics or button_style.clicked_graphical_set
    default_graphics = default_graphics or button_style.default_graphical_set
end

styles.inserter_throughput_pressed_button = {
    type = 'button_style',
    parent = mod_button_style,
    default_graphical_set = clicked_graphics,
    clicked_graphical_set = default_graphics
}
