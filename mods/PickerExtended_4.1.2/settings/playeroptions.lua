local color = require('__stdlib__/stdlib/utils/defines/color')

local allowed_values = {'default'}
for name in pairs(color) do
    allowed_values[#allowed_values + 1] = name
end

data:extend{
    {
        type = 'string-setting',
        name = 'picker-chat-color',
        setting_type = 'runtime-per-user',
        default_value = 'default',
        allowed_values = allowed_values,
        order = 'player-options-chat-color'
    },
    {
        type = 'string-setting',
        name = 'picker-character-color',
        setting_type = 'runtime-per-user',
        default_value = 'default',
        allowed_values = allowed_values,
        order = 'player-options-character-color'
    }
}