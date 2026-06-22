local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local config = require("config")

local function create_valve(name, valve_config)
  local threshold = nil
  if valve_config.type == "overflow" or valve_config.type == "top_up" then
    -- Note: this will be overwritten during data-final-fixes anyway
    threshold = settings.startup["valves-default-threshold-"..valve_config.type].value / 100
  end

  data:extend{
      {
        type = "item",
        name = name,
        icon = "__valves__/graphics/"..valve_config.type.."/icon.png",
        subgroup = "energy-pipe-distribution",
        order = "b[pipe]-d["..name.."]",
        inventory_move_sound = item_sounds.fluid_inventory_move,
        pick_sound = item_sounds.fluid_inventory_pickup,
        drop_sound = item_sounds.fluid_inventory_move,
        place_result = name,
        stack_size = 20,
        random_tint_color = item_tints.iron_rust
      },
      {
        type = "recipe",
        name = name,
        energy_required = 2,
        ingredients = { }, -- Determined in data-updates
        results = {{type="item", name=name, amount=1}}
      },
      {
        type = "valve",
        name = name,
        icon = "__valves__/graphics/"..valve_config.type.."/icon.png",
        flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
        minable = {mining_time = 0.2, result = name},
        mode = valve_config.mode,
        threshold = threshold,
        max_health = 180,
        fast_replaceable_group = "pipe",
        corpse = "pump-remnants",
        dying_explosion = "pump-explosion",
        collision_box = {{-0.29, -0.45}, {0.29, 0.45}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        icon_draw_specification = {scale = 0.5},
        working_sound =    {
          sound = {filename = "__base__/sound/pump.ogg", volume = 0.3, audible_distance_modifier = 0.5},
          max_sounds_per_prototype = 2
        },
        damaged_trigger_effect = hit_effects.entity(),
        resistances =
        {
          {
            type = "fire",
            percent = 80
          },
          {
            type = "impact",
            percent = 30
          }
        },
        fluid_box =
        {
          volume = 400,
          pipe_covers = pipecoverspictures(),
          pipe_connections = {
            { direction = defines.direction.south, position = {0, 0}, flow_direction = "output" },
            { direction = defines.direction.north, position = {0, 0}, flow_direction = "input-output" }
          },
          hide_connection_info = true,
        },
        flow_rate = settings.startup["valves-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]
        impact_category = "metal",
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,

        animations =
        {
          north =
          {
            layers = {
              {
                filename = "__valves__/graphics/"..valve_config.type.."/north.png",
                width = 128,
                height = 128,
                scale = 0.5,
                line_length = 1,
                repeat_count = 8,
                frame_count = 1,
                animation_speed = 1,
              },
              {
                filename = "__valves__/graphics/anim/north.png",
                width = 122,
                height = 128,
                scale = 0.5,
                line_length = 8,
                frame_count = 8,
                animation_speed = 1,
              }
            },
          },
          east =
          {
            layers = {
              {
                filename = "__valves__/graphics/"..valve_config.type.."/east.png",
                width = 128,
                height = 128,
                scale = 0.5,
                line_length = 1,
                repeat_count = 8,
                frame_count = 1,
                animation_speed = 1,
              },
              {
                filename = "__valves__/graphics/anim/east.png",
                width = 112,
                height = 128,
                scale = 0.5,
                line_length = 8,
                frame_count = 8,
                animation_speed = 1,
              }
            },
          },
          south =
          {
            layers = {
              {
                filename = "__valves__/graphics/"..valve_config.type.."/south.png",
                width = 128,
                height = 128,
                scale = 0.5,
                line_length = 1,
                repeat_count = 8,
                frame_count = 1,
                animation_speed = 1,
              },
              {
                filename = "__valves__/graphics/anim/south.png",
                width = 92,
                height = 128,
                scale = 0.5,
                line_length = 8,
                frame_count = 8,
                animation_speed = 1,
              }
            },
          },
          west =
          {
            layers = {
              {
                filename = "__valves__/graphics/"..valve_config.type.."/west.png",
                width = 128,
                height = 128,
                scale = 0.5,
                line_length = 1,
                repeat_count = 8,
                frame_count = 1,
                animation_speed = 1,
              },
              {
                filename = "__valves__/graphics/anim/west.png",
                width = 102,
                height = 128,
                scale = 0.5,
                line_length = 8,
                frame_count = 8,
                animation_speed = 1,
              }
            },
          },
        },
      },
  }
end

for valve_name, valve_config in pairs(config.valves) do
  create_valve(valve_name, valve_config)
end