local category_list = require('categories').list
local data_utils = require('data_utils')
local setting_formats = require('defines.setting_name_formats')

local ordering_table = data_utils.create_ordering_table_for_settings()
local settings = {}

-- Startup settings
settings[#settings + 1] = {
    name = setting_formats.modpack_compatibility_enabled,
    type = 'bool-setting',
    setting_type = 'startup',
    order = 'a-a',
    default_value = true,
}
settings[#settings + 1] = {
    name = setting_formats.infinite_research_enabled,
    type = 'bool-setting',
    setting_type = 'startup',
    order = 'a-b',
    default_value = true,
}
for index, category in ipairs(category_list) do
    settings[#settings + 1] = {
        name = setting_formats.research_enabled:format(category.name),
        type = 'bool-setting',
        setting_type = 'startup',
        order = 'b-' .. ordering_table[index],
        default_value = true,
    }
end
settings[#settings + 1] = {
    name = setting_formats.custom_config,
    type = 'string-setting',
    setting_type = 'startup',
    order = 'c-a',
    default_value = '',
    allow_blank = true,
}

-- Runtime settings
for index, category in ipairs(category_list) do
    settings[#settings + 1] = {
        name = setting_formats.flat_bonus:format(category.name),
        type = category.type .. '-setting',
        setting_type = 'runtime-global',
        order = ordering_table[index * 3 - 2] .. '-a',
        default_value = 0,
        minimum_value = 0,
        maximum_value = 99999,
    }
end
for index, category in ipairs(category_list) do
    settings[#settings + 1] = {
        name = setting_formats.multiplier:format(category.name),
        type = 'double-setting',
        setting_type = 'runtime-global',
        order = ordering_table[index * 3 - 1] .. '-b',
        default_value = 1,
        minimum_value = 0,
        maximum_value = 999,
    }
end
for index, category in ipairs(category_list) do
    local effect_index = 1
    for _, effect_toggle in pairs(category.effect_settings or {}) do
        settings[#settings + 1] = {
            name = setting_formats.effect_flag:format(category.name, effect_toggle),
            type = 'bool-setting',
            setting_type = 'runtime-global',
            order = ('%s-c-%s'):format(ordering_table[index * 3], ordering_table[effect_index]),
            default_value = true,
        }
        effect_index = effect_index + 1
    end
end

if #settings > 0 then
    data:extend(settings)
end
