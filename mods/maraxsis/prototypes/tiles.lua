local function default_destroyed_dropped_item_trigger()
    return {
        type = "direct",
        action_delivery = {
            type = "instant",
            source_effects = {
                type = "create-trivial-smoke",
                smoke_name = "maraxsis-swimming-bubbles",
                offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
            }
        }
    }
end

local layer = 4
local function waterifiy(tile, collision_layers)
    assert(data.raw.tile[tile], "tile not found " .. tile)
    tile = table.deepcopy(data.raw.tile[tile])
    tile.name = tile.name .. "-underwater"
    tile.layer = math.min(layer, 255)
    layer = layer + 1
    tile.fluid = tile.fluid or "maraxsis-saline-water"
    tile.map_color = maraxsis.color_combine(tile.map_color or data.raw.tile["water"].map_color, data.raw.tile["deepwater"].map_color, 0.25)
    tile.absorptions_per_second = table.deepcopy(data.raw.tile["water"].absorptions_per_second)
    tile.draw_in_water_layer = true
    tile.walking_speed_modifier = 0.2
    tile.allows_being_covered = false
    water_tile_type_names[#water_tile_type_names + 1] = tile.name

    for _, layer in pairs(collision_layers) do
        tile.collision_mask.layers[layer] = true
    end

    data:extend {tile}
    return tile
end

waterifiy("lava-hot", {maraxsis_lava_collision_mask})
data.raw.tile["lava-hot-underwater"].collision_mask.layers.rail = nil
data.raw.tile["lava-hot-underwater"].map_color = maraxsis.color_combine(data.raw.tile["lava-hot"].map_color, data.raw.tile["deepwater"].map_color, 0.6)
data.raw.tile["lava-hot-underwater"].allows_being_covered = true
waterifiy("volcanic-cracks-hot", {maraxsis_underwater_collision_mask})
waterifiy("volcanic-cracks-warm", {maraxsis_underwater_collision_mask})
waterifiy("volcanic-folds", {maraxsis_underwater_collision_mask})
waterifiy("dirt-5", {maraxsis_underwater_collision_mask})
waterifiy("sand-3", {maraxsis_underwater_collision_mask})
waterifiy("sand-2", {maraxsis_underwater_collision_mask})
waterifiy("sand-1", {maraxsis_underwater_collision_mask})
waterifiy("lowland-cream-red", {maraxsis_coral_collision_mask})
waterifiy("lowland-red-vein-2", {maraxsis_coral_collision_mask})
waterifiy("nuclear-ground", {maraxsis_underwater_collision_mask})
data.raw.tile["nuclear-ground-underwater"].localised_name = {"tile-name.nuclear-ground"}
data.raw.tile["nuclear-ground-underwater"].hidden_in_factoriopedia = true
data.raw.tile["nuclear-ground-underwater"].factoriopedia_alternative = "nuclear-ground"

data.raw.tile["lowland-cream-red-underwater"].map_color = defines.color.orange
data.raw.tile["lowland-cream-red-underwater"].searchable = true
data.raw.tile["lowland-red-vein-2-underwater"].map_color = defines.color.firebrick
data.raw.tile["lowland-red-vein-2-underwater"].localised_name = {"tile-name.lowland-cream-red-underwater"}

data:extend {maraxsis.merge(data.raw.tile["out-of-map"], {
    name = "maraxsis-trench-entrance",
    layer = 0,
    layer_group = "zero",
    effect = "maraxsis-trench",
    effect_color = {1, 0, 0},
    effect_color_secondary = {0, 68, 25},
    map_color = {0, 0, 0.1, 1},
    destroys_dropped_items = true,
    default_destroyed_dropped_item_trigger = default_destroyed_dropped_item_trigger(),
    allows_being_covered = false,
    walking_speed_modifier = 0.2,
    collision_mask = {layers = {object = true, item = true, doodad = true, resource = true, [maraxsis_trench_entrance_collision_mask] = true}},
    autoplace = {
        probability_expression = "maraxsis_trench_entrance"
    },
})}
table.insert(out_of_map_tile_type_names, "maraxsis-trench-entrance")

data:extend {maraxsis.merge(data.raw.tile["out-of-map"], {
    name = "maraxsis-trench-out-of-map",
    localised_name = {"tile-name.out-of-map"},
    hidden = true,
    factoriopedia_alternative = "out-of-map",
    effect = "nil",
})}
table.insert(out_of_map_tile_type_names, "maraxsis-trench-out-of-map")

-- https://github.com/notnotmelon/maraxsis/issues/167
data.raw.tile["maraxsis-trench-out-of-map"].collision_mask.layers.trigger_target = true
data.raw.tile["maraxsis-trench-out-of-map"].collision_mask.layers.rail = true

data:extend {{
    type = "tile-effect",
    name = "maraxsis-trench",
    shader = "space",
    space = {
        star_density = 0,
        nebula_scale = 10,
        nebula_brightness = 0.5
    }
}}

-- orange glow on the trench lava is created by lamp entities on a 4x4 tile grid.
data:extend {{
    name = "maraxsis-lava-lamp",
    type = "simple-entity",
    localised_name = {"", {"tile-name.lava"}, " (lamp)"},
    hidden = true,
    icon = data.raw.lamp["small-lamp"].icon,
    collision_mask = {layers = {}},
    icon_size = data.raw.lamp["small-lamp"].icon_size,
    picture = {
        filename = "__core__/graphics/light-medium.png",
        scale = 1.4,
        width = 300,
        height = 300,
        tint = {1, 0.3, 0},
        intensity = 0.5,
        draw_as_light = true,
    }
}}

local tile = maraxsis.merge(data.raw.tile["space-platform-foundation"], {
    name = "maraxsis-pressure-dome-tile",
    is_foundation = true,
    minable = {
        -- https://github.com/notnotmelon/maraxsis/issues/34
        mining_time = 2 ^ 63 - 1, -- weird hack needed to make this a "top" tile. top tiles require minable properties however these dome tiles actually should not be minable
        results = {},
    },
    collision_mask = {layers = {[maraxsis_dome_collision_mask] = true, ground_tile = true}},
    map_color = {r = 0.5, g = 0.5, b = 0.75},
    can_be_part_of_blueprint = false,
    layer_group = "ground-artificial",
    allows_being_covered = false,
})
tile.variants.transition = table.deepcopy(data.raw.tile["concrete"].variants.transition)
data:extend {tile}

--- We replace foundation placed on maraxsis with this.
data:extend {maraxsis.merge(data.raw.tile["foundation"], {
    name = "maraxsis-trench-foundation",
    localised_name = {"tile-name.foundation"},
    is_foundation = true,
    minable = {mining_time = 0.5, result = "foundation"},
    placeable_by = {item = "foundation", count = 1},
    -- This can only be in the trench since lava is only in the trench.
    collision_mask = {layers = {ground_tile = true, [maraxsis_underwater_collision_mask] = true}},
    hidden_in_factoriopedia = true,
    factoriopedia_alternative = "foundation",
    -- The game only saves 3 layers. This needs to stay uncoverable to prevent
    -- this case where you'd have >3:
    -- [lava, foundation, stone|concrete|etc, pressure dome]
    allows_being_covered = false,
})}

table.insert(data.raw.item["foundation"].place_as_tile.tile_condition, "lava-hot-underwater")
