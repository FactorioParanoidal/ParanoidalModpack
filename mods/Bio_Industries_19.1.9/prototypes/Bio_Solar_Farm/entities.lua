local BioInd = require('common')('Bio_Industries')
require ("util")

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ENTITYPATH = "__Bio_Industries__/graphics/entities/bio_solar_farm/"

--~ local BIGICONS = BioInd.check_base_version("0.18.0")


if BI.Settings.BI_Solar_Additions then


-- demo-sounds has been removed in Factorio 1.1, so we need to check the game version!
local sound_def = BioInd.check_version("base", "<", "1.1.0") and
                    require("__base__.prototypes.entity.demo-sounds") or
                    require("__base__.prototypes.entity.sounds")
local sounds = {}
sounds.car_wood_impact = sound_def.car_wood_impact(1)
sounds.generic_impact = sound_def.generic_impact
for _, sound in ipairs(sounds.generic_impact) do
  sound.volume = 0.65
end

sounds.walking_sound = {}
for i = 1, 11 do
  sounds.walking_sound[i] = {
    filename = "__base__/sound/walking/concrete-" .. (i < 10 and "0" or "")  .. i ..".ogg",
    volume = 1.2
  }
end

data:extend({
  ------- Bio Farm Solar Panel
  {
    type = "solar-panel",
    name = "bi-bio-solar-farm",
    icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
        icon_size = 64,
      }
    },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.25, mining_time = 0.5, result = "bi-bio-solar-farm"},
    max_health = 600,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 80}},
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    energy_source = {
      type = "electric",
      usage_priority = "solar"
    },
    picture = {
      filename = ENTITYPATH .. "Bio_Solar_Farm_On.png",
      priority = "low",
      width = 312,
      height = 289,
      frame_count = 1,
      direction_count = 1,
      --scale = 3/2,
      shift = {0.30, 0}
    },
    production = "3600kW"
  },


  ---- BI Accumulator
  {
    type = "accumulator",
    name = "bi-bio-accumulator",
    icon = ICONPATH .. "bi_LargeAccumulator.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_LargeAccumulator.png",
        icon_size = 64,
      }
    },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-accumulator"},
    max_health = 500,
    corpse = "big-remnants",
    collision_box = {{-1.75, -1.75}, {1.75, 1.75}},
    selection_box = {{-2, -2}, {2, 2}},
    --collision_box = {{-2, -2}, {2, 2}},
    --selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    energy_source = {
      type = "electric",
      buffer_capacity = "300MJ",
      usage_priority = "tertiary",
      input_flow_limit = "400kW", --DrD 20MW
      output_flow_limit = "1MW" --DrD 20MW
    },
    picture = {
      filename = ENTITYPATH .. "bi_LargeAccumulator.png",
      priority = "extra-high",
      width = 245,
      height = 245,
      shift = {0.75, -0.5},
      scale = 0.75,
    },
    charge_animation = {
      filename = ENTITYPATH .. "bi_LargeAccumulatorAnimated.png",
      width = 250,
      height = 250,
      line_length = 8,
      frame_count = 24,
      shift = {0.75, -0.5},
      scale = 0.75,
      animation_speed = 0.5
    },
    charge_cooldown = 30,
    charge_light = {intensity = 0.3, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    discharge_animation = {
      filename = ENTITYPATH .. "bi_LargeAccumulatorAnimated.png",
      width = 250,
      height = 250,
      line_length = 8,
      frame_count = 24,
      shift = {0.75, -0.5},
      scale = 0.75,
      animation_speed = 0.5
    },
    discharge_cooldown = 60,
    discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
      sound = {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound = {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    },
    circuit_wire_connection_point = {
      shadow = {
        red = {0.984375, 1.10938},
        green = {0.890625, 1.10938}
      },
      wire = {
        red = {0.6875, 0.59375},
        green = {0.6875, 0.71875}
      }
    },
    --circuit_connector_sprites = get_circuit_connector_sprites({0.46875, 0.5}, {0.46875, 0.8125}, 26),
    circuit_wire_max_distance = 9,
    default_output_signal = {type = "virtual", name = "signal-A"}
  },


  ---- Large Substation
  {
    type = "electric-pole",
    name = "bi-large-substation",
    localised_name = {"entity-name.bi-large-substation"},
    localised_description = {"entity-description.bi-large-substation"},
    icon = ICONPATH .. "bi_LargeSubstation_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_LargeSubstation_icon.png",
        icon_size = 64,
      }
    },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-large-substation"},
    max_health = 600,
    corpse = "big-remnants",
    dying_explosion = "big-explosion",
    track_coverage_during_build_by_moving = true,
    resistances = {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -5}, {2.5, 2.5}},
    maximum_wire_distance = 25,
    -- Changed for 0.18.34/1.1.4
    --~ supply_area_distance = 50,
    supply_area_distance = 50.5,
    pictures = {
      filename = ENTITYPATH .. "bi_LargeSubstation.png",
      priority = "high",
      width = 450,
      height = 380,
      shift = {1, -0.5},
      direction_count = 1,
      scale = 0.5,
    },
    vehicle_impact_sound = sounds.generic_impact,
    working_sound = {
      sound = { filename = "__base__/sound/substation.ogg" },
      apparent_volume = 1.8,
      audible_distance_modifier = 0.5,
      probability = 1 / (3 * 60) -- average pause between the sound is 3 seconds
    },
    connection_points = {
      {
        shadow = {
          copper = {1.9, -0.6},
          green = {1.3, -0.6},
          red = {2.65, -0.6}
        },
        wire = {
          copper = {-0.25, -2.71875},
          green = {-0.84375, -2.71875},
          red = {0.34375, -2.71875}
        }
      },
    },
    radius_visualisation_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12,
      --scale = 3,
      --shift = {0.6, -0.6},
      priority = "extra-high-no-scale"
    },
  },


  ---- Solar Floor
  --[[drd
  {
    type = "tile",
    name = "bi-solar-mat",
    localised_name = {"entity-name.bi-solar-mat"},
    localised_description = {"entity-description.bi-solar-mat"},
    icon = ICONPATH .. "solar-mat.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "solar-mat.png",
        icon_size = 64,
      }
    },
    needs_correction = false,
    minable = {hardness = 0.1, mining_time = 0.25, result = "bi-solar-mat"},
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    --collision_mask = {"ground-tile", "not-colliding-with-itself"},
    collision_mask = {"ground-tile"},
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    walking_speed_modifier = 1.45,
    layer = 62,
    decorative_removal_probability = 1,
    variants = {
      main = {
        {
          picture = ENTITYPATH .. "solar1.png",
          count = 1,
          size = 1,
          probability = 1,
        },
		
        {
          picture = ENTITYPATH .. "solar2.png",
          count = 1,
          size = 2,
          probability = 1,
        },
    
      },
      inner_corner = {
        picture = ENTITYPATH .. "solar-inner-corner.png",
        count = 8
      },
      outer_corner = {
        picture = ENTITYPATH .. "solar-outer-corner.png",
        count = 8
      },
      side = {
        picture = ENTITYPATH .. "solar-side.png",
        count = 8
      },
      u_transition = {
        picture = ENTITYPATH .. "solar-u.png",
        count = 8
      },
      o_transition = {
        picture = ENTITYPATH .. "solar-o.png",
        count = 1
      }
    },
    walking_sound = sounds.walking_sound,
    map_color = {r = 93, g = 138, b = 168},
    pollution_absorption_per_second = 0,
    vehicle_friction_modifier = dirt_vehicle_speed_modifer
  },
})

   --~ ------- Hidden Electric pole for Solar Mat
