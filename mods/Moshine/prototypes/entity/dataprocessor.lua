local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")
 



 local pipe_connectors = {
  north = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_north.png",
    priority = "extra-high",
    shift = {0, 1},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  east = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_east.png",
    priority = "extra-high",
    shift = {-1, 0},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  south = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_south.png",
    priority = "extra-high",
    shift = {0, -1},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  west = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_west.png",
    priority = "extra-high",
    shift = {1, 0},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
}

data:extend({
  {
    type = "corpse",
    name = "data-processor-remnants",
    icon = "__Moshine__/graphics/icons/data-processor.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "production-machine-remnants",
    order = "a-a-a",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    animation = {
      filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-remnants.png",
      priority="high",
      width = 290,
      height = 290,
      line_length = 1,
      direction_count = 1,
      shift = util.by_pixel(0, -16),
      scale = 0.5
    },
  },
  {
    type = "assembling-machine",
    name = "data-processor",
    icon = "__Moshine__/graphics/icons/data-processor.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "data-processor"},
    crafting_categories = {"data-processing"},
    max_health = 300,
    corpse = "data-processor-remnants",
    dying_explosion = "assembling-machine-1-explosion",
    icon_draw_specification = {shift = {0, 0}, scale = 0.7},
    --surface_conditions =
    --{
    --  {
    --    property = "gravity",
    --    min = 0.1,
    --  },
    --},
    resistances =
    {
      {
        type = "impact",
        percent = 10
      }
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = pipe_connectors,
        volume = 1000,
        pipe_connections = {
          {flow_direction = "input", direction = defines.direction.east, position = {1, 0}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.west, position = {-1, 0}, connection_category = "data"}
        },
        secondary_draw_orders = { east = -100 },
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
      {
        production_type = "input",
        pipe_picture = pipe_connectors,
        volume = 1000,
        pipe_connections = {
          {flow_direction = "input", direction = defines.direction.north, position = {0, -1}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.south, position = {0, 1}, connection_category = "data"},
        },
        secondary_draw_orders = { north = -100 },
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
      {
        production_type = "output",
        pipe_picture = pipe_connectors,
        volume = 1000,
        pipe_connections = {
          {flow_direction = "output", direction = defines.direction.north, position = {-1, -1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.north, position = {1, -1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.east, position = {1, 1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.south, position = {1, 1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.south, position = {-1, 1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.west, position = {-1, 1}, connection_category = "data"},
        },
        secondary_draw_orders = { north = -100, south = 100 },
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
      { -- for the connectors that are behind entity
        production_type = "output",
        pipe_picture = pipe_connectors,
        volume = 100,
        pipe_connections = {
          {flow_direction = "output", direction = defines.direction.east, position = {1, -1}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.west, position = {-1, -1}, connection_category = "data"},
        },
        secondary_draw_orders = { east = -100, west = -100},
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    fast_replaceable_group = "data-processor",
    circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = util.by_pixel(6, -12), shadow_offset = util.by_pixel(17, -6), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(6, -12), shadow_offset = util.by_pixel(17, -6), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(6, -12), shadow_offset = util.by_pixel(17, -6), show_shadow = true },
        { variation = 18, main_offset = util.by_pixel(6, -12), shadow_offset = util.by_pixel(17, -6), show_shadow = true }
      }
    ),
    alert_icon_shift = util.by_pixel(0, -12),
    graphics_set =
    {
      animation_progress = 0.15,
      always_draw_idle_animation = true,
      states =
      {
        {
          name = "idle",
          duration = 1,
          next_active = "working",
          next_inactive = "idle",
        },
        {
          name = "working",
          duration = 30,
          next_active = "working",
          next_inactive = "idle",
        },
      },
      idle_animation =
      {
        layers =
        {
          {
            filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-base.png",
            priority="high",
            width = 290,
            height = 290,
            repeat_count = 30,
            line_length = 1,
            animation_speed = 0.15,
            shift = util.by_pixel(0, -16),
            scale = 0.5,
            render_layer = "object",
          },
          {
            filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-shadow.png",
            priority="high",
            width = 400,
            height = 350,
            repeat_count = 30,
            line_length = 1,
            draw_as_shadow = true,
            animation_speed = 0.15,
            shift = util.by_pixel(0, -16),
            scale = 0.5
          },
          {
            filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-animation-1.png",
            priority="high",
            width = 160,
            height = 290,
            frame_count = 16,
            line_length = 8,
            animation_speed = 0.15,
            run_mode = "forward-then-backward",
            shift = util.by_pixel(0, -16),
            scale = 0.5
          },
          
        }
      },
      working_visualisations =
      {
        {
          name = "rotation",
          constant_speed = true,
          always_draw = true,
          draw_in_states = {"working"},
          animation = 
          { 
            layers =
            {
              {
                filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-animation-1.png",
                priority = "high",
                width = 160,
                height = 290,
                frame_count = 16,
                line_length = 8,
                animation_speed = 0.15,
                run_mode = "forward-then-backward",
                shift = util.by_pixel(0, -16),
                scale = 0.5
              },
              {
                filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-emission-2.png",
                priority = "high",
                width = 160,
                height = 290,
                frame_count = 16,
                line_length = 8,
                animation_speed = 0.15,
                run_mode = "forward-then-backward",
                draw_as_glow = true,
                blend_mode = "additive",
                shift = util.by_pixel(0, -16),
                scale = 0.5
              },
            }
          },
        },
        {
          name = "rotation2",
          apply_recipe_tint = "primary",
          constant_speed = true,
          always_draw = true,
          draw_in_states = {"working"},
          animation = 
          { 
            layers =
            {
              {
                filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-emission-1.png",
                priority = "high",
                width = 160,
                height = 290,
                frame_count = 16,
                line_length = 8,
                animation_speed = 0.15,
                run_mode = "forward-then-backward",
                draw_as_glow = true,
                blend_mode = "additive",
                shift = util.by_pixel(0, -16),
                scale = 0.5
              },
            }
          },
        },
      },
      frozen_patch =
      {
        filename = "__Moshine-assets__/graphics/entity/data-processor/suit-plug-outlet-hr-frozen.png",
        priority="high",
        width = 290,
        height = 290,
        shift = util.by_pixel(0, -16),
        scale = 0.5
      },
      reset_animation_when_frozen = true,
    },




    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 4 }
    },
    energy_usage = "350kW",
    heating_energy = "200kW",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    --allowed_effects = {"speed", "consumption", "pollution"},
    --effect_receiver = {uses_module_effects = false, uses_beacon_effects = false, uses_surface_effects = true},
    module_slots = 4,
    allowed_effects = {"speed"}, --{"consumption", "speed", "pollution", "quality"}, --"productivity"
    allowed_module_categories = {"ai-speed"},
    effect_receiver = {uses_module_effects = true, uses_beacon_effects = false, uses_surface_effects = true},
    impact_category = "metal",
    working_sound =
    {
      sound =
      {
        filename = "__Moshine-assets__/sound/data-processor/processor_buzz.ogg",
        volume = 0.7,
        modifiers = volume_multiplier("main-menu", 1.44),
        audible_distance_modifier = 0.6
      },
      match_volume_to_activity = true,
      activity_to_volume_modifiers = {offset = 2, inverted = true},
      fade_in_ticks = 4,
      fade_out_ticks = 20,
    },
  },
})