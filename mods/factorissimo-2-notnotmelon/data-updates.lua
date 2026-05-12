require "prototypes.space-location"
require "prototypes.ceiling"
require "prototypes.factory-pumps"
require "prototypes.quality-tooltips"
require "script.roboport.utility-constants"
require "compat.pyanodon"

local F = "__factorissimo-2-notnotmelon__"

local function blank()
    return {
        filename = F .. "/graphics/nothing.png",
        priority = "high",
        width = 1,
        height = 1
    }
end

local linked_belts = {}
for _, type in ipairs {"linked-belt", "transport-belt", "underground-belt", "loader-1x1", "loader", "splitter", "lane-splitter"} do
    for _, belt in pairs(data.raw[type]) do
        if belt.collision_mask and belt.collision_mask.layers and not belt.collision_mask.layers.transport_belt then
            belt.collision_mask.layers.transport_belt = true -- Fixes a crash with advanced furances 2
        end

        local linked = table.deepcopy(belt)
        linked.allow_side_loading = false
        linked.type = "linked-belt"
        linked.next_upgrade = nil
        if not linked.localised_name then linked.localised_name = {"entity-name." .. linked.name} end
        linked.name = "factory-linked-" .. linked.name
        linked.structure = {
            direction_in = blank(),
            direction_out = blank()
        }
        linked.heating_energy = nil
        linked.selection_box = nil
        linked.minable = nil
        linked.hidden = true
        linked.belt_length = nil
        linked.collision_mask = {layers = {transport_belt = true}}
        linked.filter_count = nil
        linked.structure_render_layer = nil
        linked.container_distance = nil
        linked.belt_length = nil
        if type == "loader" or type == "splitter" then linked.collision_box = {{-0.4, -0.4}, {0.4, 0.4}} end

        linked_belts[#linked_belts + 1] = linked
    end
end
data:extend(linked_belts)

if data.raw["assembling-machine"]["borehole-pump"] then
    data:extend {{
        type = "item-subgroup",
        name = "borehole-pump",
        group = "space",
        order = "x-a"
    }}


    local borehole_fluids = {}
    local function add_borehole_fluid(fluid_name)
        if borehole_fluids[fluid_name] then return end

        borehole_fluids[fluid_name] = true
        local fluid = data.raw.fluid[fluid_name]
        local recipe_name = "borehole-pump-" .. fluid_name
        data:extend {{
            type = "recipe",
            name = recipe_name,
            localised_name = fluid.localised_name or {"fluid-name." .. fluid.name},
            enabled = false,
            ingredients = {},
            energy_required = 4,
            allow_productivity = true,
            hide_from_player_crafting = true,
            category = "borehole-pump",
            subgroup = "borehole-pump",
            results = {
                {type = "fluid", name = fluid_name, amount = 600}
            },
            surface_conditions = table.deepcopy(data.raw["assembling-machine"]["borehole-pump"].surface_conditions)
        }}
        table.insert(data.raw.technology["factory-upgrade-borehole-pump"].effects, {type = "unlock-recipe", recipe = recipe_name})
    end

    for _, tile in pairs(data.raw.tile) do
        if tile.autoplace and tile.fluid and not tile.hidden then
            add_borehole_fluid(tile.fluid)
        end
    end

    if mods["metal-and-stars"] then
        add_borehole_fluid("dark-matter-fluid")
    end

    local function add_surface_conditions_to_borehole_recipe(recipe_name, conditions_source_to_copy)
        local recipe = data.raw.recipe[recipe_name]
        if not recipe then return end
        if not conditions_source_to_copy then return end

        recipe.surface_conditions = recipe.surface_conditions or {}
        for _, condition in pairs(table.deepcopy(conditions_source_to_copy.surface_conditions) or {}) do
            table.insert(recipe.surface_conditions, condition)
        end
    end

    add_surface_conditions_to_borehole_recipe("borehole-pump-heavy-oil", data.raw.recipe["electromagnetic-science-pack"])
    add_surface_conditions_to_borehole_recipe("borehole-pump-ammoniacal-solution", data.raw.recipe["cryogenic-science-pack"])
    add_surface_conditions_to_borehole_recipe("borehole-pump-lava", data.raw.recipe["metallurgic-science-pack"])
    add_surface_conditions_to_borehole_recipe("borehole-pump-water", (data.raw["agricultural-tower"] or {})["agricultural-tower"])
end

data.raw.recipe["factory-1-instantiated-recycling"] = nil
data.raw.recipe["factory-2-instantiated-recycling"] = nil
data.raw.recipe["factory-3-instantiated-recycling"] = nil
