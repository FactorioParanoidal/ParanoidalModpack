
local tile_trigger_effects = require("__space-age__.prototypes.tile.tile-trigger-effects")
local tile_pollution = require("__space-age__/prototypes/tile/tile-pollution-values")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout

local destroyed_item_trigger =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    source_effects =
    {
      type = "create-trivial-smoke",
      smoke_name = "smoke",
      offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
      starting_frame_deviation = 5
    }
  }
}

local lava_stone_transitions =
{
  {
    to_tiles = water_tile_type_names,
    transition_group = water_transition_group_id,

    spritesheet = "__space-age__/graphics/terrain/water-transitions/lava-stone-cold.png",
    layout = tile_spritesheet_layout.transition_16_16_16_4_4,
    effect_map_layout =
    {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
      inner_corner_count = 8,
      outer_corner_count = 8,
      side_count = 8,
      u_transition_count = 2,
      o_transition_count = 1
    }
  },
  {
    to_tiles = lava_tile_type_names,
    transition_group = lava_transition_group_id,
    spritesheet = "__space-age__/graphics/terrain/lava-transitions/lava-stone.png",
    lightmap_layout = { spritesheet = "__space-age__/graphics/terrain/lava-transitions/lava-stone-lightmap.png" },
     -- this added the lightmap spritesheet
    layout = tile_spritesheet_layout.transition_16_16_16_4_4,
    lightmap_layout = { spritesheet = "__space-age__/graphics/terrain/lava-transitions/lava-stone-lightmap.png" },
     -- this added the lightmap spritesheet
    effect_map_layout =
    {
      spritesheet = "__Moshine-assets__/graphics/terrain/lava-dirt-mask.png",
      inner_corner_count = 8,
      outer_corner_count = 8,
      side_count = 8,
      u_transition_count = 2,
      o_transition_count = 1
    }
  },
  {
    to_tiles = {"out-of-map","empty-space","oil-ocean-shallow"},
    transition_group = out_of_map_transition_group_id,

    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,

    spritesheet = "__space-age__/graphics/terrain/out-of-map-transition/volcanic-out-of-map-transition.png",
    layout = tile_spritesheet_layout.transition_4_4_8_1_1,
    overlay_enabled = false
  }
}


local function transition_masks()
  return {
    mask_spritesheet = "__base__/graphics/terrain/masks/transition-1.png",
    mask_layout =
    {
      scale = 0.5,
      inner_corner =
      {
        count = 8,
      },
      outer_corner =
      {
        count = 8,
        x = 64*9
      },
      side =
      {
        count = 8,
        x = 64*9*2
      },
      u_transition =
      {
        count = 1,
        x = 64*9*3
      },
      o_transition =
      {
        count = 1,
        x = 64*9*4
      }
    }
  }
end
--[[
local function sunny_ground_effect(groundtexture, w, h)
  data:extend({
    ----- Hot swamp
    {
      type = "tile-effect",
      name = groundtexture,
      shader = "water",
      water =
      {
        shader_variation = "lava",
        textures =
        {
          {
            filename = "__Moshine-assets__/graphics/terrain/sunny-ground-noise-texture.png",
            width = 512,
            height = 512
          },
          {
            filename = "__Moshine-assets__/graphics/terrain/" .. groundtexture .. ".png",
            width = 512 * w,
            height = 512 * h,
            draw_as_glow = false
          }
        },
        texture_variations_columns = 1,
        texture_variations_rows = 1,
        secondary_texture_variations_columns = 8,
        secondary_texture_variations_rows = 2,

        animation_speed = 0.2,
        animation_scale = { 0.75, 0.75 },
        tick_scale = 1,

        specular_lightness = { 0, 0, 0 },
        foam_color = { 100, 100, 100 },
        foam_color_multiplier = 1,

        dark_threshold = { 2, 2 },
        reflection_threshold = { 0, 0 },
        specular_threshold = { 1,1 },

        near_zoom = 1 / 16,
        far_zoom = 1 / 16
        
      }
    },
  })
end
]]

