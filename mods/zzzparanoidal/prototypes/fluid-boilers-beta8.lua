-- Five KS Power boilers from the user's Beta 8 (normal), after OV/flowfix/restack.
-- 2.0 adaptations: Bob item IDs, oil-gas-extraction -> oil-gathering,
-- pictures.<direction>.structure and directional fluid connections. No save migration.
local assets = "__zzzparanoidal__/graphics/fluid-boilers-beta8/"
local subgroup = "paranoidal-organized-production-fluid-boilers"
local tiers = {
    {
        temperature = 165, power = "2.7MW", efficiency = 0.5, health = 150, pollution = 24,
        time = 15, ingredients = {{"boiler", 1}, {"bob-basic-circuit-board", 5}, {"copper-plate", 50}, {"stone-brick", 10}},
        prerequisites = {"basic-fluid-handling", "logistic-science-pack"},
        count = 20, research_time = 30, sciences = 2, science_amount = 1,
    },
    {
        temperature = 315, power = "5.4MW", efficiency = 0.67, health = 200, pollution = 20,
        time = 20, ingredients = {{"bob-boiler-2", 1}, {"oil-steam-boiler", 1}, {"steel-plate", 15}, {"bob-basic-circuit-board", 10}, {"concrete", 20}},
        prerequisites = {"OilBurning", "oil-gathering", "concrete", "bob-boiler-2"},
        count = 200, research_time = 30, sciences = 2, science_amount = 1,
    },
    {
        temperature = 465, power = "8.1MW", efficiency = 0.8, health = 300, pollution = 18,
        time = 25, ingredients = {{"bob-boiler-3", 1}, {"oil-steam-boiler-2", 1}, {"bob-invar-alloy", 15}, {"bob-brass-pipe", 10}, {"electronic-circuit", 10}},
        prerequisites = {"OilBurning-2", "chemical-science-pack", "bob-boiler-3"},
        count = 300, research_time = 30, sciences = 3, science_amount = 1,
    },
    {
        temperature = 615, power = "10.8MW", efficiency = 0.9, health = 400, pollution = 12,
        time = 30, ingredients = {{"bob-boiler-4", 1}, {"oil-steam-boiler-3", 1}, {"bob-titanium-plate", 15}, {"bob-titanium-pipe", 10}, {"advanced-circuit", 8}},
        prerequisites = {"OilBurning-3", "production-science-pack", "angels-titanium-smelting-1", "bob-boiler-4"},
        count = 500, research_time = 60, sciences = 4, science_amount = 2,
    },
    {
        temperature = 765, power = "13.5MW", efficiency = 0.98, health = 500, pollution = 6,
        time = 40, ingredients = {{"bob-boiler-5", 1}, {"oil-steam-boiler-4", 1}, {"bob-copper-tungsten-alloy", 15}, {"bob-copper-tungsten-pipe", 10}},
        prerequisites = {"OilBurning-4", "bob-boiler-5"},
        count = 500, research_time = 60, sciences = 5, science_amount = 2,
    },
}
local sciences = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack"}

local function boiler_name(tier)
    return "oil-steam-boiler" .. (tier == 1 and "" or "-" .. tier)
end

local function fluid_box(x, y, direction, flow, filter)
    -- Beta 8: base_area=1, height=2 -> 200 fluid units. Pressure has no 2.0 equivalent.
    return {
        volume = 200, production_type = flow, filter = filter,
        pipe_connections = {{flow_direction = flow, position = {x, y}, direction = direction}},
    }
end

local function pictures(tier)
    local result = {}
    -- Preserve Beta 8's E/W file assignment, frame counts and offsets exactly.
    for direction, spec in pairs({
        north = {"n", 223, 8, 0.5}, east = {"w", 175, 4, 0.45},
        south = {"s", 220, 4, 0.5}, west = {"e", 173, 4, 0.45},
    }) do
        local layers = {}
        for _, suffix in ipairs({"", "-" .. tier}) do
            layers[#layers + 1] = {
                filename = assets .. "graphics/ob_" .. spec[1] .. "_sheet" .. suffix .. ".png",
                width = 256, height = spec[2], frame_count = spec[3], line_length = spec[3],
                shift = {spec[4], 0}, scale = 0.5, animation_speed = 0.2, run_mode = "forward",
            }
        end
        result[direction] = {structure = {layers = layers}}
    end
    return result
end

