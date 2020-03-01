local flua = require('flua')
local config_ext = flua.ivalues(require('config_ext'))
local data_utils = require('data_utils')
local player_technology_format = 'qol-%s-%d-%d'
local internal_technology_format = 'qolinternal-%s-%d'

local ordering_table = data_utils.create_ordering_table(math.max(
    config_ext:map(function (entry) return #entry.config end):max(),
    config_ext:count()
))

local player_technologies = config_ext
    :filter(function (entry)
        -- log(('%s: is_research_enabled: %q'):format(entry.name, tostring(entry.is_research_enabled)))
        return entry.is_research_enabled
    end)

player_technologies = player_technologies:flatmap(function (entry)
    local config = entry.config
    local technology_icon = ('__qol_research__/graphics/%s.png'):format(entry.name)
    return flua.ipairs(config):flatmap(function (tier_index, tier)
        -- Infinite technology
        local localised_description = {
            ('technology-description.qol-%s'):format(entry.name),
            entry.description_factory(tier.effect_value)
        }
        local tier_order = ('qol-research-%s-%s'):format(ordering_table[entry.index], ordering_table[tier_index])
        local prerequisites
        if tier.requirement == 0 then
            prerequisites = table.deepcopy(config.prerequisites)
        else
            prerequisites = { (player_technology_format):format(entry.name, tier_index - 1, tier.requirement) }
        end
        if tier.tier_depth == 0 then
            if tier_index ~= #config then
                error(('[qol] invalid config for %s, tier %s cannot be infinite because it is not the last'):format(entry.name, tier_index))
            end
            return flua.duplicate(1, {
                type = 'technology',
                name = (player_technology_format):format(entry.name, tier_index, 1),
                localised_description = localised_description,
                icon = technology_icon,
                icon_size = 128,
                prerequisites = prerequisites,
                unit =
                {
                    count_formula = tier.cost_formula,
                    ingredients = tier.cycle_ingredients,
                    time = tier.cycle_duration
                },
                max_level = 'infinite',
                upgrade = true,
                order = tier_order
            })
        end

        return flua.range(tier.tier_depth):map(function (technology_index)
            local current_prerequisites
            if technology_index == 1 then
                current_prerequisites = prerequisites
            else
                current_prerequisites = { (player_technology_format):format(entry.name, tier_index, technology_index - 1) }
            end

            return {
                type = 'technology',
                name = (player_technology_format):format(entry.name, tier_index, technology_index),
                localised_description = localised_description,
                icon = technology_icon,
                icon_size = 128,
                prerequisites = current_prerequisites,
                unit =
                {
                    count_formula = tier.cost_formula,
                    ingredients = tier.cycle_ingredients,
                    time = tier.cycle_duration
                },
                upgrade = true,
                order = tier_order
            }
        end)
    end, 1)
end, 1):list()

if #player_technologies > 0 then
    data:extend(player_technologies)
end

local internal_technologies = config_ext
    :filter(function (entry) return entry.is_enabled end)
    :flatmap(function (entry)
        return entry.fields:flatmap(function (field)
            return flua.range(0, entry.field_technology.count - 1)
                :map(function (index)
                return {
                    type = 'technology',
                    name = internal_technology_format:format(field, index + 1),
                    localised_name = { 'qol-internal-tech.name' },
                    localised_description = { 'qol-internal-tech.description' },
                    icon = '__qol_research__/graphics/internal-tech.png',
                    icon_size = 128,
                    enabled = false,
                    hidden = true,
                    unit =
                    {
                        count = 1,
                        time = 1,
                        ingredients = { }
                    },
                    effects =
                    { {
                        type = field,
                        modifier = entry.field_technology.value_scale * math.pow(2, index),
                    } },
                    prerequisites = index ~= 0 and { internal_technology_format:format(field, index) } or nil,
                    order = '~~~~~~~~~~~~~~',
                    upgrade = true,
                }
            end)
            :concat(flua.duplicate(1, {
                type = 'technology',
                name = internal_technology_format:format(field, entry.field_technology.count + 1),
                localised_name = { 'qol-internal-tech.name' },
                localised_description = { 'qol-internal-tech.description' },
                icon = '__qol_research__/graphics/internal-tech.png',
                icon_size = 128,
                enabled = false,
                unit =
                {
                    count = 1,
                    time = 1,
                    ingredients = { }
                },
                prerequisites = { internal_technology_format:format(field, entry.field_technology.count) },
                order = '~~~~~~~~~~~~~~',
                upgrade = true,
            }))
        end)
    end)
    :list()

if #internal_technologies > 0 then
    data:extend(internal_technologies)
end