-- Recipes, research, health, resistances, mining time and stack size as in Paranoidal Beta 8;
-- graphics, collision boxes and power at full wind as in Wind Turbines (relaunched) 2.2.5.
local tiers = require("tiers")

local function sprite(name)
    return "__Wind-Turbines-Reforged__/graphics/" .. name
end

local function stripes(prefix, count, columns, rows)
    local list = {}
    for i = 1, count do
        list[i] = { filename = sprite(prefix .. i .. ".png"), width_in_frames = columns, height_in_frames = rows }
    end
    return list
end

local function first(kind, ...)
    for _, name in ipairs({ ... }) do
        if data.raw[kind][name] then return name end
    end
    error("Wind-Turbines-Reforged: none of " .. table.concat({ ... }, ", ") .. " exists in " .. kind)
end

local function ingredients(list)
    local result = {}
    for i, entry in ipairs(list) do
        result[i] = { type = "item", name = entry[1], amount = entry[2] }
    end
    return result
end

local function resistances(fire, physical, impact)
    return {
        { type = "fire", percent = fire },
        { type = "physical", percent = physical },
        { type = "impact", percent = impact },
    }
end

local definitions = {
    {
        name = "texugo-wind-turbine",
        icon = "windw_icon.png",
        order = "a",
        health = 100,
        mining_time = 4,
        resistances = resistances(20, 20, 30),
        corpse = "medium-small-remnants",
        dying_explosion = "explosion",
        collision_box = { { -1.4, -0.9 }, { 1.4, 0.9 } },
        selection_box = { { -1.5, -1 }, { 1.5, 1 } },
        base_box = { { -1, -0.7 }, { 1, 0.9 } },
        animation = {
            stripes = stripes("wind", 3, 4, 5),
            width = 500, height = 350, scale = 0.6, frame_count = 44,
            shift = { 2, -1.2 }, animation_speed = 0.005,
        },
        recipe = {
            energy = 8,
            enabled = true,
            ingredients = {
                { "wood", 10 }, { "copper-cable", 20 }, { "iron-stick", 20 },
                { "small-electric-pole", 4 }, { "iron-gear-wheel", 4 },
            },
        },
    },
    {
        name = "texugo-wind-turbine2",
        icon = "winds_icon.png",
        order = "b",
        health = 500,
        mining_time = 10,
        resistances = resistances(70, 50, 50),
        corpse = "medium-remnants",
        dying_explosion = "medium-explosion",
        collision_box = { { -1.9, -0.9 }, { 1.9, 0.9 } },
        selection_box = { { -2, -1 }, { 2, 1 } },
        base_box = { { -1, -1.4 }, { 1.8, 0.9 } },
        animation = {
            stripes = stripes("winds", 4, 3, 4),
            width = 650, height = 500, scale = 0.5, frame_count = 44,
            shift = { 2.5, -1.6 }, animation_speed = 0.0007,
        },
        recipe = {
            energy = 30,
            ingredients = {
                { first("item", "bob-big-electric-pole-2", "big-electric-pole"), 4 }, { "electronic-circuit", 10 },
                { "iron-gear-wheel", 50 }, { "steel-plate", 150 }, { "stone-brick", 150 },
            },
        },
        technology = {
            icon = "winds_tec.png",
            prerequisites = { first("technology", "bob-electric-pole-2", "electric-energy-distribution-1") },
            count = 200,
            packs = { "automation-science-pack", "logistic-science-pack" },
            amount = 1,
        },
    },
    {
        name = "texugo-wind-turbine3",
        icon = "windh_icon.png",
        order = "c",
        health = 1500,
        mining_time = 30,
        resistances = resistances(70, 50, 50),
        corpse = "big-remnants",
        dying_explosion = "big-explosion",
        collision_box = { { -2.9, -1.4 }, { 2.9, 1.4 } },
        selection_box = { { -3, -1.5 }, { 3, 1.5 } },
        base_box = { { -1.9, -1.2 }, { 1.9, 1.4 } },
        animation = {
            stripes = stripes("windh", 8, 2, 3),
            width = 800, height = 550, scale = 1.1, frame_count = 44,
            shift = { 4.8, -4.1 }, animation_speed = 0.000015, priority = "low",
        },
        recipe = {
            energy = 150,
            ingredients = {
                { "advanced-circuit", 25 }, { "flying-robot-frame", 25 }, { "iron-gear-wheel", 100 },
                { "substation", 10 }, { "steel-plate", 500 }, { "concrete", 500 },
            },
        },
        technology = {
            icon = "windh_tec.png",
            prerequisites = { "robotics", first("technology", "processing-unit"), "texugo-wind-turbine2" },
            count = 500,
            packs = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" },
            amount = 2,
        },
    },
}

