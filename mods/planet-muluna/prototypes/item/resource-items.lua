-- local anorthite=table.deepcopy(data.raw["item"]["metallic-asteroid-chunk"])

local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")

-- anorthite.name="anorthite"
-- anorthite.order=anorthite.order .. "a"
-- anorthite.type="item"

Muluna:extend{{
    type = "item",
    name = "anorthite-chunk",
    icon="__muluna-graphics__/graphics/icons/anorthite-chunk.png",
    subgroup = "space-material",
    order = "a[metallic]-f[chunk]",
    inventory_move_sound = space_age_item_sounds.rock_inventory_move,
    pick_sound = space_age_item_sounds.rock_inventory_pickup,
    drop_sound = space_age_item_sounds.rock_inventory_move,
    stack_size = 1,
    weight = 100 * kg,
    random_tint_color = item_tints.iron_rust
  },
  {
    type = "item", --Processed either in crusher or in recycler
    name = "muluna-lunar-regolith",
    icon="__muluna-graphics__/graphics/icons/lunar-regolith.png",
    pictures = {
      {size=64, filename="__muluna-graphics__/graphics/icons/lunar-regolith.png", scale=0.5},
      {size=64, filename="__muluna-graphics__/graphics/icons/lunar-regolith-2.png", scale=0.5},
      {size=64, filename="__muluna-graphics__/graphics/icons/lunar-regolith-3.png", scale=0.5},
      {size=64, filename="__muluna-graphics__/graphics/icons/lunar-regolith-4.png", scale=0.5}
    },
    icon_size = 64,
    subgroup = "space-material",
    order = "a[metallic]-g[chunk]",
    inventory_move_sound = space_age_item_sounds.rock_inventory_move,
    pick_sound = space_age_item_sounds.rock_inventory_pickup,
    drop_sound = space_age_item_sounds.rock_inventory_move,
    stack_size = 50,
    weight = 2 * kg,
    random_tint_color = item_tints.iron_rust
  },
  
}

--Muluna:extend{{anorthite}}