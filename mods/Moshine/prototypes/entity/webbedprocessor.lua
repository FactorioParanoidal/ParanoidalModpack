
require ("sound-util")
require ("circuit-connector-sprites")
require ("util")
require ("__space-age__.prototypes.entity.circuit-network")
require ("__space-age__.prototypes.entity.space-platform-hub-cockpit")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_trigger_effects = require("__base__.prototypes.tile.tile-trigger-effects")
local tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local space_platform_tile_animations = require("__space-age__.prototypes.tile.platform-tile-animations")
local space_age_tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")

local ENTITYPATH = "__Moshine__/graphics/entity"


local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require ("__space-age__.prototypes.entity.sounds")
local meld = require("meld")
local simulations = require("__space-age__.prototypes.factoriopedia-simulations")

data:extend({
  {
    type = "tile",
    name = "webbed_processor_tile",
    order = "a[artificial]-d[utility]-c[space-platform-foundation]",
    subgroup = "artificial-tiles",
    minable = {mining_time = 0.5, result = "webbed_processor_tile"},
    mined_sound = sounds.deconstruct_bricks(0.8),
    --is_foundation = true,
    allows_being_covered = true,
    max_health = 50,
    weight = 200,
    collision_mask = tile_collision_masks.ground(),
    layer = 18,
    layer_group = "ground-artificial",
    transitions = concrete_transitions,
    transitions_between_transitions = concrete_transitions_between_transitions,
    transition_overlay_layer_offset = 2, -- need to render border overlay on top of hazard-concrete
    decorative_removal_probability = 0.99, --0.25,
    -- transitions = landfill_transitions,
    -- transitions_between_transitions = landfill_transitions_between_transitions,
    dying_explosion = "space-platform-foundation-explosion",
    trigger_effect = tile_trigger_effects.landfill_trigger_effect(),

    bound_decoratives =
    {
      "space-platform-decorative-pipes-2x1",
      "space-platform-decorative-pipes-1x2",
      "space-platform-decorative-pipes-1x1",
      --"space-platform-decorative-pipes-2x1",
      --"space-platform-decorative-pipes-1x2",
      --"space-platform-decorative-pipes-1x1",
      --"space-platform-decorative-4x4",
      --"space-platform-decorative-2x2",
      --"space-platform-decorative-1x1",
      "space-platform-decorative-tiny",
    },

    sprite_usage_surface = "any",
    variants =
    {
      transition =
      {
        overlay_layout =
        {
          inner_corner =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-inner-corner.png",
            count = 16,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-outer-corner.png",
            count = 16,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-side.png",
            count = 32,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-u.png",
            count = 4,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-o.png",
            count = 1,
            scale = 0.5
          }
        },
        mask_layout =
        {
          inner_corner =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-inner-corner-mask.png",
            count = 16,
            scale = 0.5
          },
          outer_corner =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-outer-corner-mask.png",
            count = 16,
            scale = 0.5
          },
          side =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-side-mask.png",
            count = 32,
            scale = 0.5
          },
          u_transition =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-u-mask.png",
            count = 4,
            scale = 0.5
          },
          o_transition =
          {
            spritesheet = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground-o-mask.png",
            count = 1,
            scale = 0.5
          }
        }
      },

      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/space-platform-for-ground/space-platform-for-ground.png",
        count = 1,
        scale = 0.5
      }
    },

    walking_sound = tile_sounds.walking.concrete,
    build_sound = {
      small = sound_variations("__core__/sound/build-concrete-small", 6, 0.4), -- used in editor
      medium = sound_variations("__core__/sound/build-concrete-medium", 6, 0.5), -- used in editor
      large =  sound_variations("__core__/sound/build-concrete-large", 6, 0.5), -- used in editor
      animated =
      {
        variations = sound_variations("__space-age__/sound/terrain/space-platform-tile-build", 7, 0.5),
        aggregation = {max_count = 3, remove = true, count_already_playing = true, priority = "oldest", progress_threshold = 0.6},
      },
    },
    map_color = {63, 61, 59},
    scorch_mark_color = {r = 0.373, g = 0.307, b = 0.243, a = 1.000}
  },
})

