local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local ENTITYPATH_BIO = BioInd.modRoot .. "/graphics/entities/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"


require("util")


-- Pipes
------------------------------------------------------------------------------------
--                                    Bio farm                                    --
------------------------------------------------------------------------------------

function biofarmpipepictures()
  return
  {
    north = {
      filename = "__core__/graphics/empty.png",
      priority = "low",
      width = 1,
      height = 1,
    },
    east =
      {
        filename = ENTITYPATH_BIO .. "bio_farm/biofarm_pipes/bio_farm-pipe-E.png",
        priority = "extra-high",
        width = 42,
        height = 76,
        shift = util.by_pixel(-24.5, 1),
        scale = 0.5
      
    },
    south =
      {
        filename = ENTITYPATH_BIO .. "bio_farm/biofarm_pipes/bio_farm-pipe-S.png",
        priority = "extra-high",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5
      
    },
    west =
    {
        filename = ENTITYPATH_BIO .. "bio_farm/biofarm_pipes/bio_farm-pipe-W.png",
        priority = "extra-high",
        width = 39,
        height = 73,
        shift = util.by_pixel(25.75, 1.25),
        scale = 0.5
      
    }
  }
end

------------------------------------------------------------------------------------
--                                    Bio Greenhouse                               --
------------------------------------------------------------------------------------

function biogreenhousepipepictures()
  return
  {
    north = {
            filename = ENTITYPATH_BIO .. "bio_greenhouse/biogreenhouse_pipes/assembling-machine-3-pipe-N-exp.png",
            priority = "extra-high",
            width = 171,
            height = 152,
            shift = util.by_pixel(2.25, 13.5),
            scale = 0.5
    },
    east =
      {
            filename = ENTITYPATH_BIO .. "bio_greenhouse/biogreenhouse_pipes/assembling-machine-3-pipe-E.png",
            priority = "extra-high",
            width = 42,
            height = 76,
            shift = util.by_pixel(-24.5, 1),
            scale = 0.5
      
    },
    south =
      {
            filename = ENTITYPATH_BIO .. "bio_greenhouse/biogreenhouse_pipes/assembling-machine-3-pipe-S.png",
            priority = "extra-high",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
      
    },
    west =
    {
            filename = ENTITYPATH_BIO .. "bio_greenhouse/biogreenhouse_pipes/assembling-machine-3-pipe-W.png",
            priority = "extra-high",
            width = 39,
            height = 73,
            shift = util.by_pixel(25.75, 1.25),
            scale = 0.5
      
    }
  }
end



inv_extension2 = {
    filename = ENTITYPATH_BIO .. "bio_terraformer/arboretum.png",
    priority = "high",
	width = 640,
	height = 640,
	frame_count = 1,
	scale = 0.5,
	shift = { 0, 0 }
}


