local transitions = {}


local tile_noise_enabled = true
local tile_noise_persistence = 0.7

local tile_noise_influence = 2/3
local size_control_influence = 1
local rectangle_influence = 1
local beach_influence = 5
local water_inflike = 4096

local default_transition_group_id = 0
local water_transition_group_id = 1
local out_of_map_transition_group_id = 2

local out_of_map_transition =
  make_out_of_map_transition_template
  (
    { "out-of-map" },
    "__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
    "__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
    {
      o_transition_tall = false,
      side_count = 8,
      inner_corner_count = 4,
      outer_corner_count = 4,
      u_transition_count = 1,
      o_transition_count = 1,
      base = init_transition_between_transition_common_options()
    },
    false,
    true,
    true
)
transitions.out_of_map_transition = out_of_map_transition


transitions.beach_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/sr/beach.png",
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/beach.png",
      {
        o_transition_tall = false,
        u_transition_tall = false,
        side_tall = false,
        inner_corner_tall = false,
        outer_corner_tall = false,
        u_transition_count = 4,
        o_transition_count = 8,
        --base = init_transition_between_transition_common_options()
      }
  ),
  out_of_map_transition
}

transitions.beach_transitions_between_transitions =
{
  generic_transition_between_transitions_template
  (
      default_transition_group_id,
      water_transition_group_id,
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/sr/beach-transition.png",
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/beach-transition.png",
      {
        side_tall = false,
        inner_corner_tall = false,
        outer_corner_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
        base = { water_patch = patch_for_inner_corner_of_transition_between_transition, }
      }
  ),
  make_generic_transition_template
  (
    nil,
    default_transition_group_id,
    out_of_map_transition_group_id,
    "__base__/graphics/terrain/out-of-map-transition/sand-out-of-map-transition.png",
    "__base__/graphics/terrain/out-of-map-transition/sand-out-of-map-transition.png",
    {
      inner_corner_tall = true,
      inner_corner_count = 3,
      outer_corner_count = 3,
      side_count = 3,
      u_transition_count = 1,
      o_transition_count = 0,
      base = init_transition_between_transition_common_options()
    },
    false,
    true,
    true
  ),
  generic_transition_between_transitions_template
  (
      water_transition_group_id,
      out_of_map_transition_group_id,
      "__base__/graphics/terrain/out-of-map-transition/sand-shore-out-of-map-transition.png",
      "__base__/graphics/terrain/out-of-map-transition/sand-shore-out-of-map-transition.png",
      {
        o_transition_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
        base = init_transition_between_transition_common_options({ water_patch = patch_for_inner_corner_of_transition_between_transition, })
      }
  ),

}


transitions.cliff_transitions =
{
  water_transition_template
  (
      water_tile_type_names,
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/sr/cliff.png",
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/cliff.png",
      {
        o_transition_tall = false,
        u_transition_count = 2,
        o_transition_count = 4,
        side_count = 8,
        outer_corner_count = 8,
        inner_corner_count = 8
      }
  ),
  out_of_map_transition
}

transitions.cliff_transitions_between_transitions =
{
  generic_transition_between_transitions_template
  (
      default_transition_group_id,
      water_transition_group_id,
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/sr/cliff-transition.png",
      "__Alien-biomes-Reforged__/graphics/terrain/water-transitions/cliff-transition.png",
      {
        o_transition_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
        base = { water_patch = patch_for_inner_corner_of_transition_between_transition, }
      }
  ),
  make_generic_transition_template
  (
    nil,
    default_transition_group_id,
    out_of_map_transition_group_id,
    "__base__/graphics/terrain/out-of-map-transition/dirt-out-of-map-transition.png",
    "__base__/graphics/terrain/out-of-map-transition/dirt-out-of-map-transition.png",
    {
      o_transition_tall = false,
      inner_corner_count = 3,
      outer_corner_count = 3,
      side_count = 3,
      u_transition_count = 1,
      o_transition_count = 0,
      base = init_transition_between_transition_common_options({ water_patch = patch_for_inner_corner_of_transition_between_transition, })
    },
    false,
    true,
    true
  ),
  generic_transition_between_transitions_template
  (
      water_transition_group_id,
      out_of_map_transition_group_id,
      "__base__/graphics/terrain/out-of-map-transition/dark-dirt-shore-out-of-map-transition.png",
      "__base__/graphics/terrain/out-of-map-transition/dark-dirt-shore-out-of-map-transition.png",
      {
        o_transition_tall = false,
        inner_corner_count = 3,
        outer_corner_count = 3,
        side_count = 3,
        u_transition_count = 1,
        o_transition_count = 0,
        base = init_transition_between_transition_common_options({ water_patch = patch_for_inner_corner_of_transition_between_transition, })
      }
  ),

}


return transitions
