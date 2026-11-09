-- trench indestructible wall

local trench_wall = maraxsis.merge(data.raw["simple-entity"]["huge-rock"], {
    name = "maraxsis-trench-wall",
    minable = "nil",
    selectable_in_game = false,
    map_color = {0, 0, 0},
    autoplace = {
        probability_expression = "maraxsis_trench_wall",
    },
    flags = {"placeable-neutral"},
    collision_box = {{-3, -3}, {3, 3}},
    selection_box = {{-3, -3}, {3, 3}},
    render_layer = "object-under",
})

for _, picture in pairs(trench_wall.pictures) do
    picture.tint = {r = 0.2, g = 0.2, b = 0.3}
    picture.scale = 1.2
end

trench_wall.icons = {
    {
        icon = trench_wall.icon,
        tint = {r = 0.2, g = 0.2, b = 0.3},
        icon_size = trench_wall.icon_size,
    }
}
trench_wall.icon = nil
trench_wall.icon_size = nil
trench_wall.collision_mask = {layers = {[maraxsis_trench_entrance_collision_mask] = true, item = true, player = true}}

data:extend {trench_wall}

local trench_wall_collisionless = table.deepcopy(trench_wall)
trench_wall_collisionless.name = "maraxsis-trench-wall-collisionless"
trench_wall_collisionless.collision_mask = {layers = {}}
trench_wall_collisionless.hidden = true
trench_wall_collisionless.localised_name = {"entity-name.maraxsis-trench-wall"}
trench_wall_collisionless.created_effect = {
    type = "direct",
    action_delivery = {
        type = "instant",
        source_effects = {
            {
                type = "script",
                effect_id = "maraxsis-trench-wall-created",
            },
        }
    }
}
data:extend {trench_wall_collisionless}

-- sulfur vent thingy

local maraxsis_chimney = table.deepcopy(data.raw["simple-entity"]["vulcanus-chimney"])
maraxsis_chimney.name = "maraxsis-chimney"
maraxsis_chimney.hidden_in_factoriopedia = true
maraxsis_chimney.map_color = {153, 166, 77}
maraxsis_chimney.localised_name = {"entity-name.vulcanus-chimney"}
data:extend {maraxsis_chimney}

-- free glass forever!

data:extend {{
    type                       = "simple-entity",
    name                       = "maraxsis-mollusk-husk",
    icon                       = "__maraxsis__/graphics/icons/mollusk-husk.png",
    icon_size                  = 64,
    flags                      = {"placeable-neutral", "placeable-off-grid"},
    minable                    = {
        mining_time = 0.2,
        results = {
            {type = "item", name = "maraxsis-glass-panes", amount_min = 35, amount_max = 45},
            {type = "item", name = "limestone",   amount_min = 20, amount_max = 30},
        },
    },
    max_health                 = 300,
    collision_box              = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box              = {{-0.9, -0.9}, {0.9, 0.9}},
    map_generator_bounding_box = {{-2.9, -2.9}, {2.9, 2.9}},
    subgroup                   = "creatures",
    order                      = "j-d[mollusk-husk]",
    pictures                   = {
        {
            filename = "__maraxsis__/graphics/entity/mollusk-husk/mollusk-husk-1.png",
            width = 163,
            height = 96,
            flags = {"no-scale"},
            scale = 0.75,
        },
        {
            filename = "__maraxsis__/graphics/entity/mollusk-husk/mollusk-husk-2.png",
            width = 163,
            height = 109,
            flags = {"no-scale"},
            scale = 0.75,
        },
        {
            filename = "__maraxsis__/graphics/entity/mollusk-husk/mollusk-husk-3.png",
            width = 129,
            height = 96,
            flags = {"no-scale"},
            scale = 0.75,
            shift = {-0.5, 0}
        },
        {
            filename = "__maraxsis__/graphics/entity/mollusk-husk/mollusk-husk-4.png",
            width = 154,
            height = 85,
            flags = {"no-scale"},
            scale = 0.75,
            shift = {0.5, 0}
        },
    },
    map_color                  = {149, 145, 108}
}}

-- sandstone

local sandstone = table.deepcopy(data.raw["simple-entity"]["big-sand-rock"])
sandstone.name = "big-sand-rock-underwater"
sandstone.map_color = maraxsis.color_combine(sandstone.map_color or data.raw.tile["water"].map_color, data.raw.tile["deepwater"].map_color, 0.3)
data:extend {sandstone}