local hidden_flags = {
    "not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable",
    "not-flammable", "not-selectable-in-game", "not-in-kill-statistics", "not-upgradable", "no-copy-paste",
}
local empty = { filename = "__core__/graphics/empty.png", size = 1 }

for _, def in ipairs(definitions) do
    local tier = tiers[def.name]
    local icon = sprite(def.icon)
    local prototypes = {
        {
            type = "item",
            name = def.name,
            icon = icon,
            icon_size = 32,
            localised_description = { "entity-description." .. def.name },
            subgroup = "energy",
            order = "b[steam-power]-c[texugo-wind-turbine]-" .. def.order,
            place_result = def.name,
            stack_size = 20,
        },
        {
            type = "recipe",
            name = def.name,
            enabled = def.recipe.enabled or false,
            energy_required = def.recipe.energy,
            ingredients = ingredients(def.recipe.ingredients),
            results = { { type = "item", name = def.name, amount = 1 } },
        },
        {
            type = "electric-energy-interface",
            name = def.name,
            icon = icon,
            icon_size = 32,
            flags = { "placeable-neutral", "player-creation", "not-rotatable" },
            minable = { mining_time = def.mining_time, result = def.name },
            max_health = def.health,
            resistances = def.resistances,
            corpse = def.corpse,
            dying_explosion = def.dying_explosion,
            fast_replaceable_group = def.name,
            collision_mask = { layers = { item = true, object = true, water_tile = true } },
            collision_box = def.collision_box,
            selection_box = def.selection_box,
            -- Real output is set by control.lua; output_flow_limit stays unlimited so that quality is not cut off.
            energy_source = {
                type = "electric",
                usage_priority = "primary-output",
                buffer_capacity = string.format("%gJ", tier.kw * 1000 / 60),
                input_flow_limit = "0W",
                render_no_power_icon = false,
            },
            energy_production = tier.kw .. "kW",
            continuous_animation = false,
            animation = def.animation,
            min_perceived_performance = 1.0,
        },
        -- Hidden pole: connects the turbine to neighbouring turbines and poles.
        {
            type = "electric-pole",
            name = tier.pole,
            localised_name = { "entity-name." .. def.name },
            icon = icon,
            icon_size = 32,
            flags = hidden_flags,
            hidden = true,
            hidden_in_factoriopedia = true,
            collision_mask = { layers = {} },
            collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
            maximum_wire_distance = tier.wire,
            supply_area_distance = 1,
            pictures = { filename = "__core__/graphics/empty.png", size = 1, direction_count = 1 },
            connection_points = { { wire = { copper = { 0, 0 } }, shadow = { copper = { 0, 0 } } } },
            radius_visualisation_picture = empty,
        },
        -- Solid base at the foot of the turbine: players and vehicles cannot pass through it.
        {
            type = "simple-entity-with-owner",
            name = tier.base,
            localised_name = { "entity-name." .. def.name },
            icon = icon,
            icon_size = 32,
            flags = hidden_flags,
            hidden = true,
            hidden_in_factoriopedia = true,
            collision_box = def.base_box,
            picture = empty,
        },
    }
    if def.technology then
        local units = {}
        for i, pack in ipairs(def.technology.packs) do units[i] = { pack, def.technology.amount } end
        prototypes[#prototypes + 1] = {
            type = "technology",
            name = def.name,
            icon = sprite(def.technology.icon),
            icon_size = 128,
            prerequisites = def.technology.prerequisites,
            effects = { { type = "unlock-recipe", recipe = def.name } },
            unit = { count = def.technology.count, ingredients = units, time = 60 },
        }
    end
    data:extend(prototypes)
end

data:extend({
    -- Left click on a turbine opens the wind window; the turbine itself has no GUI.
    { type = "custom-input", name = "twr-open-turbine", key_sequence = "", linked_game_control = "open-gui" },
})
