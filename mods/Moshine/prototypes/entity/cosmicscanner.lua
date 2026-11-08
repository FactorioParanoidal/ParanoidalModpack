local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")

local size = 14
local pipedistance = 0.5
local pipedistance2 = 0.5
local animframes = 30
local animspeed = 0.3


local make_simulation = function(name)
  return
  [[
    game.simulation.camera_position = {0, 0}
    game.simulation.camera_zoom = 0.8
    for x = -16, 16, 1 do
      for y = -8, 8 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "space-platform-foundation"}}
      end
    end

    game.surfaces[1].create_entity{name = "]]..name..[[", position = {0, 0}}

  ]]
end

 local pipe_connectors = {
  north = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_cosmicscanner_north.png",
    priority = "extra-high",
    shift = {0, 1},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  east = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_cosmicscanner_east.png",
    priority = "extra-high",
    shift = {-1, 0},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  south = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_cosmicscanner_south.png",
    priority = "extra-high",
    shift = {0, -1},
    width = 128,
    height = 128,
    scale = 0.5,
    render_layer = "object",
  },
  west = {
    filename = "__Moshine-assets__/graphics/entity/opticalfiber/opticalfiber_connector_cosmicscanner_west.png",
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
    name = "moshine_cosmicscanner-remnants",
    icon = "__Moshine__/graphics/icons/moshine_cosmicscanner.png",
    flags = {"placeable-neutral", "not-on-map", "not-rotatable"},
    hidden_in_factoriopedia = true,
    subgroup = "production-machine-remnants",
    order = "a-a-a",
    selection_box = {{-(size/2), -(size/2)}, {(size/2), (size/2)}},
    tile_width = size,
    tile_height = size,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    animation = {
      filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-remnants.png",
      priority="high",
      width = 1024,
      height = 1024,
      line_length = 1,
      direction_count = 1,
      --shift = util.by_pixel(0, -16),
      scale = 0.5
    },
  },
  {
    type = "assembling-machine",
    name = "moshine_cosmicscanner",
    icon = "__Moshine__/graphics/icons/moshine_cosmicscanner.png",
    factoriopedia_simulation = {planet = "nauvis", init = make_simulation("moshine_cosmicscanner")},
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    fixed_recipe = "cosmic-data-creation",
    disabled_when_recipe_not_researched = true,
    minable = {mining_time = 5, result = "moshine_cosmicscanner"},
    crafting_categories = {"cosmic-data-creation"},
    max_health = 1500,
    corpse = "moshine_cosmicscanner-remnants",
    dying_explosion = "assembling-machine-1-explosion",
    show_recipe_icon = false,
    icon_draw_specification = {shift = {0, 5.5}, scale = 1.5},
    icons_positioning = { {inventory_index = defines.inventory.lab_modules, shift = util.by_pixel_hr(0, 336)}, },
    surface_conditions =
    {
      {
        property = "gravity",
        max = 0,
      },
    },
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
        --pipe_covers = pipecoverspictures(),
        volume = 100000,
        --filter = "raw-data",
        pipe_connections = {
          --{flow_direction = "input", direction = defines.direction.north, position = {pipedistance, -((size/2)-0.5)}, connection_category = "data"},
          --{flow_direction = "input", direction = defines.direction.north, position = {-pipedistance, -((size/2)-0.5)}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.east, position = {((size/2)-0.5), pipedistance}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.east, position = {((size/2)-0.5), -pipedistance}, connection_category = "data"},
          --{flow_direction = "input", direction = defines.direction.south, position = {pipedistance, ((size/2)-0.5)}, connection_category = "data"},
          --{flow_direction = "input", direction = defines.direction.south, position = {-pipedistance, ((size/2)-0.5)}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.west, position = {-((size/2)-0.5), pipedistance}, connection_category = "data"},
          {flow_direction = "input", direction = defines.direction.west, position = {-((size/2)-0.5), -pipedistance}, connection_category = "data"},
        },
        --secondary_draw_orders = { north = 2 },
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
      {
        production_type = "output",
        pipe_picture = pipe_connectors,
        --pipe_picture = assembler3pipepictures(),
        --pipe_covers = pipecoverspictures(),
        volume = 100000,
        --filter = "raw-data",
        pipe_connections = {
          {flow_direction = "output", direction = defines.direction.north, position = {pipedistance2, -((size/2)-0.5)}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.north, position = {-pipedistance2, -((size/2)-0.5)}, connection_category = "data"},
          --{flow_direction = "output", direction = defines.direction.east, position = {((size/2)-0.5), pipedistance2}, connection_category = "data"},
          --{flow_direction = "output", direction = defines.direction.east, position = {((size/2)-0.5), -pipedistance2}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.south, position = {pipedistance2, ((size/2)-0.5)}, connection_category = "data"},
          {flow_direction = "output", direction = defines.direction.south, position = {-pipedistance2, ((size/2)-0.5)}, connection_category = "data"},
          --{flow_direction = "output", direction = defines.direction.west, position = {-((size/2)-0.5), pipedistance2}, connection_category = "data"},
          --{flow_direction = "output", direction = defines.direction.west, position = {-((size/2)-0.5), -pipedistance2}, connection_category = "data"},
        },
        secondary_draw_orders = { north = 2 },
        max_pipeline_extent = 1000000,
        draw_only_when_connected = true,
      },
    },
    collision_box = {{-((size/2)-0.3), -((size/2)-0.3)}, {((size/2)-0.3), ((size/2)-0.3)}},
    selection_box = {{-(size/2), -(size/2)}, {(size/2), (size/2)}},
    damaged_trigger_effect = hit_effects.entity(),
    fast_replaceable_group = "moshine_cosmicscanner",
    circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 18, main_offset = util.by_pixel_hr(128, 335), shadow_offset = util.by_pixel_hr(128, 340), show_shadow = false },
        { variation = 18, main_offset = util.by_pixel_hr(128, 335), shadow_offset = util.by_pixel_hr(128, 340), show_shadow = false },
        { variation = 18, main_offset = util.by_pixel_hr(128, 335), shadow_offset = util.by_pixel_hr(128, 340), show_shadow = false },
        { variation = 18, main_offset = util.by_pixel_hr(128, 335), shadow_offset = util.by_pixel_hr(128, 340), show_shadow = false }
      }
    ),
    alert_icon_shift = util.by_pixel_hr(0, -70),
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
            filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished.png",
            priority="high",
            width = 1024,
            height = 1024,
            repeat_count = animframes,
            line_length = 1,
            animation_speed = animspeed,
            scale = 0.5
          },
          {
            filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished-idle-animation.png",
            priority="high",
            width = 1,
            height = 1,
            frame_count = animframes,
            line_length = 8,
            animation_speed = animspeed,
            run_mode = "forward",
            scale = 0.5
          },
          {
            filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished-idle-emission.png",
            priority="high",
            width = 1,
            height = 1,
            repeat_count = animframes,
            line_length = 1,
            animation_speed = animspeed,
            draw_as_glow = true,
            blend_mode = "additive",
            scale = 0.5
          },
        }
      },
      working_visualisations =
      {
        {
          name = "lights",
          constant_speed = true,
          always_draw = true,
          draw_in_states = {"idle", "working"},
          render_layer = "higher-object-under",
          fadeout = true,
          effect = "flicker",
          apply_tint = "status",
          animation = 
          { 
            layers =
            {
              {
                filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished-emission.png",
                priority="high",
                width = 1024,
                height = 1024,
                repeat_count = animframes,
                line_length = 1,
                animation_speed = animspeed,
                draw_as_glow = true,
                blend_mode = "additive",
                scale = 0.5
              },
            }
          },
        },
        {
          name = "dome",
          constant_speed = true,
          always_draw = true,
          draw_in_states = {"idle", "working"},
          render_layer = "higher-object-above",
          animation = 
          { 
            layers =
            {
              {
                filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished-spinningdome.png",
                priority = "high",
                width = 740,
                height = 740,
                frame_count = 64,
                line_length = 8,
                animation_speed = animspeed,
                run_mode = "forward",
                --draw_as_glow = true,
                --blend_mode = "additive",
                scale = 0.5
                ---render_layer = "",
              },
            }
          },
        },
        {
          name = "pulselight",
          constant_speed = true,
          --always_draw = true,
          draw_in_states = {"working"},
          fadeout = true,
          effect = "flicker",
          frame_based_on_shift_animation_progress = false,
          apply_tint = "status",
          render_layer = "train-stop-top",
          animation = 
          { 
            layers =
            {
              {
                filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-finished-pulselight.png",
                priority = "high",
                width = 740,
                height = 740,
                frame_count = 32,
                line_length = 6,
                animation_speed = animspeed,
                run_mode = "forward-then-backward",
                draw_as_glow = true,
                blend_mode = "additive",
                scale = 0.5,
                --render_layer = "",
              },
            }
          },
        },
      },

      status_colors = {
        idle={0.1,0.1,0.1,0.1},
        no_minable_resources={0,0,0,0},
        full_output={0,0,0,0},
        insufficient_input={0.3,0.1,0.1,0.1},
        disabled={0,0,0,0},
        no_power={0.02,0.02,0.02,0.02},
        working={1,1,1,1},
        low_power={0.4,0.4,0.2,0.2},
      },
      integration_patch =
      {
        filename = "__Moshine-assets__/graphics/entity/moshine_cosmicscanner/moshine_cosmicscanner-underplatform.png",
        priority = crash_site_sprite_priority,
        width = 1024,
        height = 1772,
        scale = 0.5
      },
      integration_patch_render_layer = "background-transitions",
    },




    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      --emissions_per_minute = { pollution = 4 }
      drain = "1kW",
    },
    energy_usage = "30GW",
    --heating_energy = "200kW",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    --allowed_effects = {"speed", "consumption", "pollution"},
    --effect_receiver = {uses_module_effects = false, uses_beacon_effects = false, uses_surface_effects = true},
    module_slots = 3,
    allowed_effects = {"productivity"}, --{"speed"}, --{"consumption", "speed", "pollution", "quality"}, --"productivity"
    --allowed_module_categories = {"productivity"},
    effect_receiver = {uses_module_effects = true, speed_limits = { low = 0, high = 0 }, uses_beacon_effects = false, uses_surface_effects = false},
    --[[working_sound =
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
    },]]


    impact_category = "metal-large",
    open_sound = {filename = "__Moshine-assets__/sound/cosmic-scanner/scanner-open.ogg", volume = 0.9},
    --close_sound = {filename = "__matter_printer__/sound/zap-38.ogg", volume = 0.5},
    working_sound =
    {
      sound = {filename = "__Moshine-assets__/sound/cosmic-scanner/scanner-continuous.ogg", volume = 0.9},
      max_sounds_per_prototype = 5,
      fade_in_ticks = 20,
      fade_out_ticks = 20,
      sound_accents = {
        {
          sound = {filename = "__Moshine-assets__/sound/cosmic-scanner/scanner-repeated-sound.ogg",},
          frame = 1,
          play_for_working_visualisation = "pulselight"
        },
      },
    },
  },
})