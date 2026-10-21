local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({

  {
    type = "item",
    name = "recycler-1",
    -- PLACEHOLDER icon – replace with custom art
    icon = "__recycler-progression__/graphics/icons/recycler-1.png",
    subgroup = "smelting-machine",
    order = "da[recycler-1]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,
    pick_sound = item_sounds.metal_large_inventory_pickup,
    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = "recycler-1",
    stack_size = 20,
    weight = 100 * kg,
  },

  {
    type = "item",
    name = "recycler-2",
    -- PLACEHOLDER icon – replace with custom art
    icon = "__recycler-progression__/graphics/icons/recycler-2.png",
    subgroup = "smelting-machine",
    order = "db[recycler-2]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,
    pick_sound = item_sounds.metal_large_inventory_pickup,
    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = "recycler-2",
    stack_size = 20,
    weight = 100 * kg,
  },

  {
    type = "item",
    name = "recycler-3",
    -- PLACEHOLDER icon – replace with custom art
    icon = "__recycler-progression__/graphics/icons/recycler-3.png",
    subgroup = "smelting-machine",
    order = "dc[recycler-3]",
    inventory_move_sound = item_sounds.metal_large_inventory_move,
    pick_sound = item_sounds.metal_large_inventory_pickup,
    drop_sound = item_sounds.metal_large_inventory_move,
    place_result = "recycler-3",
    stack_size = 20,
    weight = 100 * kg,
  },

})
