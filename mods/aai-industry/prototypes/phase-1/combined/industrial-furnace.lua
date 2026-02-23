local data_util = require("data-util")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

local furnace_connections = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 18, main_offset = {1, 2.1}, shadow_offset = {1.2, 2}, show_shadow = true },
    { variation = 18, main_offset = {1, 2.1}, shadow_offset = {1.2, 2}, show_shadow = true },
    { variation = 18, main_offset = {1, 2.1}, shadow_offset = {1.2, 2}, show_shadow = true },
    { variation = 18, main_offset = {1, 2.1}, shadow_offset = {1.2, 2}, show_shadow = true },
  }
)

local function pipepictures()
  return {
    east ={
      filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-pipe-h.png",
      width = 128,
      height = 128,
      shift = {-1,0},
      scale = 0.5
    },
    north = {
      filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-pipe-n.png",
      width = 128,
      height = 128,
      shift = util.by_pixel(0, 24),
      scale = 0.5
    },
    south = {
      filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-pipe-s.png",
      width = 64,
      height = 32,
      shift = util.by_pixel(0, -24),
      scale = 0.5
    },
    west = {
      filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-pipe-h.png",
      width = 128,
      height = 128,
      shift = {1,0},
      scale = 0.5
    },
  }
end
data:extend({
  {
    type = "item",
    name = "industrial-furnace",
    icon = "__aai-industry__/graphics/icons/industrial-furnace.png",
    icon_size = 64,
    subgroup = "smelting-machine",
    order = "c[electric-furnace]-b",
    stack_size = 20,
    place_result = "industrial-furnace",
    pick_sound = item_sounds.metal_large_inventory_pickup,
    drop_sound = item_sounds.metal_large_inventory_move,
    inventory_move_sound = item_sounds.metal_large_inventory_move,
  },
  {
    type = "recipe",
    name = "industrial-furnace",
    category = "crafting",
    enabled = false,
    energy_required = 7,
    ingredients = {
      {type="item", name="steel-plate", amount=16},
      {type="item", name="concrete", amount=8},
      {type="item", name="processing-unit", amount=4},
      {type="item", name="electric-furnace", amount=1},
    },
    results= { {type="item", name="industrial-furnace", amount=1} },
  },
  {
    type = "technology",
    name = "industrial-furnace",
    icon = "__aai-industry__/graphics/technology/industrial-furnace.png",
    icon_size = 256,
    order = "a",
    prerequisites = {
      "production-science-pack",
      "processing-unit",
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
      { type = "unlock-recipe", recipe = "industrial-furnace" }
    },
  },
  {
    type = "assembling-machine",
    name = "industrial-furnace",
    icon = "__aai-industry__/graphics/icons/industrial-furnace.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.3, result = "industrial-furnace"},
    max_health = 1200,
    corpse = "big-remnants",
    alert_icon_shift = util.by_pixel(0, -12),
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -2.9}, {2.5, 2.5}},
    circuit_connector = furnace_connections,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    resistances =
    {
      { type = "impact", percent = 30 },
      { type = "fire", percent = 30 },
    },
    open_sound = sounds.electric_large_open,
    close_sound = sounds.electric_large_close,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      idle_sound = {
        filename = "__base__/sound/idle1.ogg",
        volume = 0.6
      },
      apparent_volume = 1.5,
      fade_in_ticks = 10,
      fade_out_ticks = 60,
      max_sounds_per_type = 2,
      sound = {
        filename = "__base__/sound/electric-furnace.ogg",
        volume = 0.7
      }
    },
    graphics_set = {
      animation =
      {
        layers =
        {
          {
            filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace.png",
            priority = "high",
            width = 350,
            height = 370,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, -5),
            animation_speed = 0.125,
            scale = 0.5,
          },
          {
            draw_as_shadow = true,
            filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-shadow.png",
            priority = "high",
            width = 370,
            height = 268,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 21),
            animation_speed = 0.125,
            scale = 0.5,
          },
        },
      },
      working_visualisations =
      {
        {
          animation = {
            layers = { -- these are not lights, they need to cover the static propeller
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(-1, -64-11),
                width = 38
              },
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(-0.5, -32-8),
                width = 38
              },
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(0, -6),
                width = 38
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-heater.png",
                frame_count = 12,
                height = 56,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(0, 65),
                width = 60
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-light.png",
                priority = "high",
                width = 350,
                height = 370,
                frame_count = 1,
                line_length = 1,
                shift = util.by_pixel(0, -5),
                animation_speed = 0.125,
                scale = 0.5,
                blend_mode = "additive",
              },
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-vents.png",
                frame_count = 1,
                width = 46,
                height = 66,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(-32-16-5, -32-16+4),
                blend_mode = "additive",
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(-1, -64-11),
                width = 38
              },
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(-0.5, -32-8),
                width = 38
              },
              {
                animation_speed = 0.125,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(0, -6),
                width = 38
              },
            }
          }
        },
        {
          fadeout = true,
          animation =
          {
            filename = "__aai-industry__/graphics/entity/industrial-furnace/industrial-furnace-ground-light.png",
            blend_mode = "additive",
            width = 166,
            height = 124,
            shift = util.by_pixel(3, 69+32),
            scale = 0.5,
            draw_as_light = true,
          },
        },
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.1, size = 18, shift = {0.0, 1}, color = {r = 1, g = 0.4, b = 0.1}}
        },
      },
    },
    crafting_categories = {
      "smelting",
      --"chemistry" -- only to test fluid connections
    },
    crafting_speed = 4,
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    dying_explosion = "electric-furnace-explosion",
    energy_source = {
      emissions_per_minute = { pollution = 1.5 },
      type = "electric",
      usage_priority = "secondary-input",
      light_flicker =
      {
        minimum_light_size = 5,
        color = {1,0.3,0},
        minimum_intensity = 0.6,
        maximum_intensity = 0.95
      },
    },
    energy_usage = "500kW",
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="input", position = {-1, -2}, direction=defines.direction.north }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "input",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="input", position = {1, -2}, direction=defines.direction.north }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "input",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="input", position = {-2, -1}, direction=defines.direction.west }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "input",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="input", position = {2, -1}, direction=defines.direction.east }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "output",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="output", position = {-1, 2}, direction=defines.direction.south }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "output",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="output", position = {1, 2}, direction=defines.direction.south }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "output",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="output", position = {2, 1}, direction=defines.direction.east }},
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
      {
        production_type = "output",
        pipe_picture = pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ flow_direction ="output", position = {-2, 1}, direction=defines.direction.west }}, -- west south
        secondary_draw_orders = { north = -1, east = -1, west = -1 }
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    ingredient_count = 12,
    module_slots = 5,
    allowed_effects = {"consumption", "speed",  "pollution", "productivity", "quality"}, -- not "productivity",

    water_reflection =
    {
      pictures =
      {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-reflection.png",
        priority = "extra-high",
        width = 24,
        height = 24,
        shift = util.by_pixel(5, 40),
        variation_count = 1,
        scale = 7
      },
      rotate = false,
      orientation_to_variation = false
    }
  },
})
