local data_util = require("data-util")
require("__base__.prototypes.entity.pipecovers")
require("__base__.prototypes.entity.assemblerpipes")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

--amd makes no sense with space age... theyre literally the same building lol
if not settings.startup["aai-wide-drill"].value or mods["space-age"] then return end

data:extend({
  {
    type = "item",
    name = "area-mining-drill",
    icon = "__aai-industry__/graphics/icons/area-mining-drill.png",
    icon_size = 64,
    subgroup = data.raw.item["electric-mining-drill"].subgroup,
    order = data.raw.item["electric-mining-drill"].order.."-b",
    stack_size = 50,
    place_result = "area-mining-drill",
    pick_sound = item_sounds.drill_inventory_pickup,
    drop_sound = item_sounds.drill_inventory_move,
    inventory_move_sound = item_sounds.drill_inventory_move,
  },
  {
    type = "recipe",
    name = "area-mining-drill",
    category = "crafting",
    enabled = false,
    energy_required = 4,
    ingredients = {
      {type="item", name="electric-mining-drill", amount=1},
      {type="item", name="steel-plate", amount=20},
      {type="item", name="electric-engine-unit", amount=8},
      {type="item", name="processing-unit", amount=4},
    },
    results= { {type="item", name="area-mining-drill", amount=1} },
  },
  {
    type = "technology",
    name = "area-mining-drill",
    icon = "__aai-industry__/graphics/technology/area-mining-drill.png",
    icon_size = 256,
    order = "b",
    prerequisites = {
      "electric-mining-drill",
      "production-science-pack",
      "processing-unit",
      "electric-engine",
    },
    unit = {
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
        },
        time = 30
    },
    effects = {
      { type = "unlock-recipe", recipe = "area-mining-drill" }
    },
  },
})




electric_drill_animation_speed = 0.4
electric_drill_animation_sequence =
{
  1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1
}

electric_drill_animation_shadow_sequence =
{
  1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
  21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1
}

function electric_mining_drill_smoke()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-smoke.png",
    line_length = 6,
    width = 48,
    height = 72,
    frame_count = 30,
    animation_speed = electric_drill_animation_speed,
    direction_count = 1,
    shift = util.by_pixel(0, 3),
    scale = 0.5,
  }
end

function electric_mining_drill_smoke_front()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-smoke-front.png",
    line_length = 6,
    width = 148,
    height = 132,
    frame_count = 30,
    animation_speed = electric_drill_animation_speed,
    direction_count = 1,
    shift = util.by_pixel(-3, 9),
    scale = 0.5,
  }
end

function electric_mining_drill_animation()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill.png",
    line_length = 6,
    width = 194,
    height = 154,
    frame_count = 30,
    animation_speed = electric_drill_animation_speed,
    frame_sequence = electric_drill_animation_sequence,
    direction_count = 1,
    shift = util.by_pixel(0, -21),
    scale = 0.5,
  }
end

function electric_mining_drill_shadow_animation()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-shadow.png",
    line_length = 7,
    width = 232,
    height = 50,
    frame_count = 21,
    animation_speed = electric_drill_animation_speed,
    frame_sequence = electric_drill_animation_shadow_sequence,
    draw_as_shadow = true,
    shift = util.by_pixel(49, 7),
    scale = 0.5,
  }
end

function electric_mining_drill_horizontal_animation()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-horizontal.png",
    line_length = 6,
    width = 104,
    height = 178,
    frame_count = 30,
    animation_speed = electric_drill_animation_speed,
    frame_sequence = electric_drill_animation_sequence,
    direction_count = 1,
    shift = util.by_pixel(-3, -27),
    scale = 0.5,
  }
end

function electric_mining_drill_horizontal_front_animation()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-horizontal-front.png",
    line_length = 6,
    width = 54,
    height = 136,
    frame_count = 30,
    animation_speed = electric_drill_animation_speed,
    frame_sequence = electric_drill_animation_sequence,
    direction_count = 1,
    shift = util.by_pixel(14, -23),
    scale = 0.5,
  }
