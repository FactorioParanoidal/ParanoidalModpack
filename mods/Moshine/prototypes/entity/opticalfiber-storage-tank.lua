local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local ENTITYPATH = "__Moshine-assets__/graphics/entity/opticalfiber-storage-tank/"
 
local size = 4
local pipedistance = 0.5


local circ_connections = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 2, main_offset = util.by_pixel(-39, -54), shadow_offset = util.by_pixel(53, 26), show_shadow = true },
    { variation = 2, main_offset = util.by_pixel(-39, -54), shadow_offset = util.by_pixel(53, 26), show_shadow = true },
    { variation = 2, main_offset = util.by_pixel(-39, -54), shadow_offset = util.by_pixel(53, 26), show_shadow = true },
    { variation = 2, main_offset = util.by_pixel(-39, -54), shadow_offset = util.by_pixel(53, 26), show_shadow = true },
  }
)

data:extend({
  {
    type = "corpse",
    name = "opticalfiber-storage-tank-remnants",
    icon = "__Moshine__/graphics/icons/opticalfiber-storage-tank.png",
    flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "storage-remnants",
    order = "a-d-a",
    selection_box = {{-(size/2), -(size/2)}, {(size/2), (size/2)}},
    tile_width = size,
    tile_height = size,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = 
    {
      filename = ENTITYPATH .. "opticalfiber-storage-tank-remnants.png",
      --line_length = 1,
      width = 384,
      height = 448,
      direction_count = 1,
      shift = util.by_pixel(0, -16),
      scale = 0.5,
    }
  },
  {
    type = "storage-tank",
    name = "opticalfiber-storage-tank",
    icon = "__Moshine__/graphics/icons/opticalfiber-storage-tank.png",
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "opticalfiber-storage-tank"},
    max_health = 200,
    corpse = "opticalfiber-storage-tank-remnants",
    dying_explosion = "storage-tank-explosion",
    collision_box = {{-((size/2)-0.3), -((size/2)-0.3)}, {((size/2)-0.3), ((size/2)-0.3)}},
    selection_box = {{-(size/2), -(size/2)}, {(size/2), (size/2)}},
    fast_replaceable_group = "opticalfiber-storage-tank",
    damaged_trigger_effect = hit_effects.entity(),
    icon_draw_specification = {scale = 0.6, shift = {0, 0}},
    tall = true,
    fluid_box =
    {
      volume = 120000,
      --pipe_covers = pipecoverspictures(),
      max_pipeline_extent = 1000000,
      pipe_connections =
      {
        { direction = defines.direction.north, position = {pipedistance, -((size/2)-0.5)}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.north, position = {-pipedistance, -((size/2)-0.5)}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.east, position = {((size/2)-0.5), pipedistance}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.east, position = {((size/2)-0.5), -pipedistance}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.south, position = {pipedistance, ((size/2)-0.5)}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.south, position = {-pipedistance, ((size/2)-0.5)}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.west, position = {-((size/2)-0.5), pipedistance}, hide_connection_info = true, connection_category = "data" },
        { direction = defines.direction.west, position = {-((size/2)-0.5), -pipedistance}, hide_connection_info = true, connection_category = "data" },
      },
    },
    two_direction_only = true,
    window_bounding_box = {util.by_pixel(-16, -29.5), util.by_pixel(16, -16.5), 0.5},
    heating_energy = "100kW",
    pictures =
    {
      picture =
      {
        layers =
        {
          {
            filename = ENTITYPATH .. "opticalfiber-storage-tank-base.png",
            priority = "extra-high",
            width = 384,
            height = 448,
            shift = util.by_pixel(0, -16),
            scale = 0.5
          },
          {
            filename = ENTITYPATH .. "opticalfiber-storage-tank-shadow.png",
            priority = "extra-high",
            width = 448,
            height = 384,
            shift = util.by_pixel(16, 0),
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = ENTITYPATH .. "opticalfiber-storage-tank-light.png",
            priority = "extra-high",
            width = 384,
            height = 448,
            shift = util.by_pixel(0, -16),
            scale = 0.5,
            draw_as_glow = true,
            blend_mode = "additive",
          }
        }
      },
      frozen_patch =
      {
        filename = "__Moshine__/graphics/opticalfiber-storage-tank-frozen.png",
        width = 384,
        height = 448,
        shift = util.by_pixel(0, -16),
        scale = 0.5
      },
      fluid_background =
      {
        filename = ENTITYPATH .. "fluid-background.png",
        priority = "extra-high",
        width = 32,
        height = 15
      },
      window_background =
      {
        filename = ENTITYPATH .. "window-background.png",
        priority = "extra-high",
        width = 64,
        height = 26,
        scale = 0.5
      },
      flow_sprite =
      {
        filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
        priority = "extra-high",
        width = 160,
        height = 20
      },
      gas_flow =
      {
        filename = ENTITYPATH .. "steam.png",
        priority = "extra-high",
        line_length = 8,
        width = 64,
        height = 26,
        frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5
      }
    },
    flow_length_in_ticks = 360,
    impact_category = "metal-large",
    open_sound = sounds.metal_large_open,
    close_sound = sounds.metal_large_close,
    working_sound =
    {
      sound = {filename = "__Moshine-assets__/sound/opticalfiber-storage-tank/hum.ogg", volume = 0.6, audible_distance_modifier = 0.5},
      match_volume_to_activity = true,
      max_sounds_per_prototype = 3
    },

    circuit_connector = circ_connections,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    default_fluid_temperature_signal = {type = "virtual", name = "signal-T"},
    water_reflection =
    {
      pictures =
      {
        filename = ENTITYPATH .. "opticalfiber-storage-tank-base-reflection.png",
        priority = "extra-high",
        width = 38,
        height = 45,
        shift = util.by_pixel(0, 32),
        variation_count = 1,
        scale = 5
      },
      rotate = false,
      orientation_to_variation = false
    }
  },
})