data:extend({
    ------- Seedling
    {
        type = "simple-entity-with-force",
        name = "seedling",
        localised_name = { "entity-name.seedling" },
        localised_description = { "entity-description.seedling" },
        icon = ICONPATH .. "Seedling.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling.png",
                icon_size = 64,
            }
        },
        order = "x[bi]-a[bi-seedling]",
        flags = { "placeable-neutral", "placeable-player", "player-creation", "breaths-air" },
        create_ghost_on_death = false,
        minable = {
            mining_particle = "wooden-particle",
            mining_time = 0.25,
            results = { { type = "item", name = "seedling", amount = 1 } },
            count = 1
        },
        corpse = nil,
        remains_when_mined = nil,
        emissions_per_second = { pollution = -0.0006 },
        max_health = 5,

        collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        subgroup = "trees",
        impact_category = "wood",
        picture = {
            filename = ICONPATH .. "Seedling_b.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            scale = 0.3
        },
    },

    ------- Seedling - Dummy for Seed Bomb
    {
        type = "simple-entity-with-force",
        name = "seedling-2",
        localised_name = { "entity-name.seedling" },
        localised_description = { "entity-description.seedling" },
        icon = ICONPATH .. "Seedling.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling.png",
                icon_size = 64,
            }
        },
        order = "x[bi]-a[bi-seedling]",
        flags = { "placeable-neutral", "placeable-player", "player-creation", "breaths-air" },
        create_ghost_on_death = false,
        minable = {
            mining_particle = "wooden-particle",
            mining_time = 0.25,
            results = { { type = "item", name = "seedling", amount = 1 } },
            count = 1
        },
        corpse = nil,
        remains_when_mined = nil,
        emissions_per_second = { pollution = -0.0006 },
        max_health = 5,

        collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        subgroup = "trees",
        impact_category = "wood",
        picture = {
            filename = ICONPATH .. "Seedling_b.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            scale = 0.3
        },
    },

    {
        type = "simple-entity-with-force",
        name = "seedling-3",
        localised_name = { "entity-name.seedling" },
        localised_description = { "entity-description.seedling" },
        icon = ICONPATH .. "Seedling.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling.png",
                icon_size = 64,
            }
        },
        order = "x[bi]-a[bi-seedling]",
        flags = { "placeable-neutral", "placeable-player", "player-creation", "breaths-air" },
        create_ghost_on_death = false,
        minable = {
            mining_particle = "wooden-particle",
            mining_time = 0.25,
            results = { { type = "item", name = "seedling", amount = 1 } },
            count = 1
        },
        corpse = nil,
        remains_when_mined = nil,
        emissions_per_second = { pollution = -0.0006 },
        max_health = 5,

        collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        subgroup = "trees",
        impact_category = "wood",
        picture = {
            filename = ICONPATH .. "Seedling_b.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            scale = 0.3
        },
    },

    ------- Bio Farm
    {
        type = "assembling-machine",
        name = "bi-bio-farm",
        icons = {{ icon = ICONPATH_E .. "bio_Farm_Icon.png", icon_size = 64, }},
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.5, result = "bi-bio-farm" },
        max_health = 350,
        corpse = "bi-bio-farm-remnant",
        dying_explosion = "medium-explosion",
        resistances = { { type = "fire", percent = 70 } },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = biofarmpipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                base_level = -1,
                pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { -1, -4 } } }
            },
            {
                production_type = "input",
                pipe_picture = biofarmpipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                base_level = -1,
                pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 1, -4 } } }
            },
        },
        fluid_boxes_off_when_no_fluid_recipe = true,
        collision_box = { { -4.2, -4.2 }, { 4.2, 4.2 } },
        selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = ENTITYPATH_BIO .. "bio_farm/bio_farm.png",
						priority = "high",
						width = 608,
						height = 800,
						frame_count = 1,
						scale = 0.5,
						shift = { 0, -2.0 }
					},
					{
						filename = ENTITYPATH_BIO .. "bio_farm/bio_farm_shadow.png",
						priority = "high",
						width = 800,
						height = 800,
						frame_count = 1,
						scale = 0.5,
						draw_as_shadow = true,
						shift = { 1, -2.0 }
					}
				}
			},
			working_visualisations = {
				{
					light = { intensity = 1.4, size = 10 },
					effect = "flicker",
					apply_recipe_tint = "primary",
					constant_speed = true,
					fadeout = true,
					animation = {
						filename = ENTITYPATH_BIO .. "bio_farm/bio_farm_light.png",
						priority = "high",
						width = 800,
						height = 800,
						scale = 0.5,
						frame_count = 1,
						shift = { 1, -2 },
						draw_as_light = true
					}
				}
			}
		},
        crafting_categories = { "biofarm-mod-farm" },
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "primary-input",
            drain = "50kW",
            emissions_per_minute = { pollution = -9 }, -- the "-" means it Absorbs pollution.
        },
        energy_usage = "100kW",
        ingredient_count = 3,
        open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
        close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
        module_slots = 3,
        allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    },

	--- Corpse
	{
	 
	 type = "corpse",
	  name = "bi-bio-farm-remnant",
	  localised_name = {"entity-name.bi-bio-farm-remnant"},
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
		  filename = REMNANTSPATH .. "bio_farm_remnant.png",
		  line_length = 1,
		  width = 728,
		  height = 800,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, -1.5},
		  scale = 0.5
		}
	  }
	},

})