end

function electric_mining_drill_horizontal_shadow_animation()
  return
  {
    priority = "high",
    filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-horizontal-shadow.png",
    line_length = 7,
    width = 236,
    height = 138,
    frame_count = 21,
    animation_speed = electric_drill_animation_speed,
    frame_sequence = electric_drill_animation_shadow_sequence,
    draw_as_shadow = true,
    shift = util.by_pixel(48, 5),
    scale = 0.5,
  }
end

function electric_mining_drill_status_colors()
  return
  {
    -- If no_power, idle, no_minable_resources, disabled, insufficient_input or full_output is used, always_draw of corresponding layer must be set to true to draw it in those states.

    no_power = { 0, 0, 0, 0 },                  -- If no_power is not specified or is nil, it defaults to clear color {0,0,0,0}

    idle = { 1, 0, 0, 1 },                      -- If idle is not specified or is nil, it defaults to white.
    no_minable_resources = { 1, 0, 0, 1 },      -- If no_minable_resources, disabled, insufficient_input or full_output are not specified or are nil, they default to idle color.
    insufficient_input = { 1, 1, 0, 1 },
    full_output = { 1, 1, 0, 1 },
    disabled = { 1, 1, 0, 1 },

    working = { 0, 1, 0, 1 },                   -- If working is not specified or is nil, it defaults to white.
    low_power = { 1, 1, 0, 1 },                 -- If low_power is not specified or is nil, it defaults to working color.
  }
end

function electric_mining_drill_status_leds_working_visualisation()
  local led_blend_mode = nil -- "additive"
  local led_tint = {1,1,1,0.5}
  return
  {
    apply_tint = "status",
    always_draw = true,
    ---draw_as_sprite = true,
    draw_as_light = true,
    north_animation =
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-light.png",
      width = 30,
      height = 32,
      blend_mode = led_blend_mode,
      tint = led_tint,
      shift = util.by_pixel(26, -69),
      scale = 0.5,
    },
    east_animation =
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-light.png",
      width = 32,
      height = 34,
      blend_mode = led_blend_mode,
      tint = led_tint,
      shift = util.by_pixel(41, -45),
      scale = 0.5,
    },
    south_animation =
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-light.png",
      width = 32,
      height = 30,
      blend_mode = led_blend_mode,
      tint = led_tint,
      shift = util.by_pixel(26, 10),
      scale = 0.5,
    },
    west_animation =
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-light.png",
      width = 32,
      height = 34,
      blend_mode = led_blend_mode,
      tint = led_tint,
      shift = util.by_pixel(-42, -45),
      scale = 0.5,
    }
  }
end

function electric_mining_drill_add_light_offsets(t)
  t.north_position = { 1.0 - 11/64, -2.0 - 10/64}
  t.east_position =  { 1.5 - 13/64, -1.5 +  8/64}
  t.south_position = { 1.0 - 10/64,  0.5 - 12/64}
  t.west_position =  {-1.5 + 13/64, -1.5 +  7/64}
  return t
end

local electric_mining_drill_secondary_light =
  electric_mining_drill_add_light_offsets(
  {
    always_draw = true,
    apply_tint = "status",
    light = { intensity = 0.2, size = 3, color={r=1, g=1, b=1}, minimum_darkness = 0.01 }
  })


