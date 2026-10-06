local shared = require("prototypes.shared")
local recipe = require("prototypes.recipe-util")

local base_icon = "__base__/graphics/icons/"
local overlay = shared.tank_equipment_icon
local prototypes = {}

local function add(...)
  for _, prototype in pairs({...}) do table.insert(prototypes, prototype) end
end

local function item(name, icons, subgroup, order, stack_size)
  return {
    type = "item",
    name = name,
    icons = icons,
    place_as_equipment_result = name,
    subgroup = subgroup,
    order = order,
    stack_size = stack_size
  }
end

local function shape(size_x, size_y)
  return {width = size_x, height = size_y or size_x, type = "full"}
end

-- Portable reactors 2x2 and 3x3 (armor grid), in Beta 8 unlocked together with the 4x4 reactor.
local reactor_sprite = data.raw["generator-equipment"]["fission-reactor-equipment"].sprite
for _, spec in pairs({
  {name = "fusion-reactor-2-equipment", size = 2, power = "150kW", tint = {r = 0.4, g = 0.4, b = 0.4, a = 1},
   ingredients = {{"processing-unit", 60}, {"low-density-structure", 15}}},
  {name = "fusion-reactor-3-equipment", size = 3, power = "400kW", tint = {r = 0.7, g = 0.7, b = 0.7, a = 1},
   ingredients = {{"processing-unit", 120}, {"low-density-structure", 30}}},
}) do
  add(
    item(spec.name, {{icon = base_icon .. "fission-reactor-equipment.png", tint = spec.tint}}, "equipment", "a[energy-source]-b[fusion-reactor]", 20),
    {
      type = "generator-equipment",
      name = spec.name,
      sprite = table.deepcopy(reactor_sprite),
      shape = shape(spec.size),
      energy_source = {type = "electric", usage_priority = "primary-output"},
      power = spec.power,
      categories = {"armor"}
    },
    recipe({name = spec.name, time = 10, ingredients = spec.ingredients})
  )
end

if shared.setting("vehicle-energy-shield-enable") then
  for _, spec in pairs({
    {name = "vehicle-energy-shield-equipment", base = "energy-shield-equipment", shield = 150, buffer = "180kJ", flow = "360kW",
     per_shield = "20kJ", order = "a[shield]-v[vehicle]-a[energy-shield-equipment]",
     ingredients = {{"energy-shield-equipment", 5}, {"electric-engine-unit", 10}}},
    {name = "vehicle-energy-shield-mk2-equipment", base = "energy-shield-mk2-equipment", shield = 450, buffer = "270kJ", flow = "540kW",
     per_shield = "30kJ", order = "a[shield]-v[vehicle]-b[energy-shield-equipment-mk2]",
     ingredients = {{"vehicle-energy-shield-equipment", 10}, {"processing-unit", 10}}},
  }) do
    add(
      item(spec.name, {{icon = base_icon .. spec.base .. ".png"}, overlay}, "military-equipment", spec.order, 20),
      {
        type = "energy-shield-equipment",
        name = spec.name,
        sprite = table.deepcopy(data.raw["energy-shield-equipment"][spec.base].sprite),
        shape = shape(2),
        max_shield_value = spec.shield,
        energy_source = {type = "electric", buffer_capacity = spec.buffer, input_flow_limit = spec.flow, usage_priority = "primary-input"},
        energy_per_shield = spec.per_shield,
        categories = {"vehicle"}
      },
      recipe({name = spec.name, time = 10, ingredients = spec.ingredients})
    )
  end
end

if shared.setting("vehicle-battery-enable") then
  for _, spec in pairs({
    {name = "vehicle-battery-equipment", buffer = "60MJ", flow = "600MW", order = "b[battery]-v[vehicle]-a[battery-equipment]",
     ingredients = {{"battery-equipment", 5}, {"electric-engine-unit", 10}}},
    {name = "vehicle-battery-mk2-equipment", buffer = "300MJ", flow = "3GW", order = "b[battery]-v[vehicle]-b[battery-equipment-mk2]",
     ingredients = {{"vehicle-battery-equipment", 10}, {"processing-unit", 20}}},
  }) do
    add(
      item(spec.name, {{icon = shared.icons .. spec.name .. ".png"}, overlay}, "equipment", spec.order, 20),
      {
        type = "battery-equipment",
        name = spec.name,
        sprite = {filename = shared.MOD .. "/graphics/equipment/" .. spec.name .. ".png", width = 32, height = 64, priority = "medium"},
        shape = shape(1, 2),
        energy_source = {type = "electric", buffer_capacity = spec.buffer, input_flow_limit = spec.flow, output_flow_limit = spec.flow, usage_priority = "tertiary"},
        categories = {"vehicle"}
      },
      recipe({name = spec.name, time = 10, ingredients = spec.ingredients})
    )
  end
end

local function burner_generator(spec)
  return {
    type = "generator-equipment",
    name = spec.name,
    sprite = spec.sprite,
    shape = shape(spec.size),
    energy_source = {type = "electric", usage_priority = "secondary-output"},
    burner = spec.burner,
    power = spec.power,
    categories = {"vehicle"}
  }
end

if shared.setting("vehicle-fuel-cell-enable") then
  local cell_sprite = {filename = "__base__/graphics/technology/electric-engine.png", size = 256, priority = "medium"}
  for _, spec in pairs({
    {size = 2, power = "400kW", effectivity = 0.8, slots = 1, time = 10, tint = {r = 0.4, g = 0.4, b = 0.4, a = 1},
     ingredients = {{"steam-engine", 1}, {"electric-engine-unit", 10}}},
    {size = 3, power = "1000kW", effectivity = 0.9, slots = 2, time = 20, tint = {r = 0.7, g = 0.7, b = 0.7, a = 1},
     ingredients = {{"vehicle-fuel-cell-2-equipment", 4}}},
    {size = 4, power = "2000kW", effectivity = 1, slots = 3, time = 30,
     ingredients = {{"vehicle-fuel-cell-3-equipment", 3}}},
  }) do
    local name = "vehicle-fuel-cell-" .. spec.size .. "-equipment"
    add(
      item(name, {{icon = shared.icons .. "vehicle-fuel-cell.png", icon_size = 128, tint = spec.tint}, overlay},
        "equipment", "a[energy-source]-v[vehicle]-b[fuel-cell]-" .. spec.size, 10),
      burner_generator({
        name = name, size = spec.size, power = spec.power, sprite = table.deepcopy(cell_sprite),
        burner = {type = "burner", fuel_categories = {"chemical"}, effectivity = spec.effectivity, fuel_inventory_size = spec.slots}
      }),
      recipe({name = name, time = spec.time, ingredients = spec.ingredients})
    )
  end
end

if shared.setting("vehicle-nuclear-reactor-enable") then
  local name = "vehicle-nuclear-reactor-equipment"
  add(
    item(name, {{icon = base_icon .. "nuclear-reactor.png", tint = {r = 0.7, g = 0.7, b = 0.7, a = 1}}, overlay},
      "equipment", "a[energy-source]-v[vehicle]-e[nuclear-reactor]", 10),
    burner_generator({
      name = name, size = 4, power = "20MW",
      sprite = {filename = "__base__/graphics/entity/nuclear-reactor/reactor.png", width = 302, height = 318, priority = "medium"},
      burner = {type = "burner", fuel_categories = {"nuclear"}, effectivity = 0.5, fuel_inventory_size = 1, burnt_inventory_size = 1}
    }),
    recipe({name = name, time = 60, ingredients = {{"nuclear-reactor", 1}}})
  )
end

data:extend(prototypes)
