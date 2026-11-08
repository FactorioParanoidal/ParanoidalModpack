local sounds = require("__base__/prototypes/entity/sounds")
local tile_trigger_effects = require("__base__/prototypes/tile/tile-trigger-effects")
local tile_pollution = require("__base__/prototypes/tile/tile-pollution-values")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")

local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout

local patch_for_inner_corner_of_transition_between_transition = tile_graphics.patch_for_inner_corner_of_transition_between_transition

base_tiles_util = base_tiles_util or {}
water_tile_type_names = water_tile_type_names or {}
out_of_map_tile_type_names = out_of_map_tile_type_names or {}

default_transition_group_id = default_transition_group_id or 0
water_transition_group_id = water_transition_group_id or 1
out_of_map_transition_group_id = out_of_map_transition_group_id or 2

local grass_vehicle_speed_modifier = 1.6
local dirt_vehicle_speed_modifier = 1.4
local sand_vehicle_speed_modifier = 1.8
local stone_path_vehicle_speed_modifier = 1.1
local concrete_vehicle_speed_modifier = 0.8

local landfill_build_sounds =
{
  small =
  {
    switch_vibration_data =
    {
      gain = 0.25,
      filename = "__core__/sound/landfill-small.bnvib"
    },
    variations = sound_variations("__core__/sound/landfill-small", 6, 1)
  },
  medium =
  {
    switch_vibration_data =
    {
      gain = 0.25,
      filename = "__core__/sound/landfill-medium.bnvib"
    },
    variations = sound_variations("__core__/sound/landfill-medium", 6,  0.8)
  },
  large =
  {
    switch_vibration_data =
    {
      gain = 0.25,
      filename = "__core__/sound/landfill-large.bnvib"
    },
    variations = sound_variations("__core__/sound/landfill-large", 6, 0.5)
  }
}

local concrete_tile_build_sounds =
{
  small =
  {
    switch_vibration_data =
    {
      gain = 0.25,
      filename = "__core__/sound/build-concrete-small.bnvib"
    },
    variations = sound_variations("__core__/sound/build-concrete-small", 6, 0.4)
  },
  medium =
  {
    switch_vibration_data =
    {
      gain = 0.15,
      filename = "__core__/sound/build-concrete-medium.bnvib"
    },
    variations = sound_variations("__core__/sound/build-concrete-medium", 6, 0.5)
  },
  large =
  {
    switch_vibration_data =
    {
      gain = 0.15,
      filename = "__core__/sound/build-concrete-large.bnvib"
    },
    variations = sound_variations("__core__/sound/build-concrete-large", 6, 0.5)
  }
}

local grass_sounds = sound_variations("__base__/sound/walking/grass", 10, 0.8, volume_multiplier("main-menu", 2.9))
local sand_sounds = sound_variations("__base__/sound/walking/sand", 9, 0.8, volume_multiplier("main-menu", 2.9))
local concrete_sounds = sound_variations("__base__/sound/walking/concrete", 11, 0.5)
local refined_concrete_sounds = sound_variations("__base__/sound/walking/refined-concrete", 11, 0.5)
local shallow_water_sound = sound_variations("__base__/sound/walking/shallow-water", 7, 1)
local dirt_sounds = sound_variations("__base__/sound/walking/dirt-1", 10, 0.8, volume_multiplier("main-menu", 2.9))
local tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local stone_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-stone.ogg", volume = 0.8,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}
local grass_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-grass.ogg", volume = 0.5,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}
local sand_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-sand.ogg", volume = 0.8,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}
local concrete_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-concrete.ogg", volume = 0.8,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}
local shallow_water_driving_sound =
{
  sound =
  {
    filename = "__base__/sound/driving/vehicle-surface-water-shallow.ogg", volume = 0.8,
    advanced_volume_control = {fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0 }}}}
  },
  fade_ticks = 6
}

data:extend
{
    {
        type = "tile",
        name = "gold-path",
        order = "a[artificial]-a[tier-1]-a[gold-path]",
        subgroup = "artificial-tiles",
        needs_correction = false,
        minable = {mining_time = 0.1, result = "gold-plate"},
        mined_sound = sounds.deconstruct_bricks(0.8),
        collision_mask = tile_collision_masks.ground(),
        walking_speed_modifier = 1.3,
        layer = 11,
        layer_group = "ground-artificial",
        decorative_removal_probability = 0.15,
        variants =
        {
        main =
        {
            {
            picture = "__secretas__/graphics/terrain/gold-path/gold-path-1.png",
            count = 16,
            size = 1,
            scale = 0.5
            },
            {
            picture = "__secretas__/graphics/terrain/gold-path/gold-path-2.png",
            count = 16,
            size = 2,
            probability = 0.39,
            scale = 0.5
            },
            {
            picture = "__secretas__/graphics/terrain/gold-path/gold-path-4.png",
            count = 16,
            size = 4,
            probability = 1,
            scale = 0.5
            }
        },
        transition =
        {
            overlay_layout =
            {
            inner_corner =
            {
                spritesheet = "__secretas__/graphics/terrain/gold-path/gold-path-inner-corner.png",
                count = 16,
                tile_height = 2,
                scale = 0.5
            },
            outer_corner =
            {
                spritesheet = "__secretas__/graphics/terrain/gold-path/gold-path-outer-corner.png",
                count = 8,
                tile_height = 2,
                scale = 0.5
            },
            side =
            {
                spritesheet = "__secretas__/graphics/terrain/gold-path/gold-path-side.png",
                count = 16,
                tile_height = 2,
                scale = 0.5
            },
            u_transition =
            {
                spritesheet = "__secretas__/graphics/terrain/gold-path/gold-path-u.png",
                count = 8,
                tile_height = 2,
                scale = 0.5
            },
            o_transition =
            {
                spritesheet = "__secretas__/graphics/terrain/gold-path/gold-path-o.png",
                count = 4,
                scale = 0.5
            }
            }
        }
        },
        transitions = stone_path_transitions,
        transitions_between_transitions = stone_path_transitions_between_transitions,

        walking_sound = concrete_sounds,
        driving_sound = stone_driving_sound,
        build_sound = concrete_tile_build_sounds,
        map_color={86, 82, 74},
        scorch_mark_color = {r = 0.373, g = 0.307, b = 0.243, a = 1.000},
        vehicle_friction_modifier = stone_path_vehicle_speed_modifier,

        trigger_effect = tile_trigger_effects.stone_path_trigger_effect()
    },
}

--include the tile for secretas when dea dia is installed.
if (mods["dea-dia-system"] and settings.startup["ignore-dea-dia-compatibility"].value == false) then
  require("prototypes.tile.secretas")
end