--sunny_ground_effect("moshine-hot-swamp", 8, 2)
--sunny_ground_effect(groundtexture, w, h)

data:extend({
  {
    type = "item-subgroup",
    name = "moshine-tiles",
    group = "tiles",
    order = "c"
  },
  {
    name = "moshine-hot-swamp",
    type = "tile",
    order = "a[oil]-b[shallow]",
    subgroup = "moshine-tiles",
    collision_mask = {
      layers =
      {
        ground_tile = true,
        --resource = true,
      }
    },
    autoplace = {probability_expression = "50 * fulgora_oil_mask * water_base(fulgora_coastline, 1000)"}, -- target coast at cliff elevation
    layer = 4,
    layer_group = "ground-natural",
    vehicle_friction_modifier = 4,
    --walking_speed_modifier = 0.8,
    --default_cover_tile = "foundation",
    absorptions_per_second = tile_pollution.fulgora,
    --effect = "moshine-hot-swamp",
    particle_tints = tile_graphics.fulgora_oil_ocean_particle_tints,
    variants =
    {
      transition = transition_masks(),
      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/moshine-hot-swamp.png",
        line_length = 8,
        count = 16,
        scale = 0.5
      },
      material_texture_width_in_tiles = 8,
      material_texture_height_in_tiles = 8
    },
    --transitions = table.deepcopy(data.raw.tile["sand-1"].transitions),
    transitions = lava_stone_transitions,
    --transitions_between_transitions = table.deepcopy(data.raw.tile["sand-1"].transitions_between_transitions),
    transitions_between_transitions = fulgora_sand_transitions_between_transitions,
    walking_sound = sound_variations("__base__/sound/walking/resources/oil", 7, 1, volume_multiplier("main-menu", 1.5)),
    landing_steps_sound = sound_variations("__base__/sound/walking/resources/oil", 7, 1, volume_multiplier("main-menu", 2.9)),
    driving_sound = oil_driving_sound,
    scorch_mark_color = {r = 0.3, g = 0.3, b = 0.3, a = 1.000},
    trigger_effect = tile_trigger_effects.sand_trigger_effect(),
    map_color = { 121, 88, 59},
  },
})




data:extend({
  ----------- MOLTEN IRON LAVA
  {
    type = "tile-effect",
    name = "moshine-lava",
    shader = "water",
    water =
    {
      shader_variation = "lava",
      noise_textures =
      {
        {
          filename = "__space-age__/graphics/terrain/vulcanus/lava-textures/lava-noise-1.png",
          size = 512,
          color_channels = 2
        },
        {
          filename = "__space-age__/graphics/terrain/vulcanus/lava-textures/lava-noise-2.png",
          size = 512,
          color_channels = 1
        }
      },
      image_textures =
      {
        {
          filename = "__Moshine-assets__/graphics/terrain/moshine-coastal-lava.png",
        }
      },


      ---------------------- FOR PRE-2.1.22 versions
      textures =
      {
        {
          filename = "__Moshine-assets__/graphics/terrain/moshine-lava-noise-texture.png",
          width = 512,
          height = 512
        },
        {
          filename = "__Moshine-assets__/graphics/terrain/moshine-coastal-lava.png",
          width = 512 * 4,
          height = 512 * 2
        }
      },

      texture_variations_columns = 1,
      texture_variations_rows = 1,
      secondary_texture_variations_columns = 4,
      secondary_texture_variations_rows = 2,

      --------------------------------------

      animation_speed = 1.5,
      animation_scale = { 0.75, 0.75 },
      tick_scale = 1,

      specular_lightness = { 30, 48, 22 },
      foam_color = { 73, 5, 5 },
      foam_color_multiplier = 1,

      dark_threshold = { 0.755, 0.755 },
      reflection_threshold = { 1, 1 },
      specular_threshold = { 0.889, 0.291 },

      near_zoom = 1 / 16,
      far_zoom = 1 / 16
    }
  },
  {
    type = "tile",
    name = "moshine-lava",
    subgroup = "moshine-tiles",
    order = "a-b",
    collision_mask = tile_collision_masks.lava(),
    autoplace = {probability_expression = "100 * fulgora_oil_mask * water_base(fulgora_coastline - 90 - fulgora_coastline_drop / 2, 2000)"},
    effect = "moshine-lava",
    fluid = "molten-iron",
    effect_color = { 167, 59, 27 },
    effect_color_secondary = { 49, 80, 14 },
    particle_tints = tile_graphics.lava_particle_tints,
    destroys_dropped_items = true,
    default_destroyed_dropped_item_trigger = destroyed_item_trigger,
    layer = 6,
    layer_group = "water",
    --sprite_usage_surface = "vulcanus",
    variants = tile_variations_template(
      "__Moshine-assets__/graphics/terrain/moshine-coastal-lava2.png",
      "__base__/graphics/terrain/masks/transition-1.png",
      {
        max_size = 4,
        [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
        [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
        [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
      }
    ),
    --allowed_neighbors={"lava-hot"},
    transitions = lava_stone_transitions,
    --transitions_between_transitions = data.raw.tile["water"].transitions_between_transitions,
    walking_sound = data.raw.tile["water"].walking_sound,
    --walking_speed_modifier = 1,
    vehicle_friction_modifier = 1,
    absorptions_per_second = tile_pollution.lava,
    trigger_effect = tile_trigger_effects.hot_lava_trigger_effect(),
    default_cover_tile = "foundation",
    ambient_sounds =
    {
      sound =
      {
        variations = sound_variations("__space-age__/sound/world/tiles/lava", 10, 0.5 ),
        advanced_volume_control =
        {
          fades = { fade_in = { curve_type = "cosine", from = { control = 0.5, volume_percentage = 0.0 }, to = { 1.5, 100.0 } } }
        }
      },
      radius = 7.5,
      min_entity_count = 10,
      max_entity_count = 30,
      entity_to_sound_ratio = 0.1,
      average_pause_seconds = 3
    },
    map_color = {r = 86, g = 41, b = 51},
  },








  {
    name = "moshine-dust",
    type = "tile",
    order = "b[natural]-a[dust]",
    subgroup = "moshine-tiles",
    collision_mask = tile_collision_masks.ground(),
    autoplace = {
      probability_expression = "fulgora_scrap_medium + max(0, fulgora_natural, 2 * fulgora_mesa * fulgora_pyramids) * 2 - 0.9 + fulgora_rock + fulgora_road_dust * fulgora_sprawl"
    },
    layer = 6,
    map_color={155, 127, 98},
    vehicle_friction_modifier = 4,
    absorptions_per_second = tile_pollution.fulgora,
    sprite_usage_surface = "fulgora",
    variants =
    {
      transition = transition_masks(),
      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/moshine-dust.png",
        line_length = 8,
        count = 16,
        scale = 0.5
      },
      material_texture_width_in_tiles = 8,
      material_texture_height_in_tiles = 8
    },
    transitions = fulgora_rock_sand_transitions,
    transitions_between_transitions = fulgora_sand_transitions_between_transitions,
    walking_sound = sound_variations("__space-age__/sound/walking/soft-sand", 9, 0.6, volume_multiplier("main-menu", 2.9)),
    landing_steps_sound = tile_sounds.landing.sand,
    driving_sound = sand_driving_sound,
    ambient_sounds = sand_ambient_sound,
    scorch_mark_color = {r = 0.3, g = 0.3, b = 0.3, a = 1.000},
    trigger_effect = tile_trigger_effects.sand_trigger_effect()
  },
  {
    name = "moshine-dunes",
    type = "tile",
    order = "b[natural]-b[dunes]",
    subgroup = "moshine-tiles",
    collision_mask = tile_collision_masks.ground(),
    autoplace = {
      probability_expression = "1 + fulgora_dunes"
    },
    layer = 7,
    map_color={141, 125, 91},
    vehicle_friction_modifier = 4,
    absorptions_per_second = tile_pollution.fulgora,
    sprite_usage_surface = "fulgora",
    variants =
    {
      transition = transition_masks(),
      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/moshine-dunes.png",
        line_length = 4,
        count = 16,
        scale = 0.5
      },
      material_texture_width_in_tiles = 10,
      material_texture_height_in_tiles = 7
    },
    transitions = fulgora_rock_sand_transitions,
    transitions_between_transitions = fulgora_sand_transitions_between_transitions,
    walking_sound = sound_variations("__base__/sound/walking/sand", 9, 0.8, volume_multiplier("main-menu", 2.9)),
    landing_steps_sound = tile_sounds.landing.sand,
    driving_sound = sand_driving_sound,
    ambient_sounds = sand_ambient_sound,
    scorch_mark_color = {r = 0.3, g = 0.3, b = 0.3, a = 1.000},
    trigger_effect = tile_trigger_effects.sand_trigger_effect()
  },
  {
    name = "moshine-sand",
    type = "tile",
    order = "b[natural]-c[sand]",
    subgroup = "moshine-tiles",
    collision_mask = tile_collision_masks.ground(),
    autoplace = {
      probability_expression = "1 - fulgora_dunes"
    },
    layer = 8,
    map_color={169, 131, 86},
    vehicle_friction_modifier = 4,
    absorptions_per_second = tile_pollution.fulgora,
    sprite_usage_surface = "fulgora",
    variants =
    {
      transition = transition_masks(),
      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/moshine-sand.png",
        line_length = 4,
        count = 16,
        scale = 0.5
      },
      material_texture_width_in_tiles = 10,
      material_texture_height_in_tiles = 7
    },
    transitions = fulgora_rock_sand_transitions,
    transitions_between_transitions = fulgora_sand_transitions_between_transitions,
    walking_sound = sound_variations("__base__/sound/walking/sand", 9, 0.8, volume_multiplier("main-menu", 2.9)),
    landing_steps_sound = tile_sounds.landing.sand,
    driving_sound = sand_driving_sound,
    ambient_sounds = sand_ambient_sound,
    scorch_mark_color = {r = 0.3, g = 0.3, b = 0.3, a = 1.000},
    trigger_effect = tile_trigger_effects.sand_trigger_effect()
  },
  {
    name = "moshine-rock",
    type = "tile",
    order = "b[natural]-d[rock]",
    subgroup = "moshine-tiles",
    collision_mask = tile_collision_masks.ground(),
    autoplace = {
      probability_expression = "0.8 + fulgora_rock * 2 - max(0, fulgora_mix_oil) * 6"
    },
    layer = 9,
    map_color={171, 121, 69},
    vehicle_friction_modifier = 4,
    absorptions_per_second = tile_pollution.fulgora,
    sprite_usage_surface = "fulgora",
    variants =
    {
      transition = transition_masks(),
      material_background =
      {
        picture = "__Moshine-assets__/graphics/terrain/moshine-rock.png",
        line_length = 8,
        count = 16,
        scale = 0.5
      },
      material_texture_width_in_tiles = 8,
      material_texture_height_in_tiles = 8
    },
    transitions = fulgora_rock_sand_transitions,
    transitions_between_transitions = fulgora_sand_transitions_between_transitions,
    walking_sound = sound_variations("__space-age__/sound/walking/rocky-stone", 10, 0.8, volume_multiplier("main-menu", 2.9)),
    landing_steps_sound = tile_sounds.landing.rock,
    driving_sound = stone_driving_sound,
    scorch_mark_color = {r = 0.3, g = 0.3, b = 0.3, a = 1.000},
    trigger_effect = tile_trigger_effects.sand_trigger_effect()
  },

})






table.insert(lava_tile_type_names, "moshine-lava")
table.insert(water_tile_type_names, "moshine-lava")
--table.insert(water_tile_type_names, "moshine-hot-swamp")
