local item_sounds = require("__base__.prototypes.item_sounds")

local radiation_wall = table.deepcopy(data.raw["wall"]["stone-wall"])

radiation_wall.name = "radiation-wall"
radiation_wall.minable.result = "radiation-wall"

-- Apply green tint
radiation_wall.pictures.single.layers[1].tint              = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.straight_vertical.layers[1].tint   = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.straight_horizontal.layers[1].tint = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.corner_right_down.layers[1].tint   = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.corner_left_down.layers[1].tint    = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.t_up.layers[1].tint                = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.ending_right.layers[1].tint        = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.ending_left.layers[1].tint         = {r=0, g=1, b=0, a=1}
radiation_wall.pictures.filling.tint                       = {r=0, g=1, b=0, a=1}

data:extend{radiation_wall}

data:extend({
    {
        type = "item",
        name = "radiation-wall",
        icons = {
            {
                icon = "__base__/graphics/icons/wall.png",
                icon_size = 64,
                tint = {r=0, g=1, b=0, a=1} -- green tint
            }
        },
        subgroup = "defensive-structure",
        order = "a[stone-wall]-b[radiation-wall]",
        inventory_move_sound = item_sounds.concrete_inventory_move,
        pick_sound = item_sounds.concrete_inventory_pickup,
        drop_sound = item_sounds.concrete_inventory_move,
        place_result = "radiation-wall",
        stack_size = 100,
        hidden = true
    },
    {
        type = "recipe",
        name = "radiation-wall-recipe",
        category = "crafting-with-fluid",
        enabled = false,
        energy_required = 8,
        ingredients = {
            {type = "item", name = "stone-wall", amount = 4},
            {type = "item", name = "steel-plate", amount = 200},
            {type = "fluid", name = "lubricant", amount = 50}
        },
        results = {
            { type = "item", name = "radiation-wall", amount = 1 }
        }
    }
})
