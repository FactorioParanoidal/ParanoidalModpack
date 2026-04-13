local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local BioInd = require('common')('Bio_Industries_2')
require("util")

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local ENTITYPATH_BIO = BioInd.modRoot .. "/graphics/entities/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"



if BI.Settings.BI_Solar_Additions then
    local sounds = {}
    sounds.walking_sound = {}
    for i = 1, 11 do
        sounds.walking_sound[i] = {
            filename = "__base__/sound/walking/concrete-" .. i .. ".ogg",
            volume = 1.2
        }
	end


	function big_accumulator_picture(tint, repeat_count)
		return
		{
		  layers =
		  {
			{
				filename = ENTITYPATH_BIO .. "bio_accumulator/bi_large_accumulator.png",
				priority = "extra-high",
				width = 307,
				height = 362,
				scale = 0.5,
				repeat_count = repeat_count,
				tint = tint,
				shift = {0, -0.6},
			},
			{
				filename = ENTITYPATH_BIO .. "bio_accumulator/bi_large_accumulator_shadow.png",
				priority = "extra-high",
				width = 384,
				height = 272,
				repeat_count = repeat_count,
				shift = {1, 0},
				scale = 0.5,
				draw_as_shadow = true,
			}
		  }
		}
	  end
	  
	function big_accumulator_charge()
    return
    {
      layers =
      {
        big_accumulator_picture({1, 1, 1, 1} , 24),
        {
            filename = ENTITYPATH_BIO .. "bio_accumulator/bi_large_accumulator_anim_charge.png",
            priority = "extra-high",
            width = 307,
            height = 362,
            line_length = 6,
            frame_count = 12,
            repeat_count = 2,
            draw_as_glow = true,
            shift = {0, -0.6},
            scale = 0.5,
            animation_speed = 0.3,
        }
      }
    }
  end
  
  function big_accumulator_reflection()
    return
    {
      pictures =
        {
          filename = ENTITYPATH_BIO .. "bio_accumulator/big-bi_large_accumulator_reflection.png",
          priority = "extra-high",
          width = 20,
          height = 24,
          shift = util.by_pixel(0, 50),
          variation_count = 1,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = false
    }
  end
  
  function big_accumulator_discharge()
    return
    {
      layers =
      {
        big_accumulator_picture({1, 1, 1, 1} , 24),
        {
            filename = ENTITYPATH_BIO .. "bio_accumulator/bi_large_accumulator_anim_discharge.png",
            priority = "extra-high",
            width = 307,
            height = 362,
            line_length = 6,
            frame_count = 24,
            draw_as_glow = true,
            shift = {0, -0.6},
            scale = 0.5,
            animation_speed = 0.4,
        }
      }
    }
  end


    data:extend({
        ------- Bio Farm Solar Panel
        {
            type = "solar-panel",
            name = "bi-bio-solar-farm",
            icon = ICONPATH_E .. "bio_Solar_Farm_Icon.png",
            icon_size = 64,
            icons = {
                {
                    icon = ICONPATH_E .. "bio_Solar_Farm_Icon.png",
                    icon_size = 64,
                }
            },
            -- This is necessary for "Space Exploration" (if not true, the entity can only be
            -- placed on Nauvis)!
            se_allow_in_space = true,
            flags = { "placeable-neutral", "player-creation" },
            minable = { hardness = 0.25, mining_time = 0.5, result = "bi-bio-solar-farm" },
            max_health = 600,
            corpse = "bi-bio-solar-farm-remnant",
            dying_explosion = "medium-explosion",
            resistances = { { type = "fire", percent = 80 } },
            collision_box = { { -4.2, -4.2 }, { 4.2, 4.2 } },
            selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
            energy_source = {
                type = "electric",
                usage_priority = "solar"
            },
			 picture =
			{
			  layers =
			  {
				{
				  filename = ENTITYPATH_BIO .. "bio_solar_farm/bio_Solar_Farm.png",
				  priority = "high",
				  width = 624,
				  height = 578,
				  shift = { 0.30, 0 },
				  scale = 0.5
				},
				{
				  filename = ENTITYPATH_BIO .. "bio_solar_farm/bio_Solar_Farm_shadow.png",
				  priority = "high",
				  width = 624,
				  height = 578,
				  shift = { 1.30, 0 },
				  draw_as_shadow = true,
				  scale = 0.5
				}
			  }
			},
            production = "3600kW"
        },
		
		---- corpse
	{
	  type = "corpse",
	  name = "bi-bio-solar-farm-remnant",
	  localised_name = {"entity-name.bi-bio-solar-farm-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
	  tile_width = 9,
	  tile_height = 9,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "bio_solar_farm_remnant.png",
		  line_length = 1,
		  width = 624,
		  height = 578,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0.3, 0},
		  scale = 0.5
		}
	  }
	},

        ---- BI Accumulator
{
    type = "accumulator",
    name = "bi-bio-accumulator",
    icon = ICONPATH_E .. "bi_LargeAccumulator.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH_E .. "bi_LargeAccumulator.png",
            icon_size = 64,
        }
    },
    -- This is necessary for "Space Exploration"
    se_allow_in_space = true,
    flags = { "placeable-neutral", "player-creation" },
    minable = { hardness = 0.2, mining_time = 0.5, result = "bi-bio-accumulator" },
    max_health = 500,
    corpse = "bi-bio-accumulator-remnant",
    collision_box = { { -1.75, -1.75 }, { 1.75, 1.75 } },
    selection_box = { { -2, -2 }, { 2, 2 } },

    energy_source = {
        type = "electric",
        buffer_capacity = "300MJ",
        usage_priority = "tertiary",
        input_flow_limit = "25MW",
        output_flow_limit = "25MW"
    },
	
    chargable_graphics =
    {
      picture = big_accumulator_picture(),
      charge_animation = big_accumulator_charge(),
      charge_cooldown = 30,
      discharge_animation = big_accumulator_discharge(),
      discharge_cooldown = 60
      --discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    },
    water_reflection = big_accumulator_reflection(),
    impact_category = "metal",
    open_sound = sounds.electric_large_open,
    close_sound = sounds.electric_large_close,
    working_sound =
    {
      main_sounds =
      {
        {
          sound = {filename = "__base__/sound/accumulator-working.ogg", volume = 0.4, modifiers = volume_multiplier("main-menu", 1.44)},
          match_volume_to_activity = true,
          activity_to_volume_modifiers = {offset = 2, inverted = true},
          fade_in_ticks = 4,
          fade_out_ticks = 20
        },
        {
          sound = {filename = "__base__/sound/accumulator-discharging.ogg", volume = 0.4, modifiers = volume_multiplier("main-menu", 1.44)},
          match_volume_to_activity = true,
          activity_to_volume_modifiers = {offset = 1},
          fade_in_ticks = 4,
          fade_out_ticks = 20
        }
      },
      idle_sound = {filename = "__base__/sound/accumulator-idle.ogg", volume = 0.35},
      max_sounds_per_type = 3,
      audible_distance_modifier = 0.5
    },

    circuit_connector = circuit_connector_definitions["accumulator"],
    circuit_wire_max_distance = 9,

    default_output_signal = {type = "virtual", name = "signal-A"},
    weight = 200 * kg
	},
	
	--- corpse
	
		{
		  type = "corpse",
		  name = "bi-bio-accumulator-remnant",
		  localised_name = {"entity-name.bi-bio-accumulator-remnant"},
		  icon = "__base__/graphics/icons/remnants.png",
		  icon_size = 64,
		  icon_mipmaps = 4,
		  BI_add_icon = true,
		  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
		  subgroup = "remnants",
		  order = "z-z-z",
		  selection_box = {{-2, -2}, {2, 2}},
		  tile_width = 4,
		  tile_height = 4,
		  selectable_in_game = false,
		  time_before_removed = 60 * 60 * 15, -- 15 minutes
		  final_render_layer = "remnants",
		  remove_on_tile_placement = false,
		  animation =
		  {
			{
			  filename = REMNANTSPATH .. "bi_large_accumulator_remnant.png",
			  line_length = 1,
			  width = 307,
			  height = 362,
			  frame_count = 1,
			  direction_count = 1,
			  shift = {0, -0.6},
			  scale = 0.5
			}
		  }
		},


        ---- Large Substation
        {
            type = "electric-pole",
            name = "bi-large-substation",
            localised_name = { "entity-name.bi-large-substation" },
            localised_description = { "entity-description.bi-large-substation" },
            icon = ICONPATH_E .. "bi_LargeSubstation_icon.png",
            icon_size = 64,
            icons = {
                {
                    icon = ICONPATH_E .. "bi_LargeSubstation_icon.png",
                    icon_size = 64,
                }
            },
            -- This is necessary for "Space Exploration" (if not true, the entity can only be
            -- placed on Nauvis)!
            se_allow_in_space = true,
            flags = { "placeable-neutral", "player-creation" },
            minable = { hardness = 0.2, mining_time = 0.5, result = "bi-large-substation" },
            max_health = 600,
            corpse = "bi-large-substation-remnant",
            dying_explosion = "big-explosion",
            track_coverage_during_build_by_moving = true,
            resistances = {
                {
                    type = "fire",
                    percent = 90
                }
            },
            collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
            selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
            drawing_box = { { -2.5, -5 }, { 2.5, 2.5 } },
            maximum_wire_distance = 25,
            -- Changed for 0.18.34/1.1.4
            supply_area_distance = 50.5,
			pictures = {
			layers = {
				{
					filename = ENTITYPATH_BIO .. "bio_substation/bio_substation.png",
					priority = "high",
					width = 384,
					height = 384,
					shift = { 0, 0 },
					direction_count = 1,
					scale = 0.5,
				},
				{
					filename = ENTITYPATH_BIO .. "bio_substation/bio_substation_shadow.png",
					priority = "high",
					width = 384,
					height = 384,
					shift = { 1, 0 },
					direction_count = 1,
					draw_as_shadow = true,
					scale = 0.5,
				},
			}
		},		
            working_sound = {
                sound = { filename = "__base__/sound/substation.ogg" },
                apparent_volume = 1.8,
                audible_distance_modifier = 0.5,
                probability = 1 / (3 * 60) -- average pause between the sound is 3 seconds
            },
            connection_points = {
                {
                    shadow = {
                        copper = { 1.9, -0.6 },
                        green = { 1.3, -0.6 },
                        red = { 2.65, -0.6 }
                    },
                    wire = {
                        copper = { -0.25, -2.71875 },
                        green = { -0.84375, -2.71875 },
                        red = { 0.34375, -2.71875 }
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
		
		--- corpse	
		{
		  type = "corpse",
		  name = "bi-large-substation-remnant",
		  localised_name = {"entity-name.bi-large-substation-remnant"},
		  icon = "__base__/graphics/icons/remnants.png",
		  icon_size = 64,
		  icon_mipmaps = 4,
		  BI_add_icon = true,
		  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
		  subgroup = "remnants",
		  order = "z-z-z",
		  selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
		  tile_width = 5,
		  tile_height = 5,
		  selectable_in_game = false,
		  time_before_removed = 60 * 60 * 15, -- 15 minutes
		  final_render_layer = "remnants",
		  remove_on_tile_placement = false,
		  animation =
		  {
			{
			  filename = REMNANTSPATH .. "large_substation_remnant.png",
			  line_length = 1,
			  width = 384,
			  height = 384,
			  frame_count = 1,
			  direction_count = 1,
			  shift = {0,0},
			  scale = 0.5
			}
		  }
		},


        ---- Solar Floor / Musk Floor
        {
            type = "tile",
            name = "bi-solar-mat",
            localised_name = { "entity-name.bi-solar-mat" },
            localised_description = { "entity-description.bi-solar-mat" },
            icon = ICONPATH_E .. "solar-mat.png",
            icon_size = 64,
            icons = {
                {
                    icon = ICONPATH_E .. "solar-mat.png",
                    icon_size = 64,
                }
            },
            needs_correction = false,
            minable = { hardness = 0.1, mining_time = 0.25, result = "bi-solar-mat" },
            mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
            collision_mask = { layers = { ground_tile = true } },
            --collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            walking_speed_modifier = 1.45,
			layer = 13,			
			layer_group = "ground-artificial",
			transition_overlay_layer_offset = 2,
            decorative_removal_probability = 1,
            variants = {
                transition = tile_graphics.generic_masked_tile_transitions1,
                main = {
                    {
                        picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor.png",
                        count = 1,
                        size = 1,
						scale = 0.5,
                        probability = 1,
                    },
                },
                inner_corner = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_inner-corner.png",
					count = 1,
					scale = 0.5,
                },
                inner_corner_mask = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_inner-corner-mask.png",
					count = 1,
					scale = 0.5,
                },
                outer_corner = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_outer-corner.png",
                    count = 1,
					scale = 0.5,
                },
                outer_corner_mask = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_outer-corner-mask.png",
                    count = 1,
					scale = 0.5,
                },
                side = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_side.png",
                    count = 1,
					scale = 0.5,
                },
                side_mask = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_side-mask.png",
                    count = 1,
					scale = 0.5,
                },
                u_transition = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_u.png",
                    count = 1,
					scale = 0.5,
                },
                u_transition_mask = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_u-mask.png",
                    count = 1,
					scale = 0.5,
                },
                o_transition = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_o.png",
                    count = 1,
					scale = 0.5,
                },
                o_transition_mask = {
                    picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor_o-mask.png",
                    count = 1,
					scale = 0.5,
                },
				material_background = {
                picture = ENTITYPATH_BIO .. "bio_musk_floor/solarfloor.png",
                count = 1,
				scale = 0.5,
				},
				
            },
            walking_sound = sounds.walking_sound,
            map_color = { r = 93, g = 138, b = 168 },
            vehicle_friction_modifier = dirt_vehicle_speed_modifer
        },
    })

 data:extend({
        ------- Boiler for Solar Plant / Boiler
	{
		type = "boiler",
		name = "bi-solar-boiler",
		icon = ICONPATH_E .. "bio_Solar_Boiler_Icon.png",
		icon_size = 64,
		icons = {
			{ icon = ICONPATH_E .. "bio_Solar_Boiler_Icon.png", icon_size = 64 }
		},
		se_allow_in_space = true,
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.2, mining_time = 1, result = "bi-solar-boiler" },
		max_health = 400,
		corpse = "bi-solar-boiler-remnant",
		vehicle_impact_sound = sounds.generic_impact,
		mode = "output-to-separate-pipe",
		resistances = {
			{ type = "fire", percent = 100 },
			{ type = "explosion", percent = 30 },
			{ type = "impact", percent = 30 }
		},
		collision_box = { { -4.2, -4.2 }, { 4.2, 4.2 } },
		selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
		target_temperature = 235,
		fluid_box = {
			volume = 200,
			base_level = -1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.east, position = { 4, 0 } },
				{ flow_direction = "input-output", direction = defines.direction.west, position = { -4, 0 } }
			},
			production_type = "input-output",
			filter = "water"
		},
		output_fluid_box = {
			volume = 200,
			base_level = 1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 4 } },
				{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -4 } }
			},
			production_type = "output",
			filter = "steam"
		},
		energy_consumption = "1.799MW",
		energy_source = {
			type = "electric",
			usage_priority = "primary-input",
			emissions_per_minute = { pollution = -1 }, -- Negative value: pollution is absorbed!
		},
		working_sound = {
			sound = { filename = "__base__/sound/boiler.ogg", volume = 0.9 },
			max_sounds_per_type = 3
		},
		pictures = {
			north = {
				structure = {
					layers = {
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5
						},
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_shadow.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5,
							draw_as_shadow = true
						}
					}
				},
				fire_glow = {
					filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_light.png",
					priority = "extra-high",
					frame_count = 1,
					width = 576,
					height = 576,
					scale = 0.5,
					blend_mode = "additive"
				}
			},

			east = {
				structure = {
					layers = {
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5
						},
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_shadow.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5,
							draw_as_shadow = true
						}
					}
				},
				fire_glow = {
					filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_light.png",
					priority = "extra-high",
					frame_count = 1,
					width = 576,
					height = 576,
					scale = 0.5,
					blend_mode = "additive"
				}
			},

			south = {
				structure = {
					layers = {
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5
						},
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_shadow.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5,
							draw_as_shadow = true
						}
					}
				},
				fire_glow = {
					filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_light.png",
					priority = "extra-high",
					frame_count = 1,
					width = 576,
					height = 576,
					scale = 0.5,
					blend_mode = "additive"
				}
			},

			west = {
				structure = {
					layers = {
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5
						},
						{
							filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_shadow.png",
							priority = "high",
							width = 576,
							height = 576,
							scale = 0.5,
							draw_as_shadow = true
						}
					}
				},
				fire_glow = {
					filename = ENTITYPATH_BIO .. "bio_solar_boiler/bio_Solar_Boiler_light.png",
					priority = "extra-high",
					frame_count = 1,
					width = 576,
					height = 576,
					scale = 0.5,
					blend_mode = "additive"
				}
			}
		},

		fire_flicker_enabled = false,
		fire_glow_flicker_enabled = false,
		burning_cooldown = 20
	},

	{
	  type = "corpse",
	  name = "bi-solar-boiler-remnant",
	  localised_name = {"entity-name.bi-solar-boiler-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
	  tile_width = 9,
	  tile_height = 9,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "bio_solar_boiler_remnant.png",
		  line_length = 1,
		  width = 576,
		  height = 576,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0,0},
		  scale = 0.5
		}
	  }
	},


    })
end
