-- Import color options to use in settings
local color = require('utils/color')

local allowed_values = {'default'}
for _, name in ipairs(color.names()) do
    allowed_values[#allowed_values + 1] = name
end

data:extend{
    {
        type = 'bool-setting',
        name = 'picker-alt-mode-default',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a[Picker]-a[Player]-c'
    },
    {
        type = 'string-setting',
        name = 'picker-chat-color',
        setting_type = 'runtime-per-user',
        default_value = 'default',
        allowed_values = allowed_values,
        order = 'a[Picker]-a[Player]-b'
    },
    {
        type = 'string-setting',
        name = 'picker-character-color',
        setting_type = 'runtime-per-user',
        default_value = 'default',
        allowed_values = allowed_values,
        order = 'a[Picker]-a[Player]-a'
    }
}