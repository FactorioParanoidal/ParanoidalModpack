local constants = require "__FluidMustFlow__.prototypes.constants"

data.raw.technology["ducts"].unit = nil
data.raw.technology["ducts"].research_trigger = {
    type = "mine-entity",
    entities = {"maraxsis-chimney"}
}
data.raw.technology["ducts"].prerequisites = {"sp-spidertron-automation", "planet-discovery-maraxsis"}

data:extend {{
    type = "item",
    name = "maraxsis-trench-duct",
    icon = "__maraxsis__/graphics/icons/trench-duct.png",
    stack_size = 5,
    place_result = "maraxsis-trench-duct",
    subgroup = "ducts",
    order = "d[pipe]-x[trench-duct]"
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-trench-duct",
    enabled = false,
    ingredients = {
        {type = "item", name = "duct-small",     amount = 100},
        {type = "item", name = "tungsten-plate", amount = 100},
        {type = "item", name = "pump",           amount = 10},
    },
    results = {
        {type = "item", name = "maraxsis-trench-duct", amount = 1},
    },
    auto_recycle = true,
    energy_required = 10,
}}
table.insert(data.raw.technology["ducts"].effects, {
    type = "unlock-recipe",
    recipe = "maraxsis-trench-duct",
})

for _, effect in pairs(data.raw.technology["ducts"].effects) do
    if effect.type == "unlock-recipe" then
        local recipe = data.raw.recipe[effect.recipe]        
        recipe.categories = {"maraxsis-hydro-plant", "advanced-crafting"}
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.name == "iron-plate" then
                ingredient.name = "tungsten-plate"
                ingredient.amount = ingredient.amount / 4
                break
            elseif not data.raw.item[ingredient.name] and not data.raw.fluid[ingredient.name] then -- https://github.com/notnotmelon/maraxsis/issues/271
                ingredient.name = "iron-gear-wheel"
                ingredient.type = "item"
            end
        end
        local item = data.raw.item[effect.recipe]
        item.default_import_location = "vulcanus"
    end
end

data:extend {{
    type = "storage-tank",
    name = "maraxsis-trench-duct",
    icon = "__maraxsis__/graphics/icons/trench-duct.png",
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.8, result = "maraxsis-trench-duct"},
    fast_replaceable_group = "ducts",
    collision_box = {{-0.99, -0.99}, {0.79, 0.79}},
    selection_box = {{-1, -1}, {1, 1}},
    collision_mask = {layers = {[maraxsis_underwater_collision_mask] = true, train = true, is_object = true, is_lower_object = true}},
    tile_buildability_rules = {
        {area = {{-1, -2}, {1, -1.5}}, required_tiles = {layers = {maraxsis_underwater_collision_mask = true}}, colliding_tiles = {layers = {}}},
    },
    maraxsis_buildability_rules = {water = false, dome = false, coral = false, trench = true, trench_entrance = true, trench_lava = true},
    integration_patch_render_layer = "under-tiles",
    integration_patch = {
        north = {
            filename = "__maraxsis__/graphics/entity/trench-duct/trench-duct.png",
            width = 128,
            height = 561,
            scale = 0.5,
            shift = {-0.05, 4}
        },
        east = {
            filename = "__maraxsis__/graphics/entity/trench-duct/trench-duct.png",
            width = 128,
            height = 561,
            scale = 0.5,
            shift = {0, 4.3}
        },
        south = {
            filename = "__maraxsis__/graphics/entity/trench-duct/trench-duct.png",
            width = 128,
            height = 561,
            scale = 0.5,
            shift = {0, 4.3}
        },
        west = {
            filename = "__maraxsis__/graphics/entity/trench-duct/trench-duct.png",
            width = 128,
            height = 561,
            scale = 0.5,
            shift = {-0.1, 4.3}
        },
    },
    placeable_position_visualization = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"].placeable_position_visualization),
    surface_conditions = maraxsis.shallow_surface_conditions(),
    fluid_box = {
        volume = constants.volume * 2,
        pipe_covers = nil,
        pipe_connections = {
            {direction = defines.direction.north, connection_category = "ducts", position = {0, -0.5}},
            {
                connection_type = "linked",
                connection_category = "ducts",
                linked_connection_id = 0,
            },
        },
        hide_connection_info = true,
        max_pipeline_extent = constants.extent,
    },
    max_health = 800,
    corpse = "small-remnants",
    dying_explosion = "storage-tank-explosion",
    resistances = data.raw["pipe"]["pipe"].resistances,
    working_sound = {
        sound = {{filename = "__base__/sound/pipe.ogg", volume = 0.25}},
        match_volume_to_activity = true,
        max_sounds_per_type = 3,
    },
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    pictures = {picture = {
        north = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        east = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        south = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        west = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
    }},
    window_bounding_box = {{0, 0}, {0, 0}},
    flow_length_in_ticks = 360,
}}

data:extend {{
    type = "storage-tank",
    name = "maraxsis-trench-duct-lower",
    icon = "__maraxsis__/graphics/icons/trench-duct.png",
    hidden = true,
    factoriopedia_alternative = "maraxsis-trench-duct",
    localised_name = {"entity-name.maraxsis-trench-duct"},
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.8, result = "maraxsis-trench-duct"},
    fast_replaceable_group = "ducts",
    collision_box = {{-0.99, -0.99}, {0.79, 0.79}},
    selection_box = {{-1, -1}, {1, 1}},
    surface_conditions = maraxsis.trench_surface_conditions(),
    fluid_box = {
        volume = constants.volume * 2,
        pipe_covers = nil,
        pipe_connections = {
            {direction = defines.direction.north, connection_category = "ducts", position = {0, -0.5}},
            {
                connection_type = "linked",
                connection_category = "ducts",
                linked_connection_id = 0,
            },
        },
        hide_connection_info = true,
        max_pipeline_extent = constants.extent,
    },
    max_health = 800,
    corpse = "small-remnants",
    dying_explosion = "storage-tank-explosion",
    resistances = data.raw["pipe"]["pipe"].resistances,
    working_sound = {
        sound = {{filename = "__base__/sound/pipe.ogg", volume = 0.25}},
        match_volume_to_activity = true,
        max_sounds_per_type = 3,
    },
    vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    pictures = {picture = {
        north = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        east = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        south = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
        west = {
            layers = {
                {
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
                {
                    draw_as_shadow = true,
                    filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left-shadow.png",
                    height = 256,
                    priority = "high",
                    scale = 0.5,
                    width = 256,
                },
            },
        },
    }},
    placeable_by = {item = "maraxsis-trench-duct", count = 1},
    window_bounding_box = {{0, 0}, {0, 0}},
    flow_length_in_ticks = 360,
}}

data.raw.recipe["duct-intake"].ingredients = {
    {type = "item", name = "tungsten-plate", amount = 6},
    {type = "item", name = "pump",           amount = 1},
}

data.raw.recipe["duct-exhaust"].ingredients = {
    {type = "item", name = "tungsten-plate", amount = 6},
    {type = "item", name = "pump",           amount = 1},
}

data.raw.pump["duct-intake"].energy_source = {type = "void"}
data.raw.pump["duct-exhaust"].energy_source = {type = "void"}
data.raw.pump["non-return-duct"].energy_source = {type = "void"}
