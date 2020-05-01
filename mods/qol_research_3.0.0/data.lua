local categories = require('categories')
local data_utils = require('data_utils')
local config = require('config')
local setting_formats = require('defines.setting_name_formats')
local technology_formats = require('defines.technology_name_formats')

local ordering_table
do
    local count = categories.count
    for _, tiers in pairs(config) do
        count = math.max(count, #tiers)
        for _, tier in ipairs(tiers) do
            count = math.max(tier.technology_count)
        end
    end
    ordering_table = data_utils.create_ordering_table(count)
end

local player_technologies = {}
local function create_player_technologies_for_category(category, tiers)
    if not settings.startup[setting_formats.research_enabled:format(category.name)].value then
        return
    end

    local technology_icon = ('__qol_research__/graphics/%s.png'):format(category.name)
    for tier_index, tier in ipairs(tiers) do
        local localised_description = {
            ('technology-description.qol-%s'):format(category.name),
            category.description_factory(tier.bonus_per_technology)
        }

        for technology_index = 1, math.max(tier.technology_count, 1) do
            local prerequisites
            if technology_index == 1 then
                prerequisites = tier.prerequisites
            else
                prerequisites = { technology_formats.player:format(category.name, tier_index, technology_index - 1) }
            end

            player_technologies[#player_technologies + 1] = {
                type = 'technology',
                name = technology_formats.player:format(category.name, tier_index, technology_index),
                localised_description = localised_description,
                icon = technology_icon,
                icon_size = 128,
                prerequisites = prerequisites,
                unit =
                {
                    count_formula = tier.cycle_count_formula,
                    time = tier.cycle_time,
                    ingredients = tier.cycle_ingredients,
                },
                upgrade = true,
                order = ('qol-research-%s-%s-%s'):format(
                    ordering_table[category.index],
                    ordering_table[tier_index],
                    ordering_table[technology_index]
                ),
            }
        end

        -- Special case for infinite research
        if tier.technology_count == 0 then
            player_technologies[#player_technologies].max_level = 'infinite'
        end
    end
end
for category_name, tiers in pairs(config) do
    create_player_technologies_for_category(categories.map[category_name], tiers)
end

if #player_technologies > 0 then
    data:extend(player_technologies)
end

local internal_technologies = {}
for _, category in ipairs(categories.list) do
    for _, effect in ipairs(category.effects) do
        for index = 1, category.internal_technology_spec.count do
            internal_technologies[#internal_technologies + 1] = {
                type = 'technology',
                name = technology_formats.internal:format(effect, index),
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
                    type = effect,
                    modifier = category.internal_technology_spec.value_scale * math.pow(2, index - 1),
                } },
                prerequisites = index ~= 1 and { technology_formats.internal:format(effect, index - 1) } or nil,
                order = '~~~~~~~~~~~~~~',
                upgrade = true,
            }
        end
    end
end

if #internal_technologies > 0 then
    data:extend(internal_technologies)
end