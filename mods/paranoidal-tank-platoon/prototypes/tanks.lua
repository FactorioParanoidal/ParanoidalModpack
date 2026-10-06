local shared = require("prototypes.shared")
local recipe = require("prototypes.recipe-util")
local specs = require("prototypes.tank-specs")

-- Graphics, sounds and triggers come from the 2.0 tank; all gameplay fields are set explicitly below.
local base_tank = data.raw.car["tank"]

local minimap_style = shared.setting("minimap-representation")
local hide_resistances = shared.setting("vehicle-hide-resistances")

local function scale_box(box, factor)
  return {{box[1][1] * factor, box[1][2] * factor}, {box[2][1] * factor, box[2][2] * factor}}
end

local function minimap(scale)
  if minimap_style == "tank" then
    return {filename = shared.MOD .. "/graphics/entity/tank-map.png", flags = {"icon"}, size = {32, 50}, scale = 0.5 * scale}
  elseif minimap_style == "generic" then
    return {filename = shared.MOD .. "/graphics/entity/generic-map.png", flags = {"icon"}, size = 40, scale = 0.5 * scale}
  end
end

local function icons(spec, tier)
  local list = {}
  if spec.tinted_icon then
    list[1] = {icon = shared.icons .. "tank-to-tint.png", tint = spec.tint}
  else
    list[1] = {icon = "__base__/graphics/icons/tank.png", tint = spec.tint}
  end
  if tier > 0 then table.insert(list, shared.tier_icon[tier]) end
  return list
end

local function entity(spec, tier, values)
  local name = shared.tank_name(spec.class, tier)
  local tank = table.deepcopy(base_tank)
  tank.name = name
  tank.icon = nil
  tank.icons = icons(spec, tier)
  tank.localised_name = nil
  tank.localised_description = nil
  tank.minable = {mining_time = spec.mining_time, result = name}
  tank.placeable_by = nil
  tank.max_health = values.max_health
  tank.resistances = values.resistances
  tank.hide_resistances = hide_resistances
  tank.collision_box = scale_box(base_tank.collision_box, spec.scale)
  tank.selection_box = scale_box(base_tank.selection_box, spec.scale)
  if base_tank.drawing_box_vertical_extension then
    tank.drawing_box_vertical_extension = base_tank.drawing_box_vertical_extension * spec.scale
  end
  tank.effectivity = values.effectivity
  tank.braking_power = values.braking_power
  tank.consumption = values.consumption
  tank.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = values.burner_effectivity,
    fuel_inventory_size = values.fuel_inventory_size,
    smoke = table.deepcopy(base_tank.energy_source.smoke)
  }
  tank.terrain_friction_modifier = spec.terrain_friction_modifier
  tank.friction = 0.002
  tank.weight = values.weight
  tank.turret_rotation_speed = spec.turret_rotation_speed
  tank.rotation_speed = spec.rotation_speed
  tank.inventory_size = values.inventory_size
  tank.guns = table.deepcopy(spec.guns)
  tank.equipment_grid = name .. "-equipment-grid"
  tank.stop_trigger_speed = 0.1
  tank.minimap_representation = minimap(spec.scale)
  tank.selected_minimap_representation = nil

  shared.tint_sprite(tank.animation, spec.tint)
  shared.rescale_sprite(tank.animation, spec.scale)
  shared.rescale_sprite(tank.turret_animation, spec.scale)
  shared.rescale_sprite(tank.light_animation, spec.scale)
  -- LightDefinition is either a single light or a list of lights.
  local lights = tank.light and (tank.light.type and {tank.light} or tank.light) or {}
  for _, light in pairs(lights) do
    if type(light) == "table" and light.shift then
      light.shift = shared.scale_vector(light.shift, spec.scale)
    end
  end
  if tank.water_reflection then
    shared.rescale_sprite(tank.water_reflection.pictures, spec.scale)
  end
  return tank
end

local function item(spec, tier)
  local name = shared.tank_name(spec.class, tier)
  local tank_item = table.deepcopy(data.raw["item-with-entity-data"]["tank"])
  tank_item.name = name
  tank_item.icon = nil
  tank_item.icons = icons(spec, tier)
  tank_item.localised_name = nil
  tank_item.localised_description = nil
  tank_item.place_result = name
  tank_item.order = "b[personal-transport]-b[tank]-c[conventional]-" .. spec.order .. "-" .. tier
  tank_item.stack_size = 1
  return tank_item
end

local function grid(spec, tier)
  local width, height = shared.grid_size(tier)
  return {
    type = "equipment-grid",
    name = shared.tank_name(spec.class, tier) .. "-equipment-grid",
    width = math.max(width + spec.grid.width_add, 0),
    height = math.max(height + spec.grid.height_add, 0),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank"}
  }
end

local function tank_recipe(spec, tier, values)
  local ingredients = {}
  if tier > 0 then
    table.insert(ingredients, {shared.tank_name(spec.class, tier - 1), 1})
  end
  for _, ingredient in pairs(values.recipe.ingredients) do
    table.insert(ingredients, ingredient)
  end
  return recipe({name = shared.tank_name(spec.class, tier), time = values.recipe.time, ingredients = ingredients})
end

local prototypes = {}
for _, spec in pairs(specs) do
  for _, tier in pairs(shared.tiers) do
    local values = spec.tiers[tier]
    table.insert(prototypes, entity(spec, tier, values))
    table.insert(prototypes, item(spec, tier))
    table.insert(prototypes, grid(spec, tier))
    table.insert(prototypes, tank_recipe(spec, tier, values))
  end
end
data:extend(prototypes)
