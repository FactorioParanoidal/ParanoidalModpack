require ("prototypes.Bio_Farm.pipeConnectors")
require ("util")



	inv_extension2 =
{
	
		filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Idle_alt.png",
		priority = "high",
		width = 320,
		height = 320,
		frame_count = 1,
		direction_count = 1,
		shift = {0.75, 0},
		--axially_symmetrical = false,
		

}


data:extend({

 
------- Seedling
  {
    type = "land-mine",
    name = "seedling",
    icon = "__Bio_Industries__/graphics/icons/Seedling.png",
	icon_size = 32,
	order = "x[bi]-a[bi-seedling]",
	flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air",},
    minable =
    {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    emissions_per_tick = -0.0006,
    max_health = 5,

    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	subgroup = "intermediate-product",

    vehicle_impact_sound = { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
	picture_safe =
	{
		filename = "__Bio_Industries__/graphics/icons/Seedling_a.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	picture_set =
    {
		filename = "__Bio_Industries__/graphics/icons/Seedling_b.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	trigger_radius = 0,
  },
  
  ------- Seedling - Dummy for Seed Bomb
  {
    type = "land-mine",
    name = "seedling-2",
    icon = "__Bio_Industries__/graphics/icons/Seedling.png",
	icon_size = 32,
	order = "x[bi]-a[bi-seedling]",
	flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air",},
    minable =
    {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    emissions_per_tick = -0.0006,
    max_health = 5,

    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	subgroup = "intermediate-product",

    vehicle_impact_sound = { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
	picture_safe =
	{
		filename = "__Bio_Industries__/graphics/icons/Seedling_a.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	picture_set =
    {
		filename = "__Bio_Industries__/graphics/icons/Seedling_b.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	trigger_radius = 0,
  },
  
    ------- Seedling - Dummy for Seed Bomb
  {
    type = "land-mine",
    name = "seedling-3",
    icon = "__Bio_Industries__/graphics/icons/Seedling.png",
	icon_size = 32,
	order = "x[bi]-a[bi-seedling]",
	flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air",},
    minable =
    {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    emissions_per_tick = -0.0006,
    max_health = 5,

    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	subgroup = "intermediate-product",

    vehicle_impact_sound = { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
	picture_safe =
	{
		filename = "__Bio_Industries__/graphics/icons/Seedling_a.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	picture_set =
    {
		filename = "__Bio_Industries__/graphics/icons/Seedling_b.png",
		priority = "extra-high",
		width = 32,
		height = 32,
    },
	trigger_radius = 0,
  },

  ------- Bio Farm 
  {
    type = "assembling-machine",
    name = "bi-bio-farm",
    icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Icon.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-farm"},
    max_health = 250,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 70}},
	fluid_boxes =
    {
		{
        production_type = "input",
        --pipe_picture = bio_farm_pipe_pictures(),	
        --pipe_covers = bio_farm_pipe_covers_pictures(),
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,        
		pipe_connections = {{ type="input", position = {-1, -5} }}
		},
		{
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
		--pipe_covers = bio_farm_pipe_covers_pictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, -5} }}
		},
      off_when_no_fluid_recipe = true
	  
    },

	collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},

	animation =
	{
		filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Idle.png",
		priority = "high",
        width = 348,
        height = 288,
        shift = {0.96, 0},
		frame_count = 1,

	},
	
	working_visualisations =
	{

		animation =
		{
			filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Working.png",
			priority = "high",
			width = 348,
			height = 288,
			shift = {0.96, 0},
			frame_count = 1,
		},
	},
    crafting_categories = {"biofarm-mod-farm"},
    crafting_speed = 1,
    energy_source =

	{
      type = "electric",
      usage_priority = "primary-input",
	  drain = "50kW",
	  emissions = -0.2, -- the "-" means it eats pollution. Absorbs about 20 PU
    },	

    energy_usage = "100kW",
    ingredient_count = 3,
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	module_specification =
    {
      module_slots = 3
    },
	allowed_effects = {"consumption", "speed", "productivity", "pollution"},
  },

------- Bio Farm Lamp
  {
    type = "lamp",
    name = "bi-bio-farm-light",
    icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Lamp.png",
	icon_size = 32,
	flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable", "not-blueprintable"},
	selectable_in_game = false,
    max_health = 1,
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
	collision_mask = {},
	energy_source =
    {
		type = "electric",
		render_no_network_icon = false,
		render_no_power_icon = false,
		usage_priority = "lamp"
    },
    energy_usage_per_tick = "100kW",
    light = {intensity = 1, size = 45},
    picture_off =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Idle.png",
      priority = "low",
      width = 1,
      height = 1,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
	  shift = {0.75, 0},
    },
    picture_on =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Working.png",
      priority = "low",
      width = 1,
      height = 1,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
	  shift = {0.75, 0},
    },

  },

------- Bio Farm Hidden Electric Pole
  {
    type = "electric-pole",
    name = "bi-bio-farm-electric-pole",
    icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Cabeling.png",
	icon_size = 32,
	flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable", "not-blueprintable"},
	selectable_in_game = false,
    max_health = 1,
    resistances = {{type = "fire", percent = 100}},
    collision_box = {{-0, -0}, {0, 0}},
	collision_mask = {},
    maximum_wire_distance = 10,
    supply_area_distance = 5,
    pictures =
    {
      filename = "__Bio_Industries__/graphics/icons/empty.png",
      priority = "low",
      width = 1,
      height = 1,
	  frame_count = 1,
      axially_symmetrical = false,
      direction_count = 4,
	  shift = {0.75, 0},
    },
    connection_points =
    {
      {
        shadow =
        {

        },
        wire =
        {

        }
      },
      {
        shadow =
        {
 
        },
        wire =
        {

        }
      },
      {
        shadow =
        {

        },
        wire =
        {

        }
      },
      {
        shadow =
        {

        },
        wire =
        {

        }
      }

	},
    radius_visualisation_picture =
    {
      filename = "__Bio_Industries__/graphics/icons/empty.png",
      width = 1,
      height = 1,
      priority = "low"
    },
  },
  
------- Bio Farm Solar Panel
  {
    type = "solar-panel",
    name = "bi-bio-farm-solar-panel",
    icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Solar.png",
	icon_size = 32,
	flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable", "not-blueprintable"},
	selectable_in_game = false,
    max_health = 1,
    resistances = {{type = "fire", percent = 100}},
    collision_box = {{-0, -0}, {0, 0}},
	collision_mask = {},
    energy_source =
    {
      type = "electric",
      usage_priority = "solar"
    },
    picture =
    {
      filename = "__Bio_Industries__/graphics/icons/empty.png",
      priority = "low",
      width = 1,
      height = 1,
    },
    production = "100kW"
  },
	
------ Greenhouse
   {
    type = "assembling-machine",
    name = "bi-bio-greenhouse",
    icon = "__Bio_Industries__/graphics/icons/bio_greenhouse.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.25, result = "bi-bio-greenhouse"},
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 250,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    crafting_categories = {"biofarm-mod-greenhouse"},
    crafting_speed = 1,
    energy_source =

	{
      type = "electric",
      usage_priority = "primary-input",
	  drain = "15kW",
	  emissions = -0.1, -- the "-" means it eats pollution. Absorbs about 10 PU
    },	

    energy_usage = "50kW",
    ingredient_count = 3,
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -2} }}
      },
    },
	module_specification =
    {
      module_slots = 2
    },
	allowed_effects = {"consumption", "speed", "productivity", "pollution"},
	animation =
    {
      filename = "__Bio_Industries__/graphics/entities/biofarm/bio_greenhouse_off.png",
      width = 113,
      height = 93,
      frame_count = 1,
      scale = 1,
      shift = {0.3, 0}
    },
    working_visualisations =
    {
      {
        light = {intensity = 1, size = 6},
        animation =
        {
          filename = "__Bio_Industries__/graphics/entities/biofarm/bio_greenhouse_on.png",
          width = 113,
          height = 93,
          frame_count = 1,
          scale = 1,
          shift = {0.3, 0}
        }
      }
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  },

	-- COKERY
	{
		type = "assembling-machine",
		name = "bi-cokery",
		icon = "__Bio_Industries__/graphics/icons/cokery.png",
		icon_size = 32,
		flags = {"placeable-neutral","placeable-player", "player-creation"},
		order = "a[cokery]",
		minable = {hardness = 0.2, mining_time = 0.5, result = "bi-cokery"},
		max_health = 200,
		corpse = "medium-remnants",
		resistances = {{type = "fire", percent = 95}},
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		module_specification =
		{
			module_slots = 2
		},
		allowed_effects = {"consumption", "speed", "pollution"},	
		animation =
			{
				filename = "__Bio_Industries__/graphics/entities/cokery/cokery_sheet.png",
				frame_count = 28,
				line_length = 7,
				width = 256,
				height = 256,
				scale = 0.5,
				shift = {0.5, -0.5},
				animation_speed = 0.1
			},		
		crafting_categories = {"biofarm-mod-smelting"},
		energy_source =
		{
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions = 0.05     
		},
		energy_usage = "180kW",
		crafting_speed = 2,
		ingredient_count = 1
		
	},
	
	-- STONECRUSHER
	{
		type = "furnace",
		name = "bi-stone-crusher",
		icon = "__Bio_Industries__/graphics/icons/stone_crusher.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {hardness = 0.2,mining_time = 0.5,result = "bi-stone-crusher"},
		max_health = 100,
		corpse = "medium-remnants",
		module_slots = 1,
		resistances = {{type = "fire",percent = 70}},
		working_sound = {
							sound = {
										filename = "__base__/sound/assembling-machine-t1-1.ogg",
										volume = 0.7
									},
							apparent_volume = 1.5
						},
		collision_box = {{-0.8,-0.8},{0.8,0.8}},
		selection_box = {{-1.0,-1.0},{1.0,1.0}},
		animation = {
							filename = "__Bio_Industries__/graphics/entities/stone-crusher/stone_crusher_anim.png",
							priority = "high",
							width = 65,
							height = 78,
							frame_count = 11,
							animation_speed = 0.5,
							shift = {0.0, -0.1}
						},
		working_visualisations = {
							filename = "__Bio_Industries__/graphics/entities/stone-crusher/stone-crusher-anim.png",
							priority = "high",
							width = 65,
							height = 78,
							frame_count = 11,
							animation_speed = 0.18 / 2.5,
							shift = {0.0, -0.1}
						},
		crafting_categories = {"biofarm-mod-crushing"},
		result_inventory_size = 1,
		source_inventory_size = 1,
		crafting_speed = 1,
		energy_source = {
							type = "electric",
							usage_priority = "secondary-input",
							emissions = 0.05 / 1.5
						},
		energy_usage = "50kW"
	},
	
	--- Seed Bomb Projectile - 1 
  {
    type = "projectile",
    name = "seed-bomb-projectile-1",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "nested-result",
            action =
            {
              type = "area",
              target_entities = false,
              repeat_count = 600,
              radius = 24,
              action_delivery =
              {
                type = "projectile",
                projectile = "seed-bomb-wave-1",
                starting_speed = 0.5
              }
            }
          }
        }
      }
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },

    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
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
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "nested-result",
            action =
            {
              type = "area",
              target_entities = false,
              repeat_count = 800,
              radius = 27,
              action_delivery =
              {
                type = "projectile",
                projectile = "seed-bomb-wave-2",
                starting_speed = 0.5
              }
            }
          }
        }
      }
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },

    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
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
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
			{
				type = "nested-result",
				action =
				{
				  type = "area",
				  target_entities = false,
				  repeat_count = 1000,
				  radius = 30,
				  action_delivery =
				  {
					type = "projectile",
					projectile = "seed-bomb-wave-3",
					starting_speed = 0.5
				  }
				}
			}
        }
      }
    },
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },

    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
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
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
		  {
			type = "direct",
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {
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
		animation =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		},
		shadow =
		{
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
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
		  {
			type = "direct",
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {

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
		animation =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		},
		shadow =
		{
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
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
		  {
			type = "direct",
			action_delivery =
			{
			  type = "instant",
			  target_effects =
			  {
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
		animation =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		},
		shadow =
		{
		  filename = "__core__/graphics/empty.png",
		  frame_count = 1,
		  width = 1,
		  height = 1,
		  priority = "high"
		}
	},
	
	--- 	Arboretum
  --- Radar Arboretum
  {
    type = "radar",
    name = "bi-arboretum-radar",
    icon = "__Bio_Industries__/graphics/icons/Arboretum_Icon.png",
	icon_size = 32,	
	flags = {"placeable-player", "player-creation", "not-deconstructable"},
	order = "y[bi]-a[bi-arboretum]",

	minable = nil, 
	max_health = 250,
    corpse = "big-remnants",
	dying_explosion = "medium-explosion",
	resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },

    collision_box = {{-0.70, -0.70}, {0.70, 0.70}},
    selection_box = {{-0.75, -0.75}, {0.75, 0.75}},
	
    energy_per_sector = "2MJ",
    max_distance_of_nearby_sector_revealed = 2,
    max_distance_of_sector_revealed = 5,
    energy_per_nearby_scan = "200kW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
	  emissions = -0.15, -- the "-" means it eats pollution. Absorbs about 15 PU
    },
    energy_usage = "150kW",
    pictures =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/radar/radar.png",
          priority = "extra-high",
          width = 98,
          height = 128,
          apply_projection = false,
          direction_count = 64,
          line_length = 8,
          shift = util.by_pixel(1, -16),
		  scale = 0.5,
          hr_version = {
            filename = "__base__/graphics/entity/radar/hr-radar.png",
            priority = "extra-high",
            width = 196,
            height = 254,
            apply_projection = false,
            direction_count = 64,
            line_length = 8,
            shift = util.by_pixel(1, -16),
            scale = 0.25
          }
        },
      }
    },
	
	
  },

  
	---- Arboretum Area Overlay
	{
		type = "ammo-turret",
		name = "bi-arboretum-area",
		icon = "__Bio_Industries__/graphics/icons/Arboretum_Icon.png",
		icon_size = 32,
		flags = {"not-deconstructable", "not-on-map", "placeable-off-grid", "not-repairable"},
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },	
		max_health = 250,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
		selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
		order = "x[bi]-a[bi-arboretum]",
		automated_ammo_count = 1,
		resistances = {},	
		inventory_size = 1,
		attack_parameters =
		{
			type = "projectile",
			ammo_category = "bullet",
			cooldown = 2,
			range = 75,
			projectile_creation_distance = 0.1,
			action ={}
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


		call_for_help_radius = 1			   

	},

	
	--- Assembling-Machine Arboretum
 {
    type = "assembling-machine",
    name = "bi-arboretum",
    icon = "__Bio_Industries__/graphics/icons/Arboretum_Icon.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-arboretum-area"},
    max_health = 250,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 70}},
	fluid_boxes =
    {
		{
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,        
		pipe_connections = {{ type="input", position = {-1, -5} }}
		},
		{
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, -5} }}
		},
      off_when_no_fluid_recipe = true
	  
    },

	collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
	order = "x[bi]-a[bi-arboretum]",

	animation =
	{
			filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Idle_alt.png",
			priority = "low",
			width = 320,
			height = 320,
			frame_count = 1,
			shift = {0.75, 0},
	},
	
	working_visualisations =
	{

		animation =
		{
				filename = "__Bio_Industries__/graphics/entities/biofarm/Bio_Farm_Working_alt.png",
				priority = "low",
				width = 320,
				height = 320,
				frame_count = 1,
				shift = {0.75, 0},
		},
	},

    crafting_categories = {"bi-arboretum"},
    crafting_speed = 0.000000000001,
    energy_source =
	{
      type = "electric",
      usage_priority = "primary-input",
	  --drain = "5W",
	  emissions = -0.15, -- the "-" means it eats pollution. Absorbs about 15 PU
    },	
    energy_usage = "150kW",
    ingredient_count = 3,
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	module_specification = {},

  },	

	
})

local my_pole_1 = util.table.deepcopy(data.raw["electric-pole"]["bi-bio-farm-electric-pole"])
my_pole_1.name = "bi-hidden-power-pole"
my_pole_1.draw_copper_wires = false
data:extend({my_pole_1})



