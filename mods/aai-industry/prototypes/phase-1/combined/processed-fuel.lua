local include_fuel_processor = settings.startup["aai-fuel-processor"].value
local energy_cost = 10 * 100 / (100 + settings.startup["aai-fuel-processor-efficiency"].value)
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

local processor_connections = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 18, main_offset = {-0.7, 1.15}, shadow_offset = {-0.7, 1.15}, show_shadow = true },
    { variation = 18, main_offset = {-0.7, 1.15}, shadow_offset = {-0.7, 1.15}, show_shadow = true },
    { variation = 18, main_offset = {-0.7, 1.15}, shadow_offset = {-0.7, 1.15}, show_shadow = true },
    { variation = 18, main_offset = {-0.7, 1.15}, shadow_offset = {-0.7, 1.15}, show_shadow = true },
  }
)

data:extend({
  {
    type = "recipe-category",
    name = "fuel-processing"
  },
  {
      type = "technology",
      name = "fuel-processing",
      icon = "__aai-industry__/graphics/technology/fuel-processing.png",
      icon_size = 256,
      order = "a",
      enabled = include_fuel_processor,
      hidden = not include_fuel_processor,
      prerequisites = {"automation-science-pack"},
      unit = {
          count = 10,
          ingredients = {
              {"automation-science-pack", 1},
          },
          time = 10
      },
      effects = {
       { type = "unlock-recipe", recipe = "fuel-processor" },
       { type = "unlock-recipe", recipe = "processed-fuel" },
     },
     localised_description = {"technology-description.fuel-processing", tostring(settings.startup["aai-fuel-processor-efficiency"].value)},
  },

  {
    type = "item-subgroup",
    name = "fuel-processing",
    group = "intermediate-products",
    order = "a-b"
  },

  {
    type = "fuel-category",
    name = "processed-chemical"
  },

  {
      type = "item",
      name = "processed-fuel",
      icon = "__aai-industry__/graphics/icons/processed-fuel.png",
      icon_size = 64,
      fuel_value = "10MJ", -- rocket is 100MJ, solid is 12
      subgroup = "fuel-processing",
      order = "m[rocket-fuel]-b[processed-fuel]",
      stack_size = 100, --(1000MJ) rocket is 10 (2250MJ), solid is 50(1250MK),
      fuel_category = "processed-chemical",
      fuel_acceleration_multiplier = 1.75,
      fuel_top_speed_multiplier = 1.125,
      hidden = (not include_fuel_processor),
      pick_sound = item_sounds.solid_fuel_inventory_pickup,
      drop_sound = item_sounds.solid_fuel_inventory_move,
      inventory_move_sound = item_sounds.solid_fuel_inventory_move,
  },

  {
      type = "item",
      name = "fuel-processor",
      icon = "__aai-industry__/graphics/icons/fuel-processor.png",
      icon_size = 64,
      subgroup = "smelting-machine",
      order = "z",
      place_result = "fuel-processor",
      stack_size = 50,
      hidden = (not include_fuel_processor),
      pick_sound = item_sounds.drill_inventory_pickup,
      drop_sound = item_sounds.drill_inventory_move,
      inventory_move_sound = item_sounds.drill_inventory_move,
  },
  {
      type = "recipe",
      name = "fuel-processor",
      enabled = false,
      energy_required = 4,
      ingredients =
      {
          {type = "item", name = "iron-plate", amount = 10},
          {type = "item", name = "stone-brick", amount = 10},
          {type = "item", name = "motor", amount = 1},
      },
      results = {{type = "item", name = "fuel-processor", amount = 1}},
      hidden = (not include_fuel_processor)
  },
  {
      type = "recipe",
      name = "processed-fuel",
      enabled = false,
      energy_required = 1,
      ingredients =
      {
      },
      category = "fuel-processing",
      results = {{type = "item", name = "processed-fuel", amount = 1}},
      hidden = (not include_fuel_processor)
  },
  {
      type = "assembling-machine",
      name = "fuel-processor",
      localised_description = {"entity-description.fuel-processor", tostring(settings.startup["aai-fuel-processor-efficiency"].value)},
      icon = "__aai-industry__/graphics/icons/fuel-processor.png",
      icon_size = 64,
      allowed_effects = {
        --"consumption",
        --"speed",
        --"productivity",
        "pollution"
      },
      circuit_connector = processor_connections,
      circuit_wire_max_distance = default_circuit_wire_max_distance,
      graphics_set = {
        animation = {
          layers = {
            {
              filename = "__aai-industry__/graphics/entity/fuel-processor/fuel-processor.png",
                frame_count = 1,
                repeat_count = 64,
                width = 192,
                height = 216,
                priority = "high",
                scale = 0.5,
                shift = util.by_pixel(0, -4),
            },
            {
              draw_as_shadow = true,
              filename = "__aai-industry__/graphics/entity/fuel-processor/fuel-processor-shadow.png",
              frame_count = 1,
              repeat_count = 64,
              width = 224,
              height = 142,
              priority = "high",
              scale = 0.5,
              shift = util.by_pixel(20, 12),
            },
            {
              filename = "__aai-industry__/graphics/entity/fuel-processor/fuel-processor-animation.png",
              priority = "high",
              width = 1328/8,
              height = 1008/8,
              line_length = 8,
              frame_count = 64,
              animation_speed = 1,
              shift = util.by_pixel(16 - 15, -4 + 11),
              scale = 0.5
            },
          }
        },
        working_visualisations =
        {
          {
            fadeout = true,
            animation =
            {
              filename = "__aai-industry__/graphics/entity/fuel-processor/fuel-processor-light.png",
              priority = "high",
              width = 192,
              height = 216,
              frame_count = 1,
              animation_speed = 1,
              draw_as_light = true,
              shift = util.by_pixel(0, -4),
              scale = 0.5
            }
          },
          {
            draw_as_light = true,
            fadeout = true,
            constant_speed = true,
            animation =
            {
              filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
              line_length = 10,
              width = 40,
              height = 81,
              frame_count = 60,
              animation_speed = 0.75,
              scale = 0.5,
              shift = util.by_pixel(-21, -64)
            },
          },
          {
            effect = "uranium-glow", -- changes alpha based on energy source light intensity
            light = {intensity = 0.1, size = 18, shift = {0.0, 1}, color = {r = 1, g = 0.4, b = 0.1}}
          },
        },
      },
      collision_box = { { -1.1, -1.1, }, { 1.1, 1.1 } },
      corpse = "big-remnants",
      crafting_categories = {
        "fuel-processing"
      },
      fixed_recipe = "processed-fuel",
      crafting_speed = 1,
      dying_explosion = "medium-explosion",
      energy_source = {
        emissions_per_minute = { pollution = 4 },
        type = "burner",
        fuel_inventory_size = 4,
        fuel_categories = {"chemical"},
        light_flicker =
        {
          minimum_light_size = 1,
          light_intensity_to_size_coefficient = 0.2,
          color = {1,0.6,0},
          minimum_intensity = 0.05,
          maximum_intensity = 0.2
        },
      },
      energy_usage = energy_cost.."MW", -- 9MJ per second used 10MW of fuel returned.
      fast_replaceable_group = "fuel-processor",
      flags = {
        "placeable-neutral",
        "placeable-player",
        "player-creation",
      },
      hidden = (not include_fuel_processor),
      light = {
        intensity = 1,
        size = 10
      },
      max_health = 150,
      minable = {
        mining_time = 0.2,
        result = "fuel-processor"
      },
      result_inventory_size = 1,
      selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
      source_inventory_size = 1,
      vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
      },
      open_sound = sounds.drill_open,
      close_sound = sounds.drill_close,
      working_sound = {
        sound = sound_variations("__base__/sound/burner-mining-drill", 2, 0.6, volume_multiplier("tips-and-tricks", 0.8)),
        apparent_volume = 0.8,
      },
    },
})