--~ local hidden_pole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
--~ {
--     type = "electric-pole",
--     name = "bi-musk-mat-hidden-pole",
--     icon = ICONPATH .. "solar-mat.png",
--     icon_size = 64,
--     icons = {
--       {
--         icon = ICONPATH .. "solar-mat.png",
--         icon_size = 64,
--       }
--     },
--     flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-repairable"},
--     selectable_in_game = false,
--     draw_copper_wires = false,
--     max_health = 10,
--     resistances = {{type = "fire", percent = 100}},
--     collision_mask = {"ground-tile"},
--     collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
--     selection_box = {{0, 0}, {0, 0}},
--     maximum_wire_distance = 1,
--     supply_area_distance = 3,
--     pictures = {
--       filename = ICONPATH .. "empty.png",
--       filename = "__base__/graphics/icons/small-electric-pole.png",
--       filename = BioInd.is_debug and
--         "__base__/graphics/icons/small-electric-pole.png" or
--         ICONPATH .. "empty.png",
--       priority = "low",
--       width = 1,
--       height = 1,
--       frame_count = 1,
--       axially_symmetrical = false,
--       direction_count = 4,
--       shift = {0.75, 0},
--     },
--     connection_points = {
--       {
--         shadow = {
--
--         },
--         wire = {
--           copper_wire = {-0, -0},
--         }
--       },
--       {
--         shadow = {
--
--         },
--         wire = {
--           copper_wire = {-0, -0},
--         }
--       },
--       {
--         shadow = {
--
--         },
--         wire = {
--           copper_wire = {-0, -0},
--         }
--       },
--       {
--         shadow = {
--
--         },
--         wire = {
--           copper_wire = {-0, -0},
--         }
--       }
--     },
--
--     radius_visualisation_picture = {
--       filename = ICONPATH .. "empty.png",
--       width = 1,
--       height = 1,
--       priority = "low"
--     },
--   },
--~ hidden_pole.name = "bi-musk-mat-hidden-pole"
--~ hidden_pole.icon = ICONPATH .. "solar-mat.png"
--~ hidden_pole.icon_size = 64
--~ hidden_pole.icons = {
  --~ {
    --~ icon = ICONPATH .. "solar-mat.png",
    --~ icon_size = 64,
  --~ }
--~ }
--~ hidden_pole.flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-repairable"}
--~ hidden_pole.selectable_in_game = false
--~ hidden_pole.draw_copper_wires = BioInd.is_debug
--~ hidden_pole.max_health = 10
--~ hidden_pole.resistances = {{type = "fire", percent = 100}}
--~ hidden_pole.collision_mask = {"ground-tile"}
--~ hidden_pole.collision_box = {{-0.0, -0.0}, {0.0, 0.0}}
--~ hidden_pole.selection_box = {{0, 0}, {0, 0}}
--~ hidden_pole.maximum_wire_distance = 1
--~ hidden_pole.supply_area_distance = 3
--~ hidden_pole.pictures = BioInd.is_debug and hidden_pole.pictures or {
  --~ filename = ICONPATH .. "empty.png",
  --~ priority = "low",
  --~ width = 1,
  --~ height = 1,
  --~ frame_count = 1,
  --~ axially_symmetrical = false,
  --~ direction_count = 1,
  --~ shift = {0.75, 0},
--~ }
--~ hidden_pole.connection_points = BioInd.is_debug and hidden_pole.connection_points or {
  --~ {
    --~ shadow = {},
    --~ wire = { copper_wire = {-0, -0} }
  --~ },
--~ }
--~ hidden_pole.radius_visualisation_picture = {
  --~ filename = ICONPATH .. "empty.png",
  --~ width = 1,
  --~ height = 1,
  --~ priority = "low"
--~ }
--~ data:extend({hidden_pole})

