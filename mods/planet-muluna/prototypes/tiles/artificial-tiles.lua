local tile_trigger_effects = require("__space-age__.prototypes.tile.tile-trigger-effects")
local tile_pollution = require("__space-age__.prototypes.tile.tile-pollution-values")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")

local space_platform_tile_animations = require("__space-age__.prototypes.tile.platform-tile-animations")

local base_sounds = require("__base__/prototypes/entity/sounds")
local base_tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local space_age_tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local tile_graphics = require("__base__/prototypes/tile/tile-graphics")

data.raw["tile"]["space-platform-foundation"].decorative_removal_probability = 1

local animation_speed = 0.5

local animation =
{
  north =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/north",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/north-lights",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  east =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/east",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/east-lights",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  south =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/south",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/south-lights",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  west =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/west",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/west-lights",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  }
}
local top_animation =
{
  north =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/north-top",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/north-lights-top",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  east =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/east-top",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/east-lights-top",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  south =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/south-top",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/south-lights-top",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  },
  west =
  {
    layers =
    {
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/west-top",{
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      }),
      util.sprite_load("__muluna-graphics__/graphics/terrain/low-density-space-platform/tile-animations/west-lights-top",{
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 64,
        scale = 0.5,
        animation_speed = animation_speed
      })
    }
  }
}

local low_density_space_platform_foundation = {
    type = "tile",
    name = "low-density-space-platform-foundation",
    order = "a[artificial]-d[utility]-ba[low-density-space-platform-foundation]",
    localised_name = {"item-name.low-density-space-platform-foundation"},
    subgroup = "artificial-tiles",
    minable = {mining_time = 0.5, result = "low-density-space-platform-foundation"},
    mined_sound = base_sounds.deconstruct_bricks(0.8),
    is_foundation = true,
    allows_being_covered = false,
    decorative_removal_probability = 1,
    max_health = 100,
    weight = 100,
    collision_mask = tile_collision_masks.ground(),
    layer = 14,
    -- layer_group = "ground-artificial" -- should space-platform-foundation be in the ground-artifical group?

    -- transitions = landfill_transitions,
    -- transitions_between_transitions = landfill_transitions_between_transitions,
    dying_explosion = "space-platform-foundation-explosion",
    trigger_effect = tile_trigger_effects.landfill_trigger_effect(),

     bound_decoratives =
     {
       "low-density-space-platform-decorative-pipes-2x1",
       "low-density-space-platform-decorative-pipes-1x2",
       "low-density-space-platform-decorative-pipes-1x1",
      -- "low-density-space-platform-decorative-4x4",
      "low-density-space-platform-decorative-2x2",
       "low-density-space-platform-decorative-1x1",
       "low-density-space-platform-decorative-tiny",
    },

    build_animations = top_animation,
    build_animations_background = animation,
    built_animation_frame = 32,

    sprite_usage_surface = "space",
    variants =
    {
      main =
      {
        {
          picture = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-1x1.png",
          count = 16,
          size = 1,
          scale = 0.5
        },
        {
          picture = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-2x2.png",
          count = 16,
          size = 2,
          probability = 0.75,
          scale = 0.5
        },
      },
      transition =
      {
        --background_layer_offset = 1,
        --background_layer_group = "zero",
        --offset_background_layer_by_tile_layer = true,
        draw_background_layer_under_tiles = true,
        --outer_corner_variations_in_group = 8,
        side_variations_in_group = 16,
        double_side_variations_in_group = 4,

        overlay_layout =
        {
          inner_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-inner-corner.png",
            count = 16,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-outer-corner.png",
            count = 16,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-side.png",
            count = 32,
            scale = 0.5
          },
          double_side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-double-side.png",
            count = 8,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-u.png",
            count = 4,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-o.png",
            count = 1,
            scale = 0.5
          }
        },
        background_layout =
        {
          inner_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-inner-corner-background.png",
            count = 16,
            scale = 0.5,
            tile_height = 8
          },
          outer_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-outer-corner-background.png",
            count = 16,
            scale = 0.5,
            tile_height = 8
          },
          side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-side-background.png",
            count = 32,
            scale = 0.5,
            tile_height = 8
          },
          double_side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-double-side-background.png",
            count = 8,
            scale = 0.5,
            tile_height = 8
          },
          u_transition =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-u-background.png",
            count = 4,
            scale = 0.5,
            tile_height = 8
          },
          o_transition = nil
        },
        mask_layout =
        {
          inner_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-inner-corner-mask.png",
            count = 16,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-outer-corner-mask.png",
            count = 16,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-side-mask.png",
            count = 32,
            scale = 0.5
          },
          double_side =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-double-side-mask.png",
            count = 8,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-u-mask.png",
            count = 4,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__muluna-graphics__/graphics/terrain/low-density-space-platform/space-platform-o-mask.png",
            count = 1,
            scale = 0.5
          }
        }
      },

      -- material_background =
      -- {
      --   picture = "__space-age__/graphics/terrain/space-platform/space-platform.png",
      --   count = 8,
      --   scale = 0.5
      -- }
    },

    walking_sound = base_tile_sounds.walking.concrete,
    build_sound = space_age_tile_sounds.building.space_platform,
    map_color = {79, 81, 83},
    scorch_mark_color = {r = 0.373, g = 0.307, b = 0.243, a = 1.000}
  }

local gravel = table.deepcopy(data.raw["tile"]["stone-path"])


gravel.name = "muluna-gravel"
gravel.walking_speed_modifier=1.0 --Equal to walking on regular ground. Useless everywhere but Muluna
gravel.layer = gravel.layer - 1
gravel.minable.result = "muluna-breccia"
gravel.map_color = {45,45,45}
gravel.variants = tile_variations_template(
    "__muluna-graphics__/graphics/terrain/gravel/Xander Mod - sheet.png", "__base__/graphics/terrain/masks/transition-3.png",
    {
   
      max_size = 4,
      [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
      [2] = { probability = 1, weights = {0.070, 0.070, 0.025, 0.070, 0.070, 0.070, 0.007, 0.025, 0.070, 0.050, 0.015, 0.026, 0.030, 0.005, 0.070, 0.027 }, },
      [4] = { probability = 1.00, weights = {0.070, 0.070, 0.070, 0.070, 0.070, 0.070, 0.015, 0.070, 0.070, 0.070, 0.015, 0.050, 0.070, 0.070, 0.065, 0.070 }, },
      --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} }
    }
    )
gravel.transitions_between_transitions[1].spritesheet = "__muluna-graphics__/graphics/terrain/gravel/Xander Mod - between-transitions.png"
gravel.transitions_between_transitions[2].spritesheet = "__muluna-graphics__/graphics/terrain/gravel/Xander Mod - out-of-map-transitions.png"
gravel.transitions_between_transitions[3].spritesheet = "__muluna-graphics__/graphics/terrain/gravel/Xander Mod - out-of-map-water-transitions.png"




Muluna:extend{low_density_space_platform_foundation,gravel}