data:extend({

    ------ Greenhouse / Nursary
    {
        type = "assembling-machine",
        name = "bi-bio-greenhouse",
        icons = { { icon = ICONPATH_E .. "bio_greenhouse.png", icon_size = 64, } },
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.25, result = "bi-bio-greenhouse" },
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
        max_health = 250,
        corpse = "bi-bio-greenhouse-remnant",
        dying_explosion = "medium-explosion",
        crafting_categories = { "biofarm-mod-greenhouse" },
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "primary-input",
            drain = "15kW",
            emissions_per_minute = { pollution = -6 }, -- the "-" means it Absorbs pollution.
        },
        energy_usage = "50kW",
        ingredient_count = 3,
        resistances = {
            {
                type = "fire",
                percent = 70
            }
        },
        fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = biogreenhousepipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                base_level = -1,
                pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } }
            },
        },
        module_slots = 2,
        allowed_effects = { "consumption", "speed", "productivity", "pollution" },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = ENTITYPATH_BIO .. "bio_greenhouse/bio_greenhouse.png",
						width = 192,
						height = 256,
						frame_count = 1,
						scale = 0.5,
						shift = { 0, -0.5 }
					},
					{
						filename = ENTITYPATH_BIO .. "bio_greenhouse/bio_greenhouse_shadow.png",
						width = 256,
						height = 128,
						frame_count = 1,
						scale = 0.5,
						draw_as_shadow = true,
						shift = { 1, -0.5 }
					}
				}
			},
			working_visualisations = {
				{
					light = { intensity = 1, size = 6 },
					draw_as_light = true,
					effect = "flicker",
					apply_recipe_tint = "primary",
					animation = {
						filename = ENTITYPATH_BIO .. "bio_greenhouse/bio_greenhouse_light_anim.png",
						width = 192,
						height = 256,
						frame_count = 10,
						scale = 0.5,
						animation_speed = 0.1,
						shift = { 0, -0.5 },
					}
				}
			}
		},
        open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
        close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 }
    },

	-- corpse	
{
  type = "corpse",
  name = "bi-bio-greenhouse-remnant",
  localised_name = {"entity-name.bi-bio-greenhouse-remnant"},
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
      filename = REMNANTSPATH .. "bio_greenhouse_remnant.png",
      line_length = 1,
      width = 384,
      height = 384,
      frame_count = 1,
      direction_count = 1,
      shift = {0, -0.5},
      scale = 0.5
    }
  }
},

    -- COKERY
    {
        type = "assembling-machine",
        name = "bi-cokery",
        icons = { { icon = ICONPATH_E .. "cokery.png", icon_size = 64, } },
        -- This is necessary for "Space Exploration" (if not true, the entity can only be
        -- placed on Nauvis)!
        se_allow_in_space = true,
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        order = "a[cokery]",
        minable = { hardness = 0.2, mining_time = 0.5, result = "bi-cokery" },
        max_health = 200,
        corpse = "bi-cokery-remnant",
        resistances = { { type = "fire", percent = 95 } },
        collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
        selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
        module_specification = { module_slots = 2 },
        allowed_effects = { "consumption", "speed", "pollution" },
		graphics_set = {
			-- Working animation (16 frames)
			animation = {
				layers = {
					{
						filename = ENTITYPATH_BIO .. "bio_cokery/cokery_anim.png",
						priority = "high",
						width = 256,
						height = 256,
						frame_count = 16,
						line_length = 8,
						animation_speed = 0.1,
						shift = { 0.5, -0.5 },
						scale = 0.5
					},
					{
						filename = ENTITYPATH_BIO .. "bio_cokery/cokery_shadow.png",
						width = 334,
						height = 126,
						frame_count = 1,
						repeat_count = 16, -- match working animation
						draw_as_shadow = true,
						shift = { 1.5, -0.5 },
						scale = 0.5
					}
				}
			}
		},
        crafting_categories = { "biofarm-mod-smelting" },
        energy_source = {
            type = "electric",
            input_priority = "secondary",
            usage_priority = "secondary-input",
            emissions_per_minute = { pollution = 2.5 },
        },
        energy_usage = "180kW",
        crafting_speed = 2,
        ingredient_count = 1
    },
	
	--- corpse
	
	{
	  type = "corpse",
	  name = "bi-cokery-remnant",
	  localised_name = {"entity-name.bi-cokery-remnant"},
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
		  filename = REMNANTSPATH .. "cokery_remnant.png",
		  line_length = 1,
		  width = 256,
		  height = 256,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0.5, -0.5},
		  scale = 0.5
		}
	  }
	},

    -- STONECRUSHER
    {
        type = "furnace",
        name = "bi-stone-crusher",
        icon = ICONPATH_E .. "stone_crusher.png",
        icon_size = 64,
        -- This is necessary for "Space Exploration" (if not true, the entity can only be
        -- placed on Nauvis)!
        se_allow_in_space = true,
        flags = { "placeable-neutral", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.5, result = "bi-stone-crusher" },
        max_health = 100,
        corpse = "bi-stone-crusher-remnant",
        module_slots = 1,
        resistances = { { type = "fire", percent = 70 } },
        working_sound = {
            sound = {
                filename = "__base__/sound/assembling-machine-t1-1.ogg",
                volume = 0.7
            },
            apparent_volume = 1.5
        },
        collision_box = { { -0.8, -0.8 }, { 0.8, 0.8 } },
        selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		graphics_set = {
			animation = {
				filename = ENTITYPATH_BIO .. "bio_stone_crusher/stone_crusher_off.png",
				priority = "high",
				width = 130,
				height = 156,
				frame_count = 1,
				scale = 0.5,
				shift = { 0.0, -0.1 }
			},
			working_visualisations = {
				{
					animation = {
						filename = ENTITYPATH_BIO .. "bio_stone_crusher/stone_crusher_anim.png",
						priority = "high",
						width = 130,
						height = 156,
						frame_count = 20,
						line_length = 10,                
						animation_speed = 0.2,
						scale = 0.5,
						shift = { 0.0, -0.1 }
					}
				}
			},
		},
        crafting_categories = { "biofarm-mod-crushing" },
        result_inventory_size = 1,
        source_inventory_size = 1,
        crafting_speed = 1,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = { pollution = 0.25 },
        },
        energy_usage = "50kW",
        module_specification = {
            module_slots = 2
        },
        allowed_effects = { "consumption", "speed", "pollution" },
    },

