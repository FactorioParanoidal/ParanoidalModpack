local BioInd = require('common')('Bio_Industries_2')
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local ENTITYPATH_BIO = BioInd.modRoot .. "/graphics/entities/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"

require("util")

local crafting_speed_quality_multiplier = mods["quality"] and {
  uncommon = 0.83,
  rare = 0.66,
  epic = 0.50,
  legendary = 0.16
} or nil

--- Bio Garden
data:extend({
  {
    type = "assembling-machine",
    name = "bi-bio-garden",
    icon = ICONPATH_E .. "bio_garden_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_E .. "bio_garden_icon.png",
        icon_size = 64,
      }
    },
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { hardness = 0.2, mining_time = 0.5, result = "bi-bio-garden" },
    fast_replaceable_group = "bi-bio-garden",
    max_health = 150,
    corpse = "bi-bio-garden-remnant",
    collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
    selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        base_level = -1,
        pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } }
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    graphics_set = {
      animation = {
        layers = {
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_anim_trees.png",
            width = 256, height = 320,
            frame_count = 20, line_length = 5,
            animation_speed = 0.15, scale = 0.5, shift = { 0, -0.75 }
          },
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_shadow.png",
            width = 384, height = 320,
            frame_count = 1, repeat_count = 20, -- repeat to match
            draw_as_shadow = true, scale = 0.5, shift = { 1, -0.75 }
          }
        }
      }
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound = {
      sound = { { filename = "__Bio_Industries_2__/sound/rainforest_ambience.ogg", volume = 0.8 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
      max_sounds_per_type = 3,
    },
    crafting_categories = { "clean-air" },
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1.0,
    crafting_speed_quality_multiplier = crafting_speed_quality_multiplier,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = -1.5 * 60 }, -- Negative value: pollution is absorbed!
    },
    energy_usage = "200kW",
    ingredient_count = 1,
    -- Changed for 0.18.34/1.1.4 -- Modules don't make sense for the gardens!
    -- (Efficiency modules are also meant to reduce pollution, but as the base value
    -- is negative, the resulting value is greater than the base value! )
    module_specification = {
      module_slots = 1
    },
    -- Changed for 0.18.34/1.1.4 -- We need to use an empty table here, so the gardens
    -- won't be affected by beacons!
    allowed_effects = { "consumption", "speed" },
  },

  ---- corpse
  {
    type = "corpse",
    name = "bi-bio-garden-remnant",
    localised_name = { "entity-name.bi-bio-garden-remnant" },
    icon = "__base__/graphics/icons/remnants.png",
    icon_size = 64,
    icon_mipmaps = 4,
    BI_add_icon = true,
    flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
    subgroup = "remnants",
    order = "z-z-z",
    selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = {
      {
        filename = REMNANTSPATH .. "bio_garden_remnant.png",
        line_length = 1,
        width = 256,
        height = 320,
        frame_count = 1,
        direction_count = 1,
        shift = { 0, -0.75 },
        scale = 0.5
      }
    }
  },


  ---- Bio Garden Large
  {
    type = "assembling-machine",
    name = "bi-bio-garden-large",
    icon = ICONPATH_E .. "bio_garden_large_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_E .. "bio_garden_large_icon.png",
        icon_size = 64,
      }
    },
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { hardness = 0.6, mining_time = 1, result = "bi-bio-garden-large" },
    fast_replaceable_group = "bi-bio-garden-large",
    max_health = 1200,
    corpse = "bi-bio-garden-large-remnant",
    collision_box = { { -4.3, -4.3 }, { 4.3, 4.3 } },
    selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
    scale_entity_info_icon = true,
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        volume = 1000,
        filter = "water",
        pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -4 } } },
        --pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, 4 } } },
        -- pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { -4, 0 } } },
        -- pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 4, 0 } } },


      },
    },
    off_when_no_fluid_recipe = false,
    graphics_set = {
      animation = {
        layers = {
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_large.png",
            width = 640,
            height = 704,
            scale = 0.5,
            shift = { 0, -0.5 },
          },
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_large_shadow.png",
            width = 704,
            height = 640,
            scale = 0.5,
            shift = { 0.5, 0 },
            draw_as_shadow = true,
          }
        }
      },

      working_visualisations = {
        {
          light = { intensity = 1.2, size = 20 },
          draw_as_light = true,
          effect = "flicker",
          constant_speed = true,
          fadeout = true,
          animation = {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_large_light.png",
            width = 640,
            height = 640,
            scale = 0.5,
            shift = { 0, 0 },
          },
        },
      },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound = {
      sound = { { filename = "__Bio_Industries_2__/sound/rainforest_ambience.ogg", volume = 1 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.8 },
      apparent_volume = 1.5,
      max_sounds_per_type = 3,
    },
    crafting_categories = { "clean-air" },
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 4.0,
    crafting_speed_quality_multiplier = crafting_speed_quality_multiplier,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = -12 * 60 }, -- Negative value: pollution is absorbed!
    },
    energy_usage = "800kW",
    ingredient_count = 1,
    -- Changed for 0.18.34/1.1.4 -- Modules don't make sense for the gardens!
    -- (Efficiency modules are also meant to reduce pollution, but as the base value
    -- is negative, the resulting value is greater than the base value! )
    module_specification = {
      module_slots = 2
    },
    -- Changed for 0.18.34/1.1.4 -- We need to use an empty table here, so the gardens
    -- won't be affected by beacons!
    allowed_effects = { "consumption", "speed" },
  },

  --- corpse
  {
    type = "corpse",
    name = "bi-bio-garden-large-remnant",
    localised_name = { "entity-name.bi-bio-garden-large-remnant" },
    icon = "__base__/graphics/icons/remnants.png",
    icon_size = 64,
    icon_mipmaps = 4,
    BI_add_icon = true,
    flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
    subgroup = "remnants",
    order = "z-z-z",
    selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
    tile_width = 9,
    tile_height = 9,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = {
      {
        filename = REMNANTSPATH .. "bio_garden_large_remnant.png",
        line_length = 1,
        width = 640,
        height = 704,
        frame_count = 1,
        direction_count = 1,
        shift = { 0, -0.5 },
        scale = 0.5
      }
    }
  },
  ---- Bio Garden Huge
  {
    type = "assembling-machine",
    name = "bi-bio-garden-huge",
    icon = ICONPATH_E .. "bio_garden_huge_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH_E .. "bio_garden_huge_icon.png",
        icon_size = 64,
      }
    },
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { hardness = 1.2, mining_time = 2, result = "bi-bio-garden-huge" },
    fast_replaceable_group = "bi-bio-garden-huge",
    max_health = 2000,
    corpse = "bi-bio-garden-huge-remnant",
    collision_box = { { -13.3, -13.3 }, { 13.3, 13.3 } },
    selection_box = { { -13.5, -13.5 }, { 13.5, 13.5 } },
    scale_entity_info_icon = true,
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        volume = 1000,
        filter = "water",
        pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -13 } } },
        -- pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, 13 } } },
        -- pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { -13, 0 } } },
        --  pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 13, 0 } } },
      },
    },
    off_when_no_fluid_recipe = false,
    graphics_set = {
      animation = {
        layers = {
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge.png",
            width = 1792,
            height = 1856,
            scale = 0.5,
            frame_count = 1,
            line_length = 1,
            repeat_count = 8,
            animation_speed = 1,
            shift = { 0, -0.5 },
          },
          {
            filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge_shadow.png",
            width = 256,
            height = 1856,
            scale = 0.5,
            frame_count = 1,
            line_length = 1,
            repeat_count = 8,
            animation_speed = 1,
            shift = { 14, -0.5 },
            draw_as_shadow = true,
          },
        },
      },

      working_visualisations = {
        {
          constant_speed = true,
          fadeout = true,
          animation = {
            layers = {
              {
                filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge_turbine_anim.png",
                width = 128,
                height = 96,
                scale = 0.5,
                frame_count = 8,
                line_length = 8,
                repeat_count = 1,
                animation_speed = 1,
                shift = { -4.5, -4.5 },
              },
              {
                filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge_turbine_anim.png",
                width = 128,
                height = 96,
                scale = 0.5,
                frame_count = 8,
                line_length = 8,
                repeat_count = 1,
                animation_speed = 1,
                shift = { 4.5, 4.5 },
              },
              {
                filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge_turbine_anim.png",
                width = 128,
                height = 96,
                scale = 0.5,
                frame_count = 8,
                line_length = 8,
                repeat_count = 1,
                animation_speed = 1,
                shift = { 4.5, -4.5 },
              },
              {
                filename = ENTITYPATH_BIO .. "bio_garden/bio_garden_huge_turbine_anim.png",
                width = 128,
                height = 96,
                scale = 0.5,
                frame_count = 8,
                line_length = 8,
                repeat_count = 1,
                animation_speed = 1,
                shift = { -4.5, 4.5 },
              },
            },
          },
        },
      },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound = {
      sound = { { filename = "__Bio_Industries_2__/sound/rainforest_ambience.ogg", volume = 1.8 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.9 },
      apparent_volume = 2,
      max_sounds_per_type = 3,
    },
    crafting_categories = { "clean-air" },
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 16,
    crafting_speed_quality_multiplier = crafting_speed_quality_multiplier,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = -96 * 60 }, -- Negative value: pollution is absorbed!
    },
    energy_usage = "3200kW",
    ingredient_count = 1,
    -- Changed for 0.18.34/1.1.4 -- Modules don't make sense for the gardens!
    -- (Efficiency modules are also meant to reduce pollution, but as the base value
    -- is negative, the resulting value is greater than the base value! )
    module_specification = {
      module_slots = 4
    },
    -- Changed for 0.18.34/1.1.4 -- We need to use an empty table here, so the gardens
    -- won't be affected by beacons!
    allowed_effects = { "consumption", "speed" },
  },
  ---- corpse

  {
    type = "corpse",
    name = "bi-bio-garden-huge-remnant",
    localised_name = { "entity-name.bi-bio-garden-huge-remnant" },
    icon = "__base__/graphics/icons/remnants.png",
    icon_size = 64,
    icon_mipmaps = 4,
    BI_add_icon = true,
    flags = { "placeable-neutral", "building-direction-8-way", "not-on-map" },
    subgroup = "remnants",
    order = "z-z-z",
    selection_box = { { -13.5, -13.5 }, { 13.5, 13.5 } },
    tile_width = 27,
    tile_height = 27,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = {
      {
        filename = REMNANTSPATH .. "bio_garden_huge_remnant.png",
        line_length = 1,
        width = 896,
        height = 928,
        frame_count = 1,
        direction_count = 1,
        shift = { 0, -0.5 },
      }
    }
  }

})
