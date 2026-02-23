local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local ENTITYPATH = "__base__/graphics/entity/boiler/"
local ENTITYPATH_BIO = BioInd.modRoot .. "/graphics/entities/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"


require("util")
--require("prototypes.Bio_Fuel.pipeConnectors")


-- Changed for 0.18.29: We always want to make advanced fertilizer, so we need to
-- unlock the bio-reactor and the most basic recipe for algae biomass even if
-- BI.Settings.BI_Bio_Fuel has been turned off!


------------------------------------------------------------------------------------
--                                   Bio reactor                                  --
------------------------------------------------------------------------------------
-- Pipes
function assembler2pipepicturesBioreactor()
  return {
    north = {
      filename = "__core__/graphics/empty.png",
      priority = "low",
      width = 1,
      height = 1,
      shift = util.by_pixel(2.5, 14),
    },
    east = {	
        filename = ENTITYPATH_BIO .. "bio_reactor/pipes/bioreactor-pipe-e.png",
        priority = "low",
        width = 42,
        height = 76,
        shift = util.by_pixel(-24.5, 1),
        scale = 0.5,
		},
    south = {
        filename = ENTITYPATH_BIO .. "bio_reactor/pipes/bioreactor-pipe-s.png",
        priority = "low",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5,     
		},
    west = {
        filename = ENTITYPATH_BIO .. "bio_reactor/pipes/bioreactor-pipe-w.png",
        priority = "low",
        width = 39,
        height = 73,
        shift = util.by_pixel(25.75, 1.25),
        scale = 0.5,
      },  
  }
end




data:extend({
    -- BIO_REACTOR
    {
        type = "assembling-machine",
        name = "bi-bio-reactor",
        icons = {{ icon = ICONPATH_E .. "bioreactor.png", icon_size = 64 }},
        -- This is necessary for "Space Exploration" (if not true, the entity can only be
        -- placed on Nauvis)!
        se_allow_in_space = true,
        flags = { "placeable-neutral", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.5, result = "bi-bio-reactor" },
        max_health = 100,
        corpse = "bi-bio-reactor-remnant",
	  fluid_boxes = {
		{
		  production_type = "input",
		  pipe_picture = assembler2pipepicturesBioreactor(),
		  pipe_covers = pipecoverspictures(),
		  volume = 1000,
		  base_area = 10,
		  base_level = -1,
		  pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
		  -- pipe_connections = {{ type = "input", position = {0, -2} }},
		  render_layer = "higher-object-under",
		},
		{
		  production_type = "input",
		  pipe_picture = assembler2pipepicturesBioreactor(),
		  pipe_covers = pipecoverspictures(),
		  volume = 1000,
		  base_area = 10,
		  base_level = -1,
		  pipe_connections = { { flow_direction = "input", direction = defines.direction.east, position = { 1, 0 } } },
		 -- pipe_connections = {{ type = "input", position = {2, 0} }},
		  render_layer = "higher-object-under",
		},
		{
		  production_type = "input",
		  pipe_picture = assembler2pipepicturesBioreactor(),
		  pipe_covers = pipecoverspictures(),
		  volume = 1000,
		  base_area = 10,
		  base_level = -1,
		  pipe_connections = { { flow_direction = "input", direction = defines.direction.south, position = { 0, 1 } } },
		  --pipe_connections = {{ type = "input", position = {0, 2} }},
		  render_layer = "higher-object-under",
		},
		{
		  production_type = "output",
		  pipe_picture = assembler2pipepicturesBioreactor(),
		  pipe_covers = pipecoverspictures(),
		  volume = 1000,
		  base_area = 10,
		  base_level = 1,
		  pipe_connections = { { flow_direction = "output", direction = defines.direction.west, position = { -1, -1 } } },
		  --pipe_connections = {{ type = "output", position = {-2, -1} }},
		  render_layer = "higher-object-under",
		},
		{
		  production_type = "output",
		  pipe_picture = assembler2pipepicturesBioreactor(),
		  pipe_covers = pipecoverspictures(),
		  volume = 1000,
		  base_area = 10,
		  base_level = 1,
		  pipe_connections = { { flow_direction = "output", direction = defines.direction.west, position = { -1, 1 } } },
		  --pipe_connections = {{ type = "output", position = {-2, 1} }},
		  render_layer = "higher-object-under",
		},

	  },		
        fluid_boxes_off_when_no_fluid_recipe = true,
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },

		graphics_set = {
				-- Base animation (idle state) - Factorio 2.0 syntax
				animation = {
					layers = {
						{
							filename = ENTITYPATH_BIO .. "bio_reactor/bioreactor_idle.png",
							priority = "high",
							width = 182,
							height = 256,
							frame_count = 1,
							repeat_count = 18, -- match working animation frame count
							shift = { 0, -0.125 }, -- Consistent shift (converted from -0.5 to tiles)
							scale = 0.5
						},
						{
							filename = ENTITYPATH_BIO .. "bio_reactor/bioreactor_shadow.png",
							width = 270,
							height = 256,
							frame_count = 1,
							repeat_count = 18, -- match working animation frame count
							draw_as_shadow = true,
							shift = { 0.5, -0.125 }, -- Consistent shift with main sprite
							scale = 0.5
						}
					}
				},
				
				-- Working visualizations - triggers when recipe is active
				working_visualisations = {
					{
						-- Main working animation
						animation = {
							layers = {
								{
									filename = ENTITYPATH_BIO .. "bio_reactor/bioreactor_anim.png",
									priority = "high",
									width = 182,
									height = 256,
									frame_count = 18,
									line_length = 6,
									animation_speed = 0.4,
									shift = { 0, -0.125 }, -- FIXED: Same shift as idle animation
									scale = 0.5
								}
							}
						},
						-- This ensures the working animation plays over the idle animation
						always_draw = false, -- Only draw when working
						apply_recipe_tint = "primary", -- Optional: tint based on recipe
					}
				}
			},

        energy_source = {
            type = "electric",
            usage_priority = "secondary-input"
        },
        crafting_categories = { "biofarm-mod-bioreactor" },
        ingredient_count = 3,
        crafting_speed = 1,
        energy_usage = "10kW",
        module_specification = {
            module_slots = 3
        },
        allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    },
	
	--- corpse
	
	{
	  type = "corpse",
	  name = "bi-bio-reactor-remnant",
	  localised_name = {"entity-name.bi-bio-reactor-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	  tile_width = 3,
	  tile_height = 3,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "bioreactor_remnant.png",
		  line_length = 1,
		  width = 182,
		  height = 256,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, -0.5},
		  scale = 0.5
		}
	  }
	},

})