data:extend({
  --~ ------- Hidden Solar Panel for Solar Mat
  --~ {
    --~ type = "solar-panel",
    --~ name = "bi-musk-mat-hidden-panel",
    --~ icon = ICONPATH .. "solar-mat.png",
    --~ icon_size = 64,
    --~ icons = {
      --~ {
        --~ icon = ICONPATH .. "solar-mat.png",
        --~ icon_size = 64,
      --~ }
    --~ },
    --~ flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-repairable"},
    --~ selectable_in_game = false,
    --~ max_health = 1,
    --~ resistances = {{type = "fire", percent = 100}},
    --~ collision_mask = {"ground-tile"},
    --~ collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
    --~ selection_box = {{0, 0}, {0, 0}},
    --~ energy_source = {
      --~ type = "electric",
      --~ usage_priority = "solar"
    --~ },
    --~ picture = {
      --~ -- filename = ICONPATH .. "empty.png",
      --~ filename = "__base__/graphics/icons/solar-panel.png",
      --~ priority = "low",
      --~ width = 1,
      --~ height = 1,
    --~ },
    --~ production = "10kW"
  --~ },


 --~ ------- Solar Panel for Solar Plant / Boiler
  --~ {
    --~ type = "solar-panel",
    --~ name = "bi-solar-boiler-hidden-panel",
    --~ localised_name = {"entity-name.bi-solar-boiler"},
    --~ localised_description = {"entity-description.bi-solar-boiler"},
    --~ icon = ICONPATH .. "Bio_Solar_Boiler_Panel_Icon.png",
    --~ icon_size = 64,
    --~ icons = {
      --~ {
        --~ icon = ICONPATH .. "Bio_Solar_Boiler_Panel_Icon.png",
        --~ icon_size = 64,
      --~ }
    --~ },
    --~ flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-repairable"},
    --~ max_health = 400,
    --~ render_no_power_icon = true,
    --~ resistances = {{type = "fire", percent = 100}},
    --~ -- collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    --~ -- selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
    --~ collision_box = {{0, 0}, {0, 0}},
    --~ selection_box = {{0, 0}, {0, 0}},
--~ collision_mask = {},
    --~ energy_source = {
      --~ type = "electric",
      --~ usage_priority = "solar"
    --~ },
    --~ -- picture = {
      --~ -- filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
      --~ -- priority = "low",
      --~ -- width = 288,
      --~ -- height = 288,
      --~ -- hr_version = {
        --~ -- filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
        --~ -- priority = "low",
        --~ -- width = 288,
        --~ -- height = 288,
      --~ -- }
    --~ -- },
    --~ picture = {
      --~ filename = ICONPATH .. "empty.png",
      --~ priority = "low",
      --~ size = 1,
    --~ },

    --~ overlay = {
        --~ layers = {
          --~ {
            --~ filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            --~ priority = "high",
            --~ width = 288,
            --~ height = 288,
            --~ hr_version = {
            --~ filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            --~ priority = "high",
            --~ width = 288,
            --~ height = 288,
          --~ }
        --~ },
      --~ }
    --~ },
    --~ production = "1.8MW"
  --~ },
]]--drd

  ------- Boiler for Solar Plant / Boiler
  {
    type = "boiler",
    name = "bi-solar-boiler",
    icon = ICONPATH .. "Bio_Solar_Boiler_Boiler_Icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Bio_Solar_Boiler_Boiler_Icon.png",
        icon_size = 64,
      }
    },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "bi-solar-boiler"},
    max_health = 400,
    corpse = "small-remnants",
    vehicle_impact_sound = sounds.generic_impact,
    mode = "output-to-separate-pipe",
    resistances = {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "explosion",
        percent = 30
      },
      {
        type = "impact",
        percent = 30
      }
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    target_temperature = 235,
    fluid_box = {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
        {type = "input-output", position = {5, 0}},
                {type = "input-output", position = {-5, 0}},
      },
      production_type = "input-output",
      filter = "water"
    },
    output_fluid_box = {
      base_area = 1,
      height = 2,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
       {type = "input-output", position = {0, 5}},
           {type = "input-output", position = {0, -5}},
      },
      production_type = "output",
      filter = "steam"
    },
    energy_consumption = "1.799MW",
    energy_source = {
      type = "electric",
      input_priority = "primary",
      usage_priority = "primary-input",
      --emissions_per_minute = 0 -- NO Emmisions
    },
    working_sound = {
      sound = {
        filename = "__base__/sound/boiler.ogg",
        volume = 0.9
      },
      max_sounds_per_type = 3
    },
    structure = {
      north = {
        layers = {
          {
            filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            priority = "high",
            width = 288,
            height = 288,
            hr_version = {
              filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
              priority = "high",
              width = 288,
              height = 288,
            }
          },
        }
      },
      east = {
        layers = {
          {
            filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            priority = "high",
            width = 288,
            height = 288,
            hr_version = {
              filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
              priority = "high",
                          width = 288,
                          height = 288,
            }
          },
        },
      },
      south = {
        layers = {
          {
            filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            priority = "high",
            width = 288,
            height = 288,
            hr_version = {
              filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
              priority = "high",
              width = 288,
              height = 288,
            }
          },
        }
      },
      west = {
        layers = {
          {
            filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
            priority = "high",
            width = 288,
            height = 288,
            hr_version = {
              filename = ENTITYPATH .. "Bio_Solar_Boiler.png",
              priority = "high",
              width = 288,
              height = 288,
            }
          },
        }
      }
    },
    fire_flicker_enabled = false,
    fire = {},
    fire_glow_flicker_enabled = false,
    fire_glow = {
      north = {
        filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
        priority = "extra-high",
        frame_count = 1,
        width = 62,
        height = 62,
        shift = {0.09, -2.8},
        scale = 1.5,
        blend_mode = "additive",
        hr_version = {
          filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
          priority = "extra-high",
          frame_count = 1,
          width = 62,
          height = 62,
          shift = {0.09, -2.8},
          scale = 1.5,
          blend_mode = "additive",
        }
      },
      east = {
        filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
        priority = "extra-high",
        frame_count = 1,
        width = 62,
        height = 62,
        shift = {0, -3},
        blend_mode = "additive",
        hr_version = {
          filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
          priority = "extra-high",
          frame_count = 1,
          width = 62,
          height = 62,
          shift = {0, -3},
          blend_mode = "additive",
        }
      },
      south = {
        filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
        priority = "extra-high",
        frame_count = 1,
        width = 62,
        height = 62,
        shift = {0, -3},
        blend_mode = "additive",
        hr_version = {
          filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
          priority = "extra-high",
          frame_count = 1,
          width = 62,
          height = 62,
          shift = {0, -3},
          blend_mode = "additive",
        }
      },
      west = {
        filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
        priority = "extra-high",
        frame_count = 1,
        width = 62,
        height = 62,
        shift = {0, -3},
        blend_mode = "additive",
        hr_version = {
          filename = "__Bio_Industries__/graphics/entities/small-lamp/light-on-patch.png",
          priority = "extra-high",
          frame_count = 1,
          width = 62,
          height = 62,
          shift = {0, -3},
          blend_mode = "additive",
        }
      },
    },
    burning_cooldown = 20
  },
})

end
