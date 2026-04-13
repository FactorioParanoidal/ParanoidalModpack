local tile_trigger_effects = require("__base__/prototypes/tile/tile-trigger-effects")

if not settings.startup["aai-stone-path"].value then return end

local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout

local stone_brick_path = "stone-path"
local default_transition_group_id = data.raw["tile"][stone_brick_path].transitions_between_transitions[1].transition_group1
local water_tile_type_names = data.raw["tile"][stone_brick_path].transitions[1].to_tiles
local water_transition_group_id = data.raw["tile"][stone_brick_path].transitions[1].transition_group
local out_of_map_tile_type_names = data.raw["tile"][stone_brick_path].transitions[2].to_tiles
local out_of_map_transition_group_id = data.raw["tile"][stone_brick_path].transitions[2].transition_group

local stone_path_transitions =
{
  {
    to_tiles = water_tile_type_names,
    transition_group = water_transition_group_id,

    spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path.png",
    layout = tile_spritesheet_layout.transition_8_8_8_4_4,
    background_enabled = false,
    effect_map_layout =
    {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-stone-mask.png",
      inner_corner_count = 1,
      outer_corner_count = 1,
      side_count = 1,
      u_transition_count = 1,
      o_transition_count = 1
    }
  },
  {
    to_tiles = out_of_map_tile_type_names,
    transition_group = out_of_map_transition_group_id,
  
    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,
  
    spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-out-of-map-transition.png",
    layout = tile_spritesheet_layout.transition_4_4_8_1_1,
    mask_enabled = false
  }
}

local stone_path_transitions_between_transitions =
{
  {
    transition_group1 = default_transition_group_id,
    transition_group2 = water_transition_group_id,

    spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-transitions.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    background_enabled = false,
    effect_map_layout =
    {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-stone-to-land-mask.png",
      o_transition_count = 0
    }
  },
  {
    transition_group1 = default_transition_group_id,
    transition_group2 = out_of_map_transition_group_id,

    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,

    spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-out-of-map-transition-b.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    mask_enabled = false
  },
  {
    transition_group1 = water_transition_group_id,
    transition_group2 = out_of_map_transition_group_id,

    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,

    spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-shore-out-of-map-transition.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    mask_enabled = false,
    effect_map_layout =
    {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-stone-to-out-of-map-mask.png",
      u_transition_count = 0,
      o_transition_count = 0
    }
  }
}

data.raw.item["stone"].place_as_tile = {
  result = "rough-stone-path",
  condition_size = 1,
  condition = {layers={water_tile=true}}
}

data:extend({
  {
    type = "tile",
    name = "rough-stone-path",
    order = "a-a-a",
    subgroup = "artificial-tiles",
    needs_correction = false,
    minable = {mining_time = 0.05, result = "stone"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg", volume = 0.8},
    collision_mask = {layers = {ground_tile=true}},
    walking_speed_modifier = 1.2,
    layer = 10, --below stone brick path
    layer_group = "ground-artificial",
    decorative_removal_probability = 0.15,
    variants =
    {
      main =
      {
        {
          picture = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-1.png",
          count = 10,
          size = 1,
          scale = 0.5
        },
        {
          picture = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-2.png",
          count = 5,
          size = 2,
          probability = 0.039,
          scale = 0.5
        },
      },
      transition = {
        overlay_layout = {
          inner_corner =
          {
            spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-inner-corner.png",
            count = 5,
            tall = false,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-outer-corner.png",
            count = 5,
            tall = false,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-side.png",
            count = 10,
            tall = false,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-u.png",
            count = 2,
            tall = false,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__aai-industry__/graphics/terrain/stone-path/hr-stone-path-o.png",
            count = 2,
            scale = 0.5
          }
        }
      }
    },
    transitions = stone_path_transitions,
    transitions_between_transitions = stone_path_transitions_between_transitions,

    walking_sound = table.deepcopy(data.raw.tile[stone_brick_path].walking_sound),
    build_sound = table.deepcopy(data.raw.tile[stone_brick_path].build_sound),
    map_color={r=86, g=82, b=74},
    scorch_mark_color = {r = 0.373, g = 0.307, b = 0.243, a = 1.000},
    absorptions_per_second = {},
    vehicle_friction_modifier = 1 + (data.raw.tile[stone_brick_path].vehicle_friction_modifier - 1) / 2,

    trigger_effect = tile_trigger_effects.stone_path_trigger_effect()
  },
})
