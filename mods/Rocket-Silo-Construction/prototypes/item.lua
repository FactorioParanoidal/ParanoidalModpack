local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({

  {
    type = "item",
    name = "rsc-building-stage1",
    localised_name = {"recipe-name.rsc-building-stage2"}, 
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage1.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },
  {
    type = "item",
    name = "rsc-building-stage2",
    localised_name = {"recipe-name.rsc-building-stage2"}, 
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage2.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },
  {
    type = "item",
    name = "rsc-building-stage3",
    localised_name = {"recipe-name.rsc-building-stage2"}, 
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage3.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },  
  {
    type = "item",
    name = "rsc-building-stage4",
    localised_name = {"recipe-name.rsc-building-stage2"},
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage4.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },
  {
    type = "item",
    name = "rsc-building-stage5",
    localised_name = {"recipe-name.rsc-building-stage2"},
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage5.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },
  {
    type = "item",
    name = "rsc-building-stage6",
    localised_name = {"recipe-name.rsc-building-stage2"},
    icon = "__Rocket-Silo-Construction__/graphics/icon/stage6.png",--excavator
    icon_size = 64,
    subgroup = "raw-material",
    hidden=true,
    order = "rsc-construction",
    stack_size = 100
  },
  
  {
    type = "item",
    name = "rsc-excavation-site",
	  icons = icons_rsc,
    subgroup = "defensive-structure",
    order = "e[rocket-silo]",
    place_result = "rsc-silo-stage1",
    stack_size = 1,
    inventory_move_sound = item_sounds.mechanical_large_inventory_move,
    pick_sound = item_sounds.mechanical_large_inventory_pickup,
    drop_sound = item_sounds.mechanical_large_inventory_move,
    weight = 10 * tons
  },
  
  
})


if data.raw.item['se-rocket-launch-pad'] then
local enable_se_cargo = settings.startup["rsc-st-enable-se-cargo-silo"].value 
local enable_se_probe = settings.startup["rsc-st-enable-se-probe-silo"].value 

if enable_se_cargo then
data:extend({
  {
    type = "item",
    name = "rsc-excavation-site-serlp",
	  icons = icons_se_crs,
    subgroup = "rocket-logistics",
    order = "b",
    place_result = "rsc-silo-stage1-serlp",
    stack_size = 1,
    inventory_move_sound = item_sounds.mechanical_large_inventory_move,
    pick_sound = item_sounds.mechanical_large_inventory_pickup,
    drop_sound = item_sounds.mechanical_large_inventory_move,
  }})
  end

if enable_se_probe then
data:extend({  
  {
    type = "item",
    name = "rsc-excavation-site-sesprs",
	  icons = icons_se_sp,
    subgroup = "rocket-logistics",
    order = "b",
    place_result = "rsc-silo-stage1-sesprs",
    stack_size = 1,
    inventory_move_sound = item_sounds.mechanical_large_inventory_move,
    pick_sound = item_sounds.mechanical_large_inventory_pickup,
    drop_sound = item_sounds.mechanical_large_inventory_move,
  }   
 })
 end

end