if not settings.startup["sp-enable-spiderling"].value then
  return
end

local item_sounds = require("__base__.prototypes.item_sounds")

local factoriopedia_spiderling = {
  init =
  [[
    game.simulation.camera_zoom = 1.3
    game.simulation.camera_position = {0, -1}
    game.surfaces[1].create_entity{name = "sp-spiderling", position = {0, 0}}
  ]]
}

create_spidertron{
  name = "sp-spiderling",
  scale = 0.7,
  leg_scale = 0.75, -- relative to scale
  leg_thickness = 1.2, -- relative to leg_scale
  leg_movement_speed = 0.62,
  factoriopedia_simulation = factoriopedia_spiderling,
}

local spiderling = data.raw["spider-vehicle"]["sp-spiderling"]
spiderling = util.merge{
  spiderling,
  {
    icon = "__SpidertronPatrols__/graphics/icons/spiderling.png",
    icon_size = 64,
    inventory_size = 30,  -- default = 80
    torso_rotation_speed = 0.007,  -- default = 0.005
    torso_bob_speed = 1.2,  -- default = 1
    height = spiderling.height * 1.3,
    chunk_exploration_radius = 2,  -- default = 3
    minable = {result = "sp-spiderling"},
    max_health = 1000,  -- default = 3000
    minimap_representation = {scale = 0.3},  -- default = 0.5
    automatic_weapon_cycling = false,
    chain_shooting_cooldown_modifier = 1,  -- default 0.5, has no effect because automatic_weapon_cycling = false
    equipment_grid = "sp-spiderling-equipment-grid",
  }
}
spiderling.guns = {"sp-spiderling-rocket-launcher"}
if settings.startup["sp-spiderling-requires-fuel"].value == "Yes" then
  spiderling.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = 1,
    fuel_inventory_size = 1,
  }
  spiderling.movement_energy_consumption = "250kW"
  spiderling.alert_icon_shift = {0, 0}
end
data.raw["spider-vehicle"]["sp-spiderling"] = spiderling

data:extend{
  util.merge{
    data.raw["gun"]["spidertron-rocket-launcher-2"],
    {
      name = "sp-spiderling-rocket-launcher",
      attack_parameters = {
        range = 24,  -- default = 36
        cooldown = 120,  -- default = 60 (ticks)
      }
    }
  }
}
data.raw["gun"]["sp-spiderling-rocket-launcher"].localised_name = nil

local spiderling_item = {
  type = "item-with-entity-data",
  name = "sp-spiderling",
  icon = "__SpidertronPatrols__/graphics/icons/spiderling.png",
  icon_tintable = "__SpidertronPatrols__/graphics/icons/spiderling-tintable.png",
  icon_tintable_mask = "__SpidertronPatrols__/graphics/icons/spiderling-tintable-mask.png",
  icon_size = 64,
  subgroup = "transport",
  order = "b[personal-transport]-c[spidertron]-a[[spiderling]",
  inventory_move_sound = item_sounds.spidertron_inventory_move,
  pick_sound = item_sounds.spidertron_inventory_pickup,
  drop_sound = item_sounds.spidertron_inventory_move,
  place_result = "sp-spiderling",
  weight = 0.5 * tons,
  stack_size = 1
}

local spiderling_recipe = {
  type = "recipe",
  name = "sp-spiderling",
  enabled = false,
  energy_required = 5,
  ingredients =
  {
    {type="item", name="exoskeleton-equipment", amount=4},
    {type="item", name="rocket-launcher", amount=1},
    {type="item", name="low-density-structure", amount=40},
    {type="item", name="radar", amount=1},
    {type="item", name="efficiency-module-2", amount=2},
    {type="item", name="raw-fish", amount=1}
  },
  results = {{type="item", name="sp-spiderling", amount=1}},
}

data:extend{spiderling_item, spiderling_recipe}
