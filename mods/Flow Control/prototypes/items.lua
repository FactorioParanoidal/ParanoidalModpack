local item_sounds = require("__base__.prototypes.item_sounds")

local pipe_subgroup = "energy-pipe-distribution"

if settings.startup["flow-control-new-group"].value then
  data:extend({
    {
      type = "item-subgroup",
      name = "pipe-distribution",
      group = "logistics",
      order = "da"
    }
  })
  pipe_subgroup = "pipe-distribution"
  data.raw.item["pipe"].subgroup = "pipe-distribution"
  data.raw.item["pipe-to-ground"].subgroup = "pipe-distribution"
  data.raw.item["pump"].subgroup = "pipe-distribution"
end

data:extend({
  {
    type = "item",
    name = "pipe-junction",
    icon = "__Flow Control__/graphics/icon/pipe-junction.png",
    icon_size = 64,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]c",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "pipe-junction",
    stack_size = 50,
    weight = 5 * kg
  },
  {
    type = "item",
    name = "pipe-elbow",
    icon = "__Flow Control__/graphics/icon/pipe-elbow.png",
    icon_size = 64,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]d",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "pipe-elbow",
    stack_size = 50,
    weight = 5 * kg
  },
  {
    type = "item",
    name = "pipe-straight",
    icon = "__Flow Control__/graphics/icon/pipe-straight.png",
    icon_size = 64,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]e",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "pipe-straight",
    stack_size = 50,
    weight = 5 * kg
  },
})