--- corpse
	{
	  type = "corpse",
	  name = "bi-stone-crusher-remnant",
	  localised_name = {"entity-name.bi-stone-crusher-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-1, -1}, {1, 1}},
	  tile_width = 2,
	  tile_height = 2,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "stone_crusher_remnant.png",
		  line_length = 1,
		  width = 130,
		  height = 156,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, -0.2},
		  scale = 0.5
		}
	  }
	},


    --- Seed Bomb Projectile - 1
    {
        type = "projectile",
        name = "seed-bomb-projectile-1",
        flags = { "not-on-map" },
        acceleration = 0.005,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "nested-result",
                        action = {
                            type = "area",
                            target_entities = false,
                            repeat_count = 600,
                            radius = 24,
                            action_delivery = {
                                type = "projectile",
                                projectile = "seed-bomb-wave-1",
                                starting_speed = 0.5
                            }
                        }
                    }
                }
            }
        },
        light = { intensity = 0.8, size = 15 },
        animation = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket.png",
            frame_count = 8,
            line_length = 8,
            width = 9,
            height = 35,
            shift = { 0, 0 },
            priority = "high"
        },
        shadow = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket-shadow.png",
            frame_count = 1,
            width = 7,
            height = 24,
            priority = "high",
            shift = { 0, 0 }
        },
        smoke = {
            {
                name = "smoke-fast",
                deviation = { 0.15, 0.15 },
                frequency = 1,
                position = { 0, -1 },
                slow_down_factor = 1,
                starting_frame = 3,
                starting_frame_deviation = 5,
                starting_frame_speed = 0,
                starting_frame_speed_deviation = 5
            }
        }
    },

    --- Seed Bomb Projectile - 2
    {
        type = "projectile",
        name = "seed-bomb-projectile-2",
        flags = { "not-on-map" },
        acceleration = 0.005,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "nested-result",
                        action = {
                            type = "area",
                            target_entities = false,
                            repeat_count = 800,
                            radius = 27,
                            action_delivery = {
                                type = "projectile",
                                projectile = "seed-bomb-wave-2",
                                starting_speed = 0.5
                            }
                        }
                    }
                }
            }
        },
        light = { intensity = 0.8, size = 15 },
        animation = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket.png",
            frame_count = 8,
            line_length = 8,
            width = 9,
            height = 35,
            shift = { 0, 0 },
            priority = "high"
        },
        shadow = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket-shadow.png",
            frame_count = 1,
            width = 7,
            height = 24,
            priority = "high",
            shift = { 0, 0 }
        },
        smoke = {
            {
                name = "smoke-fast",
                deviation = { 0.15, 0.15 },
                frequency = 1,
                position = { 0, -1 },
                slow_down_factor = 1,
                starting_frame = 3,
                starting_frame_deviation = 5,
                starting_frame_speed = 0,
                starting_frame_speed_deviation = 5
            }
        }
    },

    --- Seed Bomb Projectile - 3
    {
        type = "projectile",
        name = "seed-bomb-projectile-3",
        flags = { "not-on-map" },
        acceleration = 0.005,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "nested-result",
                        action = {
                            type = "area",
                            target_entities = false,
                            repeat_count = 1000,
                            radius = 30,
                            action_delivery = {
                                type = "projectile",
                                projectile = "seed-bomb-wave-3",
                                starting_speed = 0.5
                            }
                        }
                    }
                }
            }
        },
        light = { intensity = 0.8, size = 15 },
        animation = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket.png",
            frame_count = 8,
            line_length = 8,
            width = 9,
            height = 35,
            shift = { 0, 0 },
            priority = "high"
        },
        shadow = {
            filename = "__Bio_Industries_2__/graphics/entities/rocket-shadow.png",
            frame_count = 1,
            width = 7,
            height = 24,
            priority = "high",
            shift = { 0, 0 }
        },
        smoke = {
            {
                name = "smoke-fast",
                deviation = { 0.15, 0.15 },
                frequency = 1,
                position = { 0, -1 },
                slow_down_factor = 1,
                starting_frame = 3,
                starting_frame_deviation = 5,
                starting_frame_speed = 0,
                starting_frame_speed_deviation = 5
            }
        }
    },

    --- Seed Bomb Wave - 1
    {
        type = "projectile",
        name = "seed-bomb-wave-1",
        flags = { "not-on-map" },
        acceleration = 0,
        action = {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "create-entity",
                            entity_name = "seedling",
                            check_buildability = true,
                            trigger_created_entity = true,
                        }
                    }
                }
            },
        },
        animation = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        },
        shadow = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        }
    },

    --- Seed Bomb Wave - 2
    {
        type = "projectile",
        name = "seed-bomb-wave-2",
        flags = { "not-on-map" },
        acceleration = 0,
        action = {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "create-entity",
                            entity_name = "seedling-2",
                            check_buildability = true,
                            trigger_created_entity = true,
                        }
                    }
                }
            },
        },
        animation = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        },
        shadow = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        }
    },

    --- Seed Bomb Wave - 3
    {
        type = "projectile",
        name = "seed-bomb-wave-3",
        flags = { "not-on-map" },
        acceleration = 0,
        action = {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "create-entity",
                            entity_name = "seedling-3",
                            check_buildability = true,
                            trigger_created_entity = true,
                        },
                    }
                }
            },
        },
        animation = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        },
        shadow = {
            filename = "__core__/graphics/empty.png",
            frame_count = 1,
            width = 1,
            height = 1,
            priority = "high"
        }
    },

    ---- Arboretum Area Overlay
    {
        type = "ammo-turret",
        name = "bi-arboretum-area",
        localised_name = { "entity-name.bi-arboretum" },
        localised_description = { "entity-description.bi-arboretum" },
        icons = { { icon = ICONPATH_E .. "arboretum_Icon.png", icon_size = 64, }},
        flags = { "not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable" },
        open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
        close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
        max_health = 250,
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        collision_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
        selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
        order = "x[bi]-a[bi-arboretum]",
        automated_ammo_count = 1,
        resistances = {},
        inventory_size = 1,
        attack_parameters = {
            type = "projectile",
            ammo_category = "bullet",
            cooldown = 2,
            range = 75,
            projectile_creation_distance = 0.1,
            action = {}
        },
        folding_speed = 0.08,
        folded_animation = (function()
            local res = util.table.deepcopy(inv_extension2)
            res.frame_count = 1
            res.line_length = 1
            return res
        end)(),

        folding_animation = (function()
            local res = util.table.deepcopy(inv_extension2)
            res.run_mode = "backward"
            return res
        end)(),

        call_for_help_radius = 1,
        graphics_set = {}
    },


    --- Assembling-Machine Arboretum
    {
        type = "assembling-machine",
        name = "bi-arboretum",
		icons = { { icon = ICONPATH_E .. "arboretum_Icon.png", icon_size = 64, }},
        flags = { "placeable-neutral", "placeable-player", "player-creation" },
        placeable_by = { item = "bi-arboretum-area", count = 1 }, -- Fixes that entity couldn't be blueprinted
        minable = { hardness = 0.2, mining_time = 0.5, result = "bi-arboretum-area" },
        max_health = 250,
        corpse = "bi-arboretum-area-remnant",
        dying_explosion = "medium-explosion",
        resistances = { { type = "fire", percent = 70 } },
        fluid_boxes = {
            {
                production_type = "input",
                --pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                base_level = -1,
                pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { -1, -4 } } }
            },
            {
                production_type = "input",
                --pipe_picture = assembler3pipepictures(),
                pipe_covers = pipecoverspictures(),
                volume = 1000,
                base_level = -1,
                pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 1, -4 } } }
            },
        },
        fluid_boxes_off_when_no_fluid_recipe = true,
        collision_box = { { -4.2, -4.2 }, { 4.2, 4.2 } },
        selection_box = { { -4.5, -4.5 }, { 4.5, 4.5 } },
        order = "x[bi]-a[bi-arboretum]",
		graphics_set = {
			animation = {
				layers = {
					{
						filename = ENTITYPATH_BIO .. "bio_terraformer/arboretum.png",
						width = 640,
						height = 640,
						frame_count = 1,
						scale = 0.5,
						shift = { 0, 0 }
					},
					{
						filename = ENTITYPATH_BIO .. "bio_terraformer/arboretum_shadow.png",
						width = 560,
						height = 640,
						frame_count = 1,
						scale = 0.5,
						draw_as_shadow = true,
						shift = { 1.5, 0 }
					}
				}
			},
			working_visualisations = {
				{
					light = { intensity = 1, size = 8 },
					animation = {
						filename = ENTITYPATH_BIO .. "bio_terraformer/arboretum_light.png",
						width = 560,
						height = 640,
						frame_count = 1,
						scale = 0.5,
						sshift = { 0.75, 1 }
					}
				}
			}
		},
        crafting_categories = { "bi-arboretum" },
        crafting_speed = 0.000000000001,
        energy_source = {
            type = "electric",
            usage_priority = "primary-input",
            emissions_per_minute = { pollution = -8 }, -- the "-" means it Absorbs pollution.
        },
        energy_usage = "150kW",
        ingredient_count = 3,
        open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
        close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
        module_specification = {},
    },
	
	--- Corpse
	{
	  type = "corpse",
	  name = "bi-arboretum-area-remnant",
	  localised_name = {"entity-name.bi-arboretum-area-remnant"},
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
		  filename = REMNANTSPATH .. "arboretum_remnant.png",
		  line_length = 1,
		  width = 640,
		  height = 640,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0,0},
		  scale = 0.5
		}
	  }
	},
	
})

