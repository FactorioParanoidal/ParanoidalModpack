local item_sounds = require("__base__.prototypes.item_sounds")

local compat = require("__aai-industry__.prototypes.phase-1.compatibility.compat-util")

local sand_names_to_check = compat.get_compat_sand_names()

local add_sand = true
aai_sand_name = "sand"

for _, item_name in pairs(sand_names_to_check) do
  if data.raw.item[item_name] then
    add_sand = false
    aai_sand_name = item_name
    break
  end
end

if add_sand then
  data:extend({
    {
      icon = "__aai-industry__/graphics/icons/sand.png",
      icon_size = 64,
      name = aai_sand_name,
      order = "a[wood]-b-b",
      stack_size = 200,
      subgroup = "raw-material",
      type = "item",
      pick_sound = item_sounds.landfill_inventory_pickup,
      drop_sound = item_sounds.sulfur_inventory_move,
      inventory_move_sound = item_sounds.sulfur_inventory_move,
    }
  })
end

local glass_names_to_check = compat.get_compat_glass_names()

local add_glass = true
aai_glass_name = "glass"

for _, item_name in pairs(glass_names_to_check) do
  if data.raw.item[item_name] then
    add_glass = false
    aai_glass_name = item_name
    break
  end
end

if add_glass then
  data:extend({
    {
      icon = "__aai-industry__/graphics/icons/glass.png",
      icon_size = 64,
      name = aai_glass_name,
      order = "a[wood]-b-c",
      stack_size = 100,
      subgroup = "raw-material",
      type = "item",
      pick_sound = item_sounds.grenade_inventory_pickup,
      drop_sound = item_sounds.grenade_inventory_move,
      inventory_move_sound = item_sounds.grenade_inventory_move,
    }
  })
end

data:extend({
  {
    type = "item",
    name = "stone-tablet",
    icon = "__aai-industry__/graphics/icons/stone-tablet.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "a[wood]-b[stone-tablet]",
    stack_size = 100,
    pick_sound = item_sounds.brick_inventory_pickup,
    drop_sound = item_sounds.brick_inventory_move,
    inventory_move_sound = item_sounds.brick_inventory_move,
  },
  {
    type = "item",
    name = "motor",
    icon = "__aai-industry__/graphics/icons/single-cylinder-engine.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "g[engine-unit]-a[engine]-a[small]",
    stack_size = 50,
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    inventory_move_sound = item_sounds.mechanical_inventory_move,
  },
  {
    type = "item",
    name = "electric-motor",
    icon = "__aai-industry__/graphics/icons/small-electric-motor.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "g[engine-unit]-b[motor]-a[small]",
    stack_size = 50,
    pick_sound = item_sounds.electric_large_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    inventory_move_sound = item_sounds.mechanical_inventory_move,
  },
  {
    type = "item",
    name = "small-iron-electric-pole",
    icon = "__aai-industry__/graphics/icons/small-iron-electric-pole.png",
    icon_size = 64,
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-a[small-electric-pole]",
    place_result = "small-iron-electric-pole",
    stack_size = 50,
    pick_sound = item_sounds.electric_small_inventory_pickup,
    drop_sound = item_sounds.electric_small_inventory_move,
    inventory_move_sound = item_sounds.electric_small_inventory_move,
  },
  {
    type = "item",
    name = "concrete-wall",
    icon = data.raw.item["stone-wall"].icon,
    icon_size = data.raw.item["stone-wall"].icon_size,
    order = "b[concrete-wall]-a[concrete-wall]",
    place_result = "concrete-wall",
    stack_size = 50,
    subgroup = "defensive-structure",
    pick_sound = item_sounds.concrete_inventory_pickup,
    drop_sound = item_sounds.concrete_inventory_move,
    inventory_move_sound = item_sounds.concrete_inventory_move,
  },
  {
    type = "item",
    name = "steel-wall",
    icon = "__aai-industry__/graphics/icons/steel-wall.png",
    icon_size = 64,
    order = "c[steel-wall]-a[steel-wall]",
    place_result = "steel-wall",
    stack_size = 50,
    subgroup = "defensive-structure",
    pick_sound = item_sounds.concrete_inventory_pickup,
    drop_sound = item_sounds.concrete_inventory_move,
    inventory_move_sound = item_sounds.concrete_inventory_move,
  },
  {
    type = "item",
    name = "concrete-gate",
    icon = "__aai-industry__/graphics/icons/concrete-gate.png",
    order = "b[concrete-wall]-b[concrete-gate]",
    place_result = "concrete-gate",
    stack_size = 50,
    subgroup = "defensive-structure",
    pick_sound = item_sounds.concrete_inventory_pickup,
    drop_sound = item_sounds.concrete_inventory_move,
    inventory_move_sound = item_sounds.concrete_inventory_move,
  },
  {
    type = "item",
    name = "steel-gate",
    icon = "__aai-industry__/graphics/icons/steel-gate.png",
    order = "c[steel-wall]b[steel-gate]",
    place_result = "steel-gate",
    stack_size = 50,
    subgroup = "defensive-structure",
    pick_sound = item_sounds.concrete_inventory_pickup,
    drop_sound = item_sounds.concrete_inventory_move,
    inventory_move_sound = item_sounds.concrete_inventory_move,
  },
  {
    type = "item",
    name = "burner-lab",
    icon = "__aai-industry__/graphics/icons/burner-lab.png",
    icon_size = 64,
    flags = data.raw.item.lab.flags,
    subgroup = data.raw.item.lab.subgroup,
    order = data.raw.item.lab.order,
    stack_size = data.raw.item.lab.stack_size,
    place_result = "burner-lab",
    pick_sound = item_sounds.lab_inventory_pickup,
    drop_sound = item_sounds.lab_inventory_move,
    inventory_move_sound = item_sounds.lab_inventory_move,
  },
  {
    type = "item",
    name = "burner-assembling-machine",
    icon = "__aai-industry__/graphics/icons/burner-assembling-machine.png",
    icon_size = 64,
    flags = data.raw.item["assembling-machine-1"].flags,
    subgroup = data.raw.item["assembling-machine-1"].subgroup,
    order = data.raw.item["assembling-machine-1"].order .. "-a",
    stack_size = data.raw.item["assembling-machine-1"].stack_size,
    place_result = "burner-assembling-machine",
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    inventory_move_sound = item_sounds.mechanical_inventory_move,
  },
  {
    type = "item",
    name = "burner-turbine",
    icon = "__aai-industry__/graphics/icons/burner-turbine.png",
    icon_size = 64,
    subgroup = "energy",
    order = "a-a",
    place_result = "burner-turbine",
    stack_size = 50,
    pick_sound = item_sounds.steam_inventory_pickup,
    drop_sound = item_sounds.steam_inventory_move,
    inventory_move_sound = item_sounds.steam_inventory_move,
  },
})

data.raw.item["assembling-machine-1"].order = data.raw.item["assembling-machine-1"].order .. "-b"
data.raw.item["gate"].icon = "__aai-industry__/graphics/icons/stone-gate.png"
data.raw.item["gate"].order = "a[stone-wall]-b[stone-gate]"
