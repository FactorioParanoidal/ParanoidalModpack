local animations = require("prototypes.animations")
local icons = "__LootingSpaceshipWrecks__/graphics/icons/"
local impact_sound = {
  {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5},
  {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5},
  {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5},
  {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5},
  {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5}
}
local open_sound = {{filename = "__base__/sound/machine-open.ogg", volume = 0.5}}
local close_sound = {{filename = "__base__/sound/machine-close.ogg", volume = 0.5}}

data:extend({
  {
    type = "assembling-machine",
    name = "salvaged-assembling-machine",
    icon = icons .. "crash-site-assembling-machine-1-repaired.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-assembling-machine"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 50,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 70}},
    collision_box = {{-1.2, -0.7}, {1.2, 0.7}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    alert_icon_shift = util.by_pixel(-3, -12),
    graphics_set = animations.assembler,
    crafting_categories = {"crafting", "basic-crafting", "advanced-crafting"},
    crafting_speed = 0.25,
    match_animation_speed_to_activity = false,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 4}
    },
    energy_usage = "90kW",
    open_sound = table.deepcopy(open_sound),
    close_sound = table.deepcopy(close_sound),
    vehicle_impact_sound = table.deepcopy(impact_sound),
    working_sound = {
      sound = {{filename = "__base__/sound/assembling-machine-repaired-1.ogg", volume = 0.8}}
    }
  },
  {
    type = "lab",
    name = "salvaged-lab",
    icon = icons .. "crash-site-lab-repaired.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-lab"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 50,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.2, -1.2}, {2.2, 1.2}},
    selection_box = {{-2.5, -1.5}, {2.5, 1.5}},
    entity_info_icon_shift = util.by_pixel(32, 0),
    light = {intensity = 0.9, size = 12, color = {r = 1, g = 1, b = 1}, shift = {1.5, 0.5}},
    on_animation = animations.lab_on,
    off_animation = animations.lab_off,
    working_sound = {
      sound = {filename = "__base__/sound/lab.ogg", volume = 0.7},
      audible_distance_modifier = 0.7,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    vehicle_impact_sound = table.deepcopy(impact_sound),
    open_sound = table.deepcopy(open_sound),
    close_sound = table.deepcopy(close_sound),
    energy_source = {type = "electric", usage_priority = "secondary-input"},
    energy_usage = "650kW",
    researching_speed = 0.15,
    inputs = table.deepcopy(data.raw.lab.lab.inputs)
  },
  {
    type = "electric-energy-interface",
    name = "salvaged-generator",
    icon = icons .. "crash-site-generator.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-generator"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    allow_copy_paste = false,
    energy_source = {
      type = "electric",
      buffer_capacity = "15MJ",
      usage_priority = "tertiary",
      input_flow_limit = "0kW",
      output_flow_limit = "1.5MW"
    },
    energy_production = "750kW",
    energy_usage = "0kW",
    light = {intensity = 0.75, size = 6, color = {r = 1, g = 1, b = 1}, shift = {1, -140 / 64}},
    continuous_animation = true,
    animation = animations.generator,
    vehicle_impact_sound = table.deepcopy(impact_sound)
  }
})