data:extend(
{
  {
    type = "mining-drill",
    name = "area-mining-drill",
    icon = "__aai-industry__/graphics/icons/area-mining-drill.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.3, result = "area-mining-drill"},
    max_health = 300,
    resource_categories = {"basic-solid"},
    corpse = "area-mining-drill-remnants",
    dying_explosion = "electric-mining-drill-explosion",
    collision_box = {{ -2.25, -2.25}, {2.25, 2.25}},
    selection_box = {{ -2.5, -2.5}, {2.5, 2.5}},
    damaged_trigger_effect = hit_effects.entity(),
    input_fluid_box =
    {
      pipe_picture = assembler2pipepictures(),
      pipe_covers = pipecoverspictures(),
      volume = 200,
      pipe_connections =
      {
        { position = {-2, 0}, direction=defines.direction.west },
        { position = {2, 0}, direction=defines.direction.east },
        { position = {0, 2}, direction=defines.direction.south }
      }
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/electric-mining-drill.ogg",
        volume = 0.5
      },
      audible_distance_modifier = 0.6,
      fade_in_ticks = 4,
      fade_out_ticks = 20,
    },
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.drill_open,
    close_sound = sounds.drill_close,

    graphics_set =
    {
      drilling_vertical_movement_duration = 10 / electric_drill_animation_speed,
      animation_progress = 1,
      min_animation_progress = 0,
      max_animation_progress = 30,

      status_colors = electric_mining_drill_status_colors(),

      circuit_connector_layer = "object",
      circuit_connector_secondary_draw_order = { north = 14, east = 26, south = 26, west = 26 },

      animation =
      {
        north =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N.png",
              line_length = 1,
              width = 194,
              height = 242,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -12),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-output.png",
              line_length = 5,
              width = 72,
              height = 66,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-1, -44),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-shadow.png",
              line_length = 1,
              width = 274,
              height = 206,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(19, -3),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        east =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E.png",
              line_length = 1,
              width = 194,
              height = 94,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -33),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-output.png",
              line_length = 5,
              width = 50,
              height = 56,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(30, -11),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-shadow.png",
              line_length = 1,
              width = 276,
              height = 170,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(20, 6),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        south =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S.png",
              line_length = 1,
              width = 194,
              height = 240,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -7),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-shadow.png",
              line_length = 1,
              width = 274,
              height = 204,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(19, 2),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        west =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W.png",
              line_length = 1,
              width = 194,
              height = 94,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -33),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-output.png",
              line_length = 5,
              width = 50,
              height = 56,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-31, -12),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-shadow.png",
              line_length = 1,
              width = 282,
              height = 170,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(15, 6),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
      },

      shift_animation_waypoints =
      {
        -- Movement should be between 0.3-0.5 distance
        -- Bounds -0.7 - 0.6
        north = { {0, 0}, {0, 0.4}, {0, 0.1}, {0, -0.25}, {0, -0.5}, {0, -0.2}, {0, 0}, {0, -0.4}, {0, -0.1}, {0, 0.2}, {0, 0.6}, {0, 0.3}, {0, -0.1}, {0, -0.4}, {0, 0}, {0, 0.3} },
        -- Bounds -0.6 - 0.4
        east = { {0, 0}, {0.4, 0}, {0.1, 0}, {-0.3, 0}, {-0.6, 0}, {-0.2, 0}, {0.1, 0}, {-0.3, 0}, {0, 0}, {-0.35, 0}, {-0.6, 0}, {-0.2, 0}, {0.1, 0}, {-0.3, 0} },
        -- Bounds -0.7 - 0.5
        south = { {0, 0}, {0, -0.4}, {0, -0.1}, {0, 0.2}, {0, 0.5}, {0, 0.3}, {0, 0}, {0, 0.4}, {0, 0.1}, {0, -0.2}, {0, -0.6}, {0, -0.3}, {0, 0.1}, {0, 0.4}, {0, 0}, {0, -0.3} },
        -- Bounds -0.4 - 0.6
        west = { {0, 0}, {-0.4, 0}, {-0.1, 0}, {0.3, 0}, {0.6, 0}, {0.2, 0}, {-0.1, 0}, {0.3, 0}, {0, 0}, {0.35, 0}, {0.6, 0}, {0.2, 0}, {-0.1, 0}, {0.3, 0} },
      },

      shift_animation_waypoint_stop_duration = 195 / electric_drill_animation_speed,
      shift_animation_transition_duration = 30 / electric_drill_animation_speed,

      working_visualisations =
      {
        -- dust animation 1
        {
          constant_speed = true,
          synced_fadeout = true,
          align_to_waypoint = true,
          apply_tint = "resource-color",
          animation = electric_mining_drill_smoke(),
          north_position = { 0, 0.25 },
          east_position = { 0, 0 },
          south_position = { 0, 0.25 },
          west_position = { 0, 0 },
        },

        -- dust animation directional 1
        {
          constant_speed = true,
          fadeout = true,
          apply_tint = "resource-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-smoke.png",
                line_length = 5,
                width = 46,
                height = 58,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(1, -44),
                scale = 0.5,
              }
            }
          },
          east_animation = nil,
          south_animation = nil,
          west_animation = nil,
        },

        -- drill back animation
        {
          animated_shift = true,
          always_draw = true,
          north_animation =
          {
            layers =
            {
              electric_mining_drill_animation(),
              electric_mining_drill_shadow_animation()
            }
          },
          east_animation =
          {
            layers =
            {
              electric_mining_drill_horizontal_animation(),
              electric_mining_drill_horizontal_shadow_animation()
            }
          },
          south_animation =
          {
            layers =
            {
              electric_mining_drill_animation(),
              electric_mining_drill_shadow_animation()
            }
          },
          west_animation =
          {
            layers =
            {
              electric_mining_drill_horizontal_animation(),
              electric_mining_drill_horizontal_shadow_animation()
            }
          },
        },

        -- dust animation 2
        {
          constant_speed = true,
          synced_fadeout = true,
          align_to_waypoint = true,
          apply_tint = "resource-color",
          animation = electric_mining_drill_smoke_front(),
          north_position = { 0, 0.25 },
          east_position = { 0, 0 },
          south_position = { 0, 0.25 },
          west_position = { 0, 0 },
        },

        -- dust animation directional 2
        {
          constant_speed = true,
          fadeout = true,
          apply_tint = "resource-color",
          north_animation = nil,
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-smoke.png",
                line_length = 5,
                width = 52,
                height = 56,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(25, -12),
                scale = 0.5,
              }
            }
          },
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-smoke.png",
                line_length = 5,
                width = 48,
                height = 36,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-2, 20),
                scale = 0.5,
              }
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-smoke.png",
                line_length = 5,
                width = 46,
                height = 54,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-25, -11),
                scale = 0.5,
              }
            }
          }
        },

        -- front frame
        {
          always_draw = true,
          north_animation = nil,
          east_animation =
          {
            priority = "high",
            filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-front.png",
            line_length = 1,
            width = 208,
            height = 186,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(3, 2),
            scale = 0.5,
          },
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-output.png",
                line_length = 5,
                width = 82,
                height = 56,
                frame_count = 5,
                animation_speed = electric_drill_animation_speed,
                shift = util.by_pixel(-1, 34),
                scale = 0.5,
              },
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-front.png",
                line_length = 1,
                width = 172,
                height = 42,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                repeat_count = 5,
                shift = util.by_pixel(0, 13),
                scale = 0.5,
              },
            }
          },
          west_animation =
          {
            priority = "high",
            filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-front.png",
            line_length = 1,
            width = 210,
            height = 190,
            frame_count = 1,
            animation_speed = electric_drill_animation_speed,
            direction_count = 1,
            shift = util.by_pixel(-4, 1),
            scale = 0.5,
          }
        },

        -- drill front animation
        {
          animated_shift = true,
          always_draw = true,
          --north_animation = util.empty_sprite(),
          east_animation = electric_mining_drill_horizontal_front_animation(),
          --south_animation = util.empty_sprite(),
          west_animation = electric_mining_drill_horizontal_front_animation(),
        },

        -- LEDs
        electric_mining_drill_status_leds_working_visualisation(),

        -- light
        {
          always_draw = true,
          --apply_tint = "status",
          light =  {
            intensity = 0.3,
            size = 10,
            color={r=1, g=1, b=1},
            minimum_darkness = 0.01
          },
          north_position = { 0, -1},
          east_position =  { 0, -1},
          south_position = { 0, -1},
          west_position =  { 0, -1},
        },
        electric_mining_drill_secondary_light
      }
    },

    wet_mining_graphics_set =
    {
      drilling_vertical_movement_duration = 10 / electric_drill_animation_speed,
      animation_progress = 1,
      min_animation_progress = 0,
      max_animation_progress = 30,

      status_colors = electric_mining_drill_status_colors(),

      circuit_connector_layer = "object",
      circuit_connector_secondary_draw_order = { north = 14, east = 44, south = 44, west = 44 },

      animation =
      {
        north =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet.png",
              line_length = 1,
              width = 214, -- 194
              height = 242,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -12),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-output.png",
              line_length = 5,
              width = 72,
              height = 66,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-1, -44),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-shadow.png",
              line_length = 1,
              width = 276,
              height = 222,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(19, 1),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        west =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet.png",
              line_length = 1,
              width = 194,
              height = 94,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -33),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-output.png",
              line_length = 5,
              width = 50,
              height = 56,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(-31, -12),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet-shadow.png",
              line_length = 1,
              width = 284,
              height = 194,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(15, 8),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        south =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet.png",
              line_length = 1,
              width = 216, --194
              height = 240, --240
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -7),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet-shadow.png",
              line_length = 1,
              width = 276,
              height = 204,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(19, 2),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
        east =
        {
          layers =
          {
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet.png",
              line_length = 1,
              width = 194,
              height = 94,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(0, -33),
              repeat_count = 5,
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-output.png",
              line_length = 5,
              width = 50,
              height = 56,
              frame_count = 5,
              animation_speed = electric_drill_animation_speed,
              direction_count = 1,
              shift = util.by_pixel(30, -11),
              scale = 0.5,
            },
            {
              priority = "high",
              filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet-shadow.png",
              line_length = 1,
              width = 276,
              height = 194,
              frame_count = 1,
              animation_speed = electric_drill_animation_speed,
              draw_as_shadow = true,
              shift = util.by_pixel(20, 8),
              repeat_count = 5,
              scale = 0.5,
            }
          }
        },
      },

      shift_animation_waypoints =
      {
        -- Movement should be between 0.3-0.5 distance
        -- Bounds -0.5 - 0.6
        north = { {0, 0}, {0, 0.4}, {0, 0.1}, {0, -0.25}, {0, -0.5}, {0, -0.2}, {0, 0}, {0, -0.4}, {0, -0.1}, {0, 0.2}, {0, 0.6}, {0, 0.3}, {0, -0.1}, {0, -0.4}, {0, 0}, {0, 0.3} },
        -- Bounds -0.4 - 0.4
        east = { {0, 0}, {0.4, 0}, {0, 0}, {-0.25, 0}, {-0.4, 0}, {-0.2, 0}, {0.1, 0}, {-0.3, 0}, {0, 0}, {-0.35, 0}, {-0.1, 0}, {-0.2, 0}, {0.1, 0}, {-0.3, 0} },
        -- Bounds -0.7 - 0.5
        south = { {0, 0}, {0, -0.4}, {0, -0.1}, {0, 0.2}, {0, 0.5}, {0, 0.3}, {0, 0}, {0, 0.4}, {0, 0.1}, {0, -0.2}, {0, -0.6}, {0, -0.3}, {0, 0.1}, {0, 0.4}, {0, 0}, {0, -0.3} },
        -- Bounds -0.4 - 0.4
        west = { {0, 0}, {-0.4, 0}, {-0, 0}, {0.25, 0}, {0.4, 0}, {0.2, 0}, {-0.1, 0}, {0.3, 0}, {0, 0}, {0.35, 0}, {0.1, 0}, {0.2, 0}, {-0.1, 0}, {0.3, 0} },
      },

      shift_animation_waypoint_stop_duration = 195 / electric_drill_animation_speed,
      shift_animation_transition_duration = 30 / electric_drill_animation_speed,

      working_visualisations =
      {
        -- dust animation 1
        {
          constant_speed = true,
          synced_fadeout = true,
          align_to_waypoint = true,
          apply_tint = "resource-color",
          animation = electric_mining_drill_smoke(),
          north_position = { 0, 0.25 },
          east_position = { 0, 0 },
          south_position = { 0, 0.25 },
          west_position = { 0, 0 },
        },

        -- dust animation directional 1
        {
          constant_speed = true,
          fadeout = true,
          apply_tint = "resource-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-smoke.png",
                line_length = 5,
                width = 46,
                height = 58,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(1, -44),
                scale = 0.5,
              }
            }
          },
          east_animation = nil,
          south_animation = nil,
          west_animation = nil
        },

        -- drill back animation
        {
          animated_shift = true,
          always_draw = true,
          north_animation =
          {
            layers =
            {
              electric_mining_drill_animation(),
              electric_mining_drill_shadow_animation()
            }
          },
          east_animation =
          {
            layers =
            {
              electric_mining_drill_horizontal_animation(),
              electric_mining_drill_horizontal_shadow_animation()
            }
          },
          south_animation =
          {
            layers =
            {
              electric_mining_drill_animation(),
              electric_mining_drill_shadow_animation()
            }
          },
          west_animation =
          {
            layers =
            {
              electric_mining_drill_horizontal_animation(),
              electric_mining_drill_horizontal_shadow_animation()
            }
          },
        },

        -- dust animation 2
        {
          constant_speed = true,
          synced_fadeout = true,
          align_to_waypoint = true,
          apply_tint = "resource-color",
          animation = electric_mining_drill_smoke_front(),
        },

        -- dust animation directional 2
        {
          constant_speed = true,
          fadeout = true,
          apply_tint = "resource-color",
          north_animation = nil,
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-smoke.png",
                line_length = 5,
                width = 52,
                height = 56,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(25, -12),
                scale = 0.5,
              }
            }
          },
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-smoke.png",
                line_length = 5,
                width = 48,
                height = 36,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-2, 20),
                scale = 0.5,
              }
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-smoke.png",
                line_length = 5,
                width = 46,
                height = 54,
                frame_count = 10,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-25, -11),
                scale = 0.5,
              }
            }
          }
        },

        -- fluid window background (bottom)
        {
          -- render_layer = "lower-object-above-shadow",
          secondary_draw_order = -49,
          always_draw = true,
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-window-background-front.png",
                line_length = 1,
                width = 132,
                height = 28,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-1, -18),
                scale = 0.5,
              },
            }
          },
          east_animation = nil,
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet-window-background.png",
                line_length = 1,
                width = 132,
                height = 88,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-1, -33),
                scale = 0.5,
              },
            }
          },
          west_animation = nil,
        },

        -- fluid window background (front)
        {
          always_draw = true,
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-window-background.png",
                line_length = 1,
                width = 30,
                height = 20,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(1, 21),
                scale = 0.5,
              },
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet-window-background-front.png",
                line_length = 1,
                width = 88,
                height = 86,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(11, 0),
                scale = 0.5,
              }
            }
          },
          south_animation = nil,
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet-window-background-front.png",
                line_length = 1,
                width = 86,
                height = 86,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-12, 0),
                scale = 0.5,
              },
            }
          },
        },
        -- fluid base (bottom)
        {
          always_draw = true,
          -- render_layer = "lower-object-above-shadow",
          secondary_draw_order = -48,
          apply_tint = "input-fluid-base-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-fluid-background-front.png",
                line_length = 1,
                width = 130,
                height = 36,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(0, -17),
                scale = 0.5,
              },
            }
          },
          east_animation = nil,
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet-fluid-background.png",
                line_length = 1,
                width = 130,
                height = 96,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(0, -32),
                scale = 0.5,
              },
            }
          },
          west_animation = nil
        },

        -- fluid base (front)
        {
          always_draw = true,
          apply_tint = "input-fluid-base-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-fluid-background.png",
                line_length = 1,
                width = 28,
                height = 22,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(2, 21),
                scale = 0.5,
              },
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet-fluid-background-front.png",
                line_length = 1,
                width = 82,
                height = 88,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(12, -1),
                scale = 0.5,
              }
            }
          },
          south_animation = nil,
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet-fluid-background-front.png",
                line_length = 1,
                width = 82,
                height = 88,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-12, -1),
                scale = 0.5,
              },
            }
          },
        },

        -- fluid flow (bottom)
        {
          --render_layer = "lower-object-above-shadow",
          secondary_draw_order = -47,
          always_draw = true,
          apply_tint = "input-fluid-flow-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-fluid-flow-front.png",
                line_length = 1,
                width = 130,
                height = 28,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-2, -17),
                scale = 0.5,
              },
            }
          },
          east_animation = nil,
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet-fluid-flow.png",
                line_length = 1,
                width = 130,
                height = 88,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-2, -32),
                scale = 0.5,
              },
            }
          },
          west_animation = nil,
        },

        -- fluid flow (front)
        {
          always_draw = true,
          apply_tint = "input-fluid-flow-color",
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-fluid-flow.png",
                line_length = 1,
                width = 26,
                height = 20,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(2, 22),
                scale = 0.5,
              },
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet-fluid-flow-front.png",
                line_length = 1,
                width = 84,
                height = 86,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(11, 0),
                scale = 0.5,
              }
            }
          },
          south_animation = nil,
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet-fluid-flow-front.png",
                line_length = 1,
                width = 82,
                height = 86,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-12, 0),
                scale = 0.5,
              },
            }
          },
        },

        -- front frame (wet)
        {
          always_draw = true,
          north_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-wet-front.png",
                line_length = 1,
                width = 162,
                height = 124,
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-2, 20),
                scale = 0.5,
              },
            }
          },
          west_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-wet-front.png",
                line_length = 1,
                width = 230, --210
                height = 198, -- 190
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(-4, 1),
                scale = 0.5,
              }
            }
          },
          south_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-output.png",
                line_length = 5,
                width = 82,
                height = 56,
                frame_count = 5,
                animation_speed = electric_drill_animation_speed,
                shift = util.by_pixel(-1, 34),
                scale = 0.5,
              },
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-wet-front.png",
                line_length = 1,
                width = 192, --192
                height = 70, --70
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                repeat_count = 5,
                shift = util.by_pixel(0, 19),
                scale = 0.5,
              },
            }
          },
          east_animation =
          {
            layers =
            {
              {
                priority = "high",
                filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-wet-front.png",
                line_length = 1,
                width = 228, --208
                height = 194, --186
                frame_count = 1,
                animation_speed = electric_drill_animation_speed,
                direction_count = 1,
                shift = util.by_pixel(3, 2),
                scale = 0.5,
              },
            }
          },
        },

        -- drill front animation
        {
          animated_shift = true,
          always_draw = true,
          --north_animation = util.empty_sprite(),
          east_animation = electric_mining_drill_horizontal_front_animation(),
          --south_animation = util.empty_sprite(),
          west_animation = electric_mining_drill_horizontal_front_animation(),
        },

        -- LEDs
        electric_mining_drill_status_leds_working_visualisation(),

        electric_mining_drill_secondary_light
      }
    },

    integration_patch =
    {
      north =
      {
        priority = "high",
        filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-N-integration.png",
        line_length = 1,
        width = 230,
        height = 236,
        frame_count = 1,
        animation_speed = electric_drill_animation_speed,
        direction_count = 1,
        shift = util.by_pixel(0, -2),
        repeat_count = 5,
        scale = 0.5,
      },
      east =
      {
        priority = "high",
        filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-E-integration.png",
        line_length = 1,
        width = 238,
        height = 204,
        frame_count = 1,
        animation_speed = electric_drill_animation_speed,
        direction_count = 1,
        shift = util.by_pixel(2, 5),
        repeat_count = 5,
        scale = 0.5,
      },
      south =
      {
        priority = "high",
        filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-S-integration.png",
        line_length = 1,
        width = 224,
        height = 228,
        frame_count = 1,
        animation_speed = electric_drill_animation_speed,
        direction_count = 1,
        shift = util.by_pixel(0, -2),
        repeat_count = 5,
        scale = 0.5,
      },
      west =
      {
        priority = "high",
        filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-W-integration.png",
        line_length = 1,
        width = 234,
        height = 202,
        frame_count = 1,
        animation_speed = electric_drill_animation_speed,
        direction_count = 1,
        shift = util.by_pixel(-3, 5),
        repeat_count = 5,
        scale = 0.5,
      }
    },

    mining_speed = 1,
    energy_source =
    {
      type = "electric",
      emissions_per_minute = { pollution = 20 },
      usage_priority = "secondary-input"
    },
    energy_usage = "500kW",
    resource_searching_radius = 5.49,
    vector_to_place_result = {0, -2.85},
    module_slots = 5,
    radius_visualisation_picture =
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/area-mining-drill-radius-visualization.png",
      width = 10,
      height = 10
    },
    monitor_visualization_tint = {r=78, g=173, b=255},
    fast_replaceable_group = "area-mining-drill",
    circuit_connector = circuit_connector_definitions["electric-mining-drill"],
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    allowed_effects = {"consumption", "speed",  "pollution", "productivity", "quality"},
  },
  {
    type = "corpse",
    name = "area-mining-drill-remnants",
    icon = "__aai-industry__/graphics/icons/area-mining-drill.png",
    icon_size = 64,
    hidden_in_factoriopedia = true,
    flags = {"placeable-neutral", "not-on-map"},
    subgroup = "extraction-machine-remnants",
    order = "a-a-a",
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet (4,
    {
      filename = "__aai-industry__/graphics/entity/area-mining-drill/remnants/area-mining-drill-remnants.png",
      line_length = 1,
      width = 356,
      height = 328,
      frame_count = 1,
      variation_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = util.by_pixel(7, -0.5),
      scale = 0.5,
    })
  },
})
local amd = data.raw["mining-drill"]["area-mining-drill"]
local amdr = data.raw["corpse"]["area-mining-drill-remnants"]
local function scale_recursive(table, scale)
  for k, v in pairs(table) do
    if k == "width" then
      table.scale = (table.scale or 1) * scale
    elseif k == "shift" then
      table[k] = {v[1]*scale, v[2]*scale + 4/32}
    elseif type(v) == "table" then
      scale_recursive(v, scale)
    end
  end
end
for _, table in pairs({amd.integration_patch, amd.graphics_set, amd.wet_mining_graphics_set, amdr.animation}) do
  scale_recursive(table, 1.5)
end
local function table_shift(table, shift)
  for k, v in pairs(table) do
    if k == "shift" or k == "green" or k == "red" then
      table[k] = {v[1] + shift[1], v[2] + shift[2]}
    elseif type(v) == "table" then
      table_shift(v, shift)
    end
  end
end

for _, table in pairs({amd.circuit_connector[1].points, amd.circuit_connector[1].sprites}) do
  table_shift(table, {-0.5,-1.5}) -- N
end
for _, table in pairs({amd.circuit_connector[2].points, amd.circuit_connector[2].sprites}) do
  table_shift(table, {0.65,-0.55}) -- E
end
for _, table in pairs({amd.circuit_connector[3].points, amd.circuit_connector[3].sprites}) do
  table_shift(table, {1-1.5,-0.1}) -- S
end
for _, table in pairs({amd.circuit_connector[4].points, amd.circuit_connector[4].sprites}) do
  table_shift(table, {-0.58,-0.4}) -- W
end
