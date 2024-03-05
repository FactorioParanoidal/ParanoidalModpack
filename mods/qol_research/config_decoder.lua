--[[
    Takes a config string and turns it into a config object.

    The configuration object looks like this:
    {
        ['category-name'] = {
            {
                technology_count = 5, -- 0 means infinite
                bonus_per_technology = 0.05, -- 5%

                prerequisites = {
                    'qol-category-name-1-3',
                    'logistic-science-pack',
                    ... next prerequisite
                },

                cycle_count_formula = '100*L',
                cycle_time = 30, -- seconds
                cycle_ingredients = {
                    { 'logistic-science-pack', 2 },
                    ... next ingredient
                },
            },
            ... next tier
        },
        ... next category
    }
]]

local setting_name_formats = require('defines.setting_name_formats')
local technology_formats = require('defines.technology_name_formats')
local category_map = require('categories').map
local default_import_settings = {
    multiplier = 1,
    min = -1000000,
    max = 1000000,
}
local is_infinite_research_enabled = settings.startup[setting_name_formats.infinite_research_enabled].value

-- returns index: number, strings: string[]
local function decode_string_table(str, index)
    local strings = {}
    local comma = str:find(',', index, true)
    assert(comma)
    local string_count = tonumber(str:sub(index, comma - 1))
    assert(string_count > 0)
    index = comma + 1

    local temp = {}
    for _ = 1, string_count do
        comma = str:find(',', index, true)
        assert(comma)
        -- Check for escape
        while str:byte(comma + 1) == 44 --[[ , ]] do
            temp[#temp + 1] = str:sub(index, comma)
            index = comma + 2
            comma = str:find(',', index, true)
        end
        temp[#temp + 1] = str:sub(index, comma - 1)
        index = comma + 1

        strings[#strings + 1] = table.concat(temp)
        for i = #temp, 1, -1 do
            temp[i] = nil
        end
    end

    return index, strings
end

local function decode_numbers(str, index)
    local nrs = {}
    while true do
        local comma = str:find(',', index, true)
        if comma then
            nrs[#nrs + 1] = tonumber(str:sub(index, comma - 1))
            index = comma + 1
        else
            nrs[#nrs + 1] = tonumber(str:sub(index))
            return nrs
        end
    end
end

return function (str)
    assert(#str >= 3);
    local version, comma = str:byte(1, 2)
    if version ~= 49 --[[ 1 ]] or comma ~= 44 --[[ , ]] then
        error('incorrect config version')
    end

    local index, strings = decode_string_table(str, 3)
    local numbers = decode_numbers(str, index)

    local nr_index = 0
    local function decode_nr()
        nr_index = nr_index + 1
        assert(nr_index <= #numbers)
        return numbers[nr_index]
    end
    local function decode_str()
        local nr = decode_nr()
        if nr == 0 then
            return ''
        else
            return strings[nr]
        end
    end

    local decoded_categories = {}
    local category_count = decode_nr()
    for _ = 1, category_count do
        local name = decode_str()
        local import_settings =
            category_map[name] and category_map[name].import_settings or default_import_settings
        local tier_count = decode_nr()
        local tiers = {}
        for tier_index = 1, tier_count do
            local technology_count = decode_nr()
            local bonus_per_technology = decode_nr() * import_settings.multiplier
            bonus_per_technology = math.max(import_settings.min, math.min(import_settings.max, bonus_per_technology))
            local prerequisites = {}
            do
                local previous_tier = decode_nr()
                if previous_tier ~= 0 then
                    assert(tier_index > 1)
                    prerequisites[#prerequisites + 1] =
                        technology_formats.player:format(name, tier_index - 1, previous_tier)
                end
                local prerequisite_count = decode_nr()
                for _ = 1, prerequisite_count do
                    prerequisites[#prerequisites + 1] = decode_str()
                end
            end
            local cycle_count_formula = decode_str()
            local cycle_time = decode_nr()
            local cycle_ingredients = {}
            do
                local ingredient_count = decode_nr()
                for _ = 1, ingredient_count do
                    local count = decode_nr()
                    cycle_ingredients[#cycle_ingredients + 1] =
                        { decode_str(), count }
                end
            end

            if is_infinite_research_enabled or technology_count ~= 0 then
                tiers[#tiers + 1] = {
                    technology_count = technology_count,
                    bonus_per_technology = bonus_per_technology,
                    prerequisites = prerequisites,
                    cycle_count_formula = cycle_count_formula,
                    cycle_time = cycle_time,
                    cycle_ingredients = cycle_ingredients,
                }
            end
        end

        if category_map[name] then
            decoded_categories[name] = tiers
        else
            log(('[qol] category with name %q in configuration is ignored'):format(name))
        end
    end
    return decoded_categories
end

--[[

Structure represented as comma separated values:
config = {
    version = 1
    strings = count * escaped_string
    categories = count * {
        category_name = stringref
        tiers = count * {
            technology_count = int (0 means infinite)
            bonus_per_technology = float
            previous_tier_requirement = int (0 means no dependency)
            other_requirements = count * stringref
            cycle_count_formula = stringref
            cycle_time = int
            cycle_ingredients = count * {
                count = int
                name = stringref
            }
        }
    }
}

count is an int
escaped_string is the string data with ',' replaced with ',,'
stringref is a 1-based index into strings, or 0 meaning empty string

int is unsigned 32-bit integer
float is IEEE-754 64-bit binary floating point

]]
