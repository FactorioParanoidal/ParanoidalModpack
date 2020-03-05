local flua = require('flua')
local config = flua.ipairs(require('config'))
local data_utils = require('data_utils')
local setting_name_formats = require('defines.setting_name_formats')

local ordering_table = data_utils.create_ordering_table(config:count() * 3)
local flag_ordering_table = data_utils.create_ordering_table(
    config:filtermap(function (i, v)
        return v.field_toggles and #v.field_toggles
    end, 1):max() or 0
)

local function create_infinite_research_flag()
    return {
        name = setting_name_formats.infinite_research_enabled,
        type = 'bool-setting',
        setting_type = 'startup',
        order = 'a-a',
        default_value = true
    }
end
local function create_research_enabled_setting(index, entry)
    return {
        name = setting_name_formats.research_enabled:format(entry.name),
        type = 'bool-setting',
        setting_type = 'startup',
        order = 'b-' .. ordering_table[index * 2],
        default_value = true
    }
end
local function create_research_config_setting(index, entry)
    return {
        name = setting_name_formats.research_config:format(entry.name),
        type = 'string-setting',
        setting_type = 'startup',
        order = 'c-' .. ordering_table[index],
        default_value = '',
        allow_blank = true
    }
end
local function create_flat_bonus_setting(index, entry)
    return {
        name = setting_name_formats.flat_bonus:format(entry.name),
        type = entry.type .. '-setting',
        setting_type = 'runtime-global',
        order = 'd-' .. ordering_table[index * 3 - 2],
        default_value = 0,
        minimum_value = 0,
        maximum_value = 99999
    }
end
local function create_multiplier_setting(index, entry)
    return {
        name = setting_name_formats.multiplier:format(entry.name),
        type = 'double-setting',
        setting_type = 'runtime-global',
        order = 'd-' .. ordering_table[index * 3 - 1],
        default_value = 1,
        minimum_value = 0,
        maximum_value = 999
    }
end
local function create_field_toggle_settings(index, entry)
    return flua.values(entry.field_settings)
        :zip(flua.infinite())
        :map(function (field_toggle, field_index)
        return {
            name = setting_name_formats.field_toggle:format(entry.name):format(field_toggle),
            type = 'bool-setting',
            setting_type = 'runtime-global',
            order = ('d-%s-%s'):format(ordering_table[index * 3], flag_ordering_table[field_index]),
            default_value = true
        }
    end, 1)
end

data:extend(flua.duplicate(1, create_infinite_research_flag())
    :concat(config:map(create_research_enabled_setting, 1))
    :concat(config:map(create_research_config_setting, 1))
    :concat(config:map(create_flat_bonus_setting, 1))
    :concat(config:map(create_multiplier_setting, 1))
    :concat(config:flatmap(create_field_toggle_settings, 1))
    :list()
)