if BI.Settings.BI_Bio_Fuel then
    data:extend({
        --- Bio Boiler
        {
            type = "boiler",
            name = "bi-bio-boiler",
            localised_name = { "entity-name.bi-bio-boiler" },
            localised_description = { "entity-description.bi-bio-boiler" },
            icons = { {icon = ICONPATH_E .. "bio_boiler.png", icon_size = 64,} },
            -- This is necessary for "Space Exploration" (if not true, the entity can only be
            -- placed on Nauvis)!
            se_allow_in_space = true,
            flags = { "placeable-neutral", "player-creation" },
            minable = { hardness = 0.2, mining_time = 0.5, result = "bi-bio-boiler" },
            max_health = 300,
			corpse = "boiler-remnants",
			dying_explosion = "boiler-explosion",
			impact_category = "metal-large",
            mode = "output-to-separate-pipe",
            resistances = {
                {
                    type = "fire",
                    percent = 100
                },
                {
                    type = "explosion",
                    percent = 100
                },
                {
                    type = "impact",
                    percent = 35
                }
            },
            collision_box = { { -1.29, -0.79 }, { 1.29, 0.79 } },
            selection_box = { { -1.5, -1 }, { 1.5, 1 } },
            target_temperature = 165,
            fluid_box = {
                volume = 200,
                base_level = -1,
                pipe_covers = pipecoverspictures(),
                pipe_connections = {
                    { flow_direction = "input-output", direction = defines.direction.west, position = { -1, 0.5 } },
                    { flow_direction = "input-output", direction = defines.direction.east, position = { 1, 0.5 } }
                },
                production_type = "input-output",
                filter = "water"
            },
            output_fluid_box = {
                volume = 200,
                base_level = 1,
                pipe_covers = pipecoverspictures(),
                pipe_connections = {
                    { flow_direction = "output", direction = defines.direction.north, position = { 0, -0.5 } }
                },
                production_type = "output",
                filter = "steam"
            },
            energy_consumption = "3.6MW",
            energy_source = {
                type = "burner",
                fuel_categories = { "chemical" },
                effectivity = 1,
                fuel_inventory_size = 2,
                emissions_per_minute = { pollution = 15 },
                smoke = {
                    {
                        name = "smoke",
                        north_position = util.by_pixel(-38, -47.5),
                        south_position = util.by_pixel(38.5, -32),
                        east_position = util.by_pixel(20, -70),
                        west_position = util.by_pixel(-19, -8.5),
                        frequency = 20,
                        starting_vertical_speed = 0.0,
                        starting_frame_deviation = 60
                    }
                }
            },
            working_sound = {
                sound = {
                    filename = "__base__/sound/boiler.ogg",
                    volume = 0.8
                },
                max_sounds_per_type = 3
            },
            pictures = {
                north = {
                    structure = {
                        layers = {
                            {
                                filename = ENTITYPATH_BIO .. "bio_boiler/boiler-N-idle.png",
                                priority = "extra-high",
                                width = 269,
                                height = 221,
                                shift = util.by_pixel(-1.25, 5.25),
                                scale = 0.5,
                            },
                            {
                                filename = ENTITYPATH .. "boiler-N-shadow.png",
                                priority = "extra-high",
                                width = 274,
                                height = 164,
                                scale = 0.5,
                                shift = util.by_pixel(20.5, 9),
                                draw_as_shadow = true,
                            }
                        }
                    }
                },
                east = {
                    structure = {
                        layers = {
                            {
                                filename = ENTITYPATH_BIO .. "bio_boiler/boiler-E-idle.png",
                                priority = "extra-high",
                                width = 216,
                                height = 301,
                                shift = util.by_pixel(-3, 1.25),
                                scale = 0.5,
                            },
                            {
                                filename = ENTITYPATH .. "boiler-E-shadow.png",
                                priority = "extra-high",
                                width = 184,
                                height = 194,
                                scale = 0.5,
                                shift = util.by_pixel(30, 9.5),
                                draw_as_shadow = true,
                            }
                        }
                    }
                },
                south = {
                    structure = {
                        layers = {
                            {
                                filename = ENTITYPATH_BIO .. "bio_boiler/boiler-S-idle.png",
                                priority = "extra-high",
                                width = 260,
                                height = 192,
                                shift = util.by_pixel(4, 13),
                                scale = 0.5,
                            },
                            {
                                filename = ENTITYPATH .. "boiler-S-shadow.png",
                                priority = "extra-high",
                                width = 311,
                                height = 131,
                                scale = 0.5,
                                shift = util.by_pixel(29.75, 15.75),
                                draw_as_shadow = true,
                            }
                        }
                    }
                },
                west = {
                    structure = {
                        layers = {
                            {
                                filename = ENTITYPATH_BIO .. "bio_boiler/boiler-W-idle.png",
                                priority = "extra-high",
                                width = 196,
                                height = 273,
                                shift = util.by_pixel(1.5, 7.75),
                                scale = 0.5,
                            },
                            {
                                filename = ENTITYPATH .. "boiler-W-shadow.png",
                                priority = "extra-high",
                                width = 206,
                                height = 218,
                                scale = 0.5,
                                shift = util.by_pixel(19.5, 6.5),
                                draw_as_shadow = true,
                            }
                        }
                    }
                }
            },
            patch = {
                east = {
                    filename = ENTITYPATH .. "boiler-E-patch.png",
                    width = 6,
                    height = 36,
                    shift = util.by_pixel(33.5, -13.5),
                    scale = 0.5,
                },
            },
            fire_flicker_enabled = true,
            fire = {
                north = {
                    filename = ENTITYPATH .. "boiler-N-fire.png",
                    priority = "extra-high",
                    frame_count = 64,
                    line_length = 8,
                    width = 26,
                    height = 26,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0, -8.5),
                    scale = 0.5
                },
                east = {
                    filename = ENTITYPATH .. "boiler-E-fire.png",
                    priority = "extra-high",
                    frame_count = 64,
                    line_length = 8,
                    width = 28,
                    height = 28,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-9.5, -22),
                    scale = 0.5
                },
                south = {
                    filename = ENTITYPATH .. "boiler-S-fire.png",
                    priority = "extra-high",
                    frame_count = 64,
                    line_length = 8,
                    width = 26,
                    height = 16,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-1, -26.5),
                    scale = 0.5
                },
                west = {
                    filename = ENTITYPATH .. "boiler-W-fire.png",
                    priority = "extra-high",
                    frame_count = 64,
                    line_length = 8,
                    width = 30,
                    height = 29,
                    animation_speed = 0.5,
                    shift = util.by_pixel(13, -23.25),
                    scale = 0.5
                }
            },
            fire_glow_flicker_enabled = true,
            fire_glow = {
                north = {
                    filename = ENTITYPATH .. "boiler-N-light.png",
                    priority = "extra-high",
                    frame_count = 1,
                    width = 200,
                    height = 173,
                    shift = util.by_pixel(-1, -6.75),
                    blend_mode = "additive",
                    scale = 0.5
                },
                east = {
                    filename = ENTITYPATH .. "boiler-E-light.png",
                    priority = "extra-high",
                    frame_count = 1,
                    width = 139,
                    height = 244,
                    shift = util.by_pixel(0.25, -13),
                    blend_mode = "additive",
                    scale = 0.5
                },
                south = {
                    filename = ENTITYPATH .. "boiler-S-light.png",
                    priority = "extra-high",
                    frame_count = 1,
                    width = 200,
                    height = 162,
                    shift = util.by_pixel(1, 5.5),
                    blend_mode = "additive",
                    scale = 0.5
                },
                west = {
                    filename = ENTITYPATH .. "boiler-W-light.png",
                    priority = "extra-high",
                    frame_count = 1,
                    width = 136,
                    height = 217,
                    shift = util.by_pixel(2, -6.25),
                    blend_mode = "additive",
                    scale = 0.5
                }
            },
            burning_cooldown = 20
        },

    })
end
