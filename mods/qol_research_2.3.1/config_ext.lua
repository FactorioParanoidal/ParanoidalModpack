local flua = require('flua')
local config = require('config')

local setting_name_formats = require('defines.setting_name_formats')
local getters = {}

function getters:is_enabled()
    return true, true
    -- return true, settings.startup[self.setting_names.enabled].value
end

function getters:is_research_enabled()
    return true, self.is_enabled and settings.startup[self.setting_names.research_enabled].value
end

function getters:setting_flat_bonus()
    return false, settings.global[self.setting_names.flat_bonus].value
end

function getters:setting_multiplier()
    return false, settings.global[self.setting_names.multiplier].value
end

function getters:field_setting_names()
    return true, flua.keys(self.field_setting_map)
end

function getters:config()
    local config_entries = settings.startup[self.setting_names.research_config].value
    if not config_entries or #config_entries == 0 then
        config_entries = config[self.index].default_config
    end

    local function parse_assert(condition, tier_index, message)
        if not condition then
            error(('[qol] config parse error in %s tier %s, %s'):format(self.name, tier_index, message), 2)
        end
    end

    -- Parse the config
    local _, _, remainder, prerequisites = config_entries:find('^(.+);([^;]+)$')
    if prerequisites then
        config_entries = remainder
        prerequisites = flua.wrap(1, prerequisites:gmatch('[^,]+')):list()
    end

    local config = flua.wrap(1, config_entries:gmatch('[^:]+'))
        :flatmap(function (tier_str, index)
            local properties = flua.wrap(1, tier_str:gmatch('([^:,]+),?')):list()
            parse_assert(#properties >= 7 and #properties % 2 == 1, index, 'incorrect number of properties')

            -- Generate ingredients table
            local ingredients = {}
            for i, v in flua.ipairs(properties):skip(5):iter() do
                if i % 2 == 0 then -- Ingredient name
                    ingredients[(i - 4) / 2] = { v }
                else -- Ingredient count
                    ingredients[(i - 5) / 2][2] = v
                end
            end
            
            -- Parse all other properties
            local requirement = tonumber(properties[1])
            parse_assert(type(requirement) == 'number' and requirement >= 0, index, 'previous tier requirement must be a non-negative number')
            local tier_depth = tonumber(properties[2])
            parse_assert(type(tier_depth) == 'number' and tier_depth >= 0, index, 'tier depth must be a non-negative number')
            local effect_value = tonumber(properties[3])
            parse_assert(type(effect_value) == 'number' and effect_value >= 0, index, 'effect value must be a non-negative number')
            local cycle_duration = tonumber(properties[4])
            parse_assert(type(cycle_duration) == 'number' and cycle_duration >= 0, index, 'cycle duration must be a non-negative number')
            local cost_formula = properties[5]

            if tier_depth == 0 and not settings.startup[setting_name_formats.infinite_research_enabled].value then
                return flua.duplicate(0, true)
            end
            return flua.duplicate(1, {
                requirement = requirement,
                tier_depth = tier_depth,
                effect_value = effect_value,
                cycle_duration = cycle_duration,
                cost_formula = cost_formula,
                cycle_ingredients = ingredients
            })
        end)
        :list()

    parse_assert(#config >= 1, 0, 'at least one tier must be configured')
    parse_assert(config[1].requirement == 0, 1, 'the first tier cannot have requirements')
    for i = 1, #config - 1 do
        parse_assert(config[i].tier_depth >= config[i + 1].requirement, i + 1, 'tier requirement cannot be greater than previous tier depth')
    end

    config.prerequisites = prerequisites

    return true, config
end

function getters:field_is_enabled()
    return true, setmetatable({}, {
        __index = function (__self, field_name)
            local field_setting_name = self.field_settings[field_name]
            if not field_setting_name then return true end
            return settings.global[self.setting_names.field_toggle:format(field_setting_name)].value
        end,
        __newindex = function () error('cannot assign') end,
    })
end

local metatable = {}
function metatable.__index(self, key)
    -- log(('indexing %s at %q'):format(self.name, key))
    local fn = getters[key]
    if fn then
        local cache, value = fn(self)
        if cache then rawset(self, key, value) end
        return value
    end
end
function metatable.__newindex(self, key, value)
    error('cannot add extra properties to config_ext', 2)
end

return flua.ipairs(config):map(function (index, entry)
    local setting_names = flua.pairs(setting_name_formats)
        :map(function (k, v)
            return k, v:format(entry.name)
        end)
        :table()
    
    local field_setting_map = flua.pairs(entry.field_settings)
        :map(function (field_name, setting_name)
            return setting_names.field_toggle:format(setting_name), field_name
        end)
        :table()

    return setmetatable({
        index = index,
        name = entry.name,
        type = entry.type,
        description_factory = entry.description_factory,
        fields = flua.ivalues(entry.fields),
        field_settings = entry.field_settings or {},
        field_technology = entry.field_technology,
        setting_names = setting_names,
        field_setting_map = field_setting_map
    }, metatable)
end, 1):list()