data:extend({{type = "item-subgroup", name = subgroup, group = "production", order = "a-16"}})
for tier, spec in ipairs(tiers) do
    local name = boiler_name(tier)
    local technology = "OilBurning" .. (tier == 1 and "" or "-" .. tier)
    local icon = assets .. "graphics/icons/oil-steam-boiler-" .. tier .. ".png"
    local localised_name = {"paranoidal-fluid-boilers.name", tostring(spec.temperature)}
    local description = {"paranoidal-fluid-boilers.description", tostring(spec.temperature), tostring(math.floor(spec.efficiency * 100 + 0.5))}
    local ingredients, packs = {}, {}
    for _, ingredient in ipairs(spec.ingredients) do
        assert(data.raw.item[ingredient[1]], "Beta 8 boiler ingredient missing: " .. ingredient[1])
        ingredients[#ingredients + 1] = {type = "item", name = ingredient[1], amount = ingredient[2]}
    end
    for _, prerequisite in ipairs(spec.prerequisites) do
        assert(data.raw.technology[prerequisite], "Beta 8 boiler prerequisite missing: " .. prerequisite)
    end
    for index = 1, spec.sciences do
        packs[#packs + 1] = {sciences[index], spec.science_amount}
    end
    data:extend({
        {
            type = "item", name = name, icon = icon, icon_size = 64,
            localised_name = localised_name, localised_description = description,
            subgroup = subgroup, order = string.format("%02d", tier), place_result = name, stack_size = 20,
        },
        {
            type = "recipe", name = name, icon = icon, icon_size = 64,
            localised_name = localised_name, localised_description = description,
            subgroup = subgroup, order = string.format("%02d", tier),
            enabled = false, energy_required = spec.time, ingredients = ingredients,
            results = {{type = "item", name = name, amount = 1}},
            always_show_products = true, show_amount_in_title = false,
            always_show_made_in = false, allow_decomposition = true, allow_productivity = false,
        },
        {
            type = "technology", name = technology,
            icon = assets .. "graphics/technology/oil-boiler-tech-" .. tier .. ".png", icon_size = 128,
            localised_name = {"paranoidal-fluid-boilers.technology", tostring(tier)},
            localised_description = description,
            prerequisites = spec.prerequisites, effects = {{type = "unlock-recipe", recipe = name}},
            unit = {count = spec.count, time = spec.research_time, ingredients = packs}, order = "f-b-c",
        },
        {
            type = "boiler", name = name,
            icon = tier == 1 and assets .. "graphics/icons/oil-steam-boiler.png" or icon, icon_size = 64,
            localised_name = localised_name, localised_description = description,
            flags = {"placeable-neutral", "player-creation"},
            minable = {mining_time = 0.1, result = name}, max_health = spec.health,
            fast_replaceable_group = "oil-steam-boiler", next_upgrade = tier < 5 and boiler_name(tier + 1) or nil,
            corpse = "big-remnants", dying_explosion = "big-explosion",
            -- Final Beta 8 collision box (including its Squeak Through adjustment).
            collision_box = {{-1.08, -1.08}, {1.08, 1.08}}, selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
            vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
            resistances = {{type = "fire", percent = 90}, {type = "explosion", percent = 30}, {type = "impact", percent = 30}},
            mode = "output-to-separate-pipe", target_temperature = spec.temperature, energy_consumption = spec.power,
            -- North-facing: water on the left, fuel on the right, steam opposite.
            fluid_box = fluid_box(-1, -1, defines.direction.north, "input", "water"),
            output_fluid_box = fluid_box(0, 1, defines.direction.south, "output", "steam"),
            energy_source = {
                type = "fluid", effectivity = spec.efficiency, emissions_per_minute = {pollution = spec.pollution},
                burns_fluid = true, scale_fluid_usage = true,
                fluid_box = fluid_box(1, -1, defines.direction.north, "input"),
                smoke = {{
                    name = "smoke", frequency = 15, starting_vertical_speed = 0, starting_frame_deviation = 60,
                    north_position = {-1.1875, -1.484375}, south_position = {1.203125, -1},
                    east_position = {0.625, -2.1875}, west_position = {-0.59375, -0.265625},
                }},
            },
            working_sound = {
                sound = {filename = assets .. "sounds/oil-boiler-loop-2.ogg", volume = 0.35},
                idle_sound = {filename = assets .. "sounds/steam-offlet.ogg", volume = 0.35},
                max_sounds_per_type = 2,
            },
            pictures = pictures(tier), burning_cooldown = 20,
        },
    })
end
