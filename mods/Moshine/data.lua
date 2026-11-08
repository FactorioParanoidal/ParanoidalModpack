data:extend({
  {
    type = "font",
    name = "moshine-data",
    from = "default-bold",
    size = 15,
    border = true,
    border_color = {0.1,0.1,0.1,1},
  }
})
require ("prototypes.items")
require ("prototypes.fluid")
require ("prototypes.recipes")
require ("prototypes.technology")

require ("prototypes_planet.terrain")
require ("prototypes_planet.decoratives")
require ("prototypes_planet.resources")
require ("prototypes_planet.planet")
require ("prototypes_planet.music")




require ("sound-util")
require ("prototypes.entity.opticalfiber")
require ("prototypes.entity.opticalfiber-storage-tank")
require ("prototypes.entity.supercomputer")
require ("prototypes.entity.dataprocessor")
require ("prototypes.entity.computerfarm")
require ("prototypes.entity.webbedprocessor")
require ("prototypes.entity.dataextractor")
require ("prototypes.entity.aitrainer")
require ("prototypes.entity.cosmicscanner-construction")
require ("prototypes.entity.cosmicscanner")

require ("prototypes.achievements")
require ("prototypes.menu-simulations")
require ("prototypes_planet.tipsandtricks")

require ("prototypes.compatibility")
--[[

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
require ("circuit-connector-sprites")

data:extend(
{
{
  type = "inserter",
  name = "no-space-inserter",
  icon = "__base__/graphics/icons/inserter.png",
  flags = {"placeable-neutral", "placeable-player", "player-creation", "placeable-off-grid"},
  minable = {mining_time = 0.1, result = "inserter"},
  max_health = 150,
  corpse = "inserter-remnants",
  dying_explosion = "inserter-explosion",
  --tile_collision_mask = { layers = { water_tile = true, }, },
  collision_mask = {
  layers = {
    object = true,
    water_tile = true,
    player = true,
  },
},
  resistances =
  {
    {
      type = "fire",
      percent = 90
    }
  },
  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
  selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
  damaged_trigger_effect = hit_effects.entity(),
  energy_per_movement = "5kJ",
  energy_per_rotation = "5kJ",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    drain = "0.4kW"
  },
  extension_speed = 0.035,
  rotation_speed = 0.014,
  filter_count = 5,
  icon_draw_specification = {scale = 0.5},
  --fast_replaceable_group = "inserter",
  --next_upgrade = "fast-inserter",
  impact_category = "metal",
  open_sound = sounds.inserter_open,
  close_sound = sounds.inserter_close,
  working_sound = sounds.inserter_basic,
  hand_base_picture =
  {
    filename = "__base__/graphics/entity/inserter/inserter-hand-base.png",
    priority = "extra-high",
    width = 32,
    height = 136,
    scale = 0.25
  },
  hand_closed_picture =
  {
    filename = "__base__/graphics/entity/inserter/inserter-hand-closed.png",
    priority = "extra-high",
    width = 72,
    height = 164,
    scale = 0.25
  },
  hand_open_picture =
  {
    filename = "__base__/graphics/entity/inserter/inserter-hand-open.png",
    priority = "extra-high",
    width = 72,
    height = 164,
    scale = 0.25
  },
  hand_base_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
    priority = "extra-high",
    width = 32,
    height = 132,
    scale = 0.25
  },
  hand_closed_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
    priority = "extra-high",
    width = 72,
    height = 164,
    scale = 0.25
  },
  hand_open_shadow =
  {
    filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
    priority = "extra-high",
    width = 72,
    height = 164,
    scale = 0.25
  },
  pickup_position = {0, -0.5},
  insert_position = {0, 0.4},
  platform_picture =
  {
    sheet =
    {
      filename = "__base__/graphics/entity/inserter/inserter-platform.png",
      priority = "extra-high",
      width = 105,
      height = 79,
      shift = util.by_pixel(1.5, 7.5-1),
      scale = 0.5
    }
  },
  circuit_connector = circuit_connector_definitions["inserter"],
  circuit_wire_max_distance = inserter_circuit_wire_max_distance,
  default_stack_control_input_signal = inserter_default_stack_control_input_signal
},
})]]