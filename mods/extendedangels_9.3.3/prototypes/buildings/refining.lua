data:extend(
{
--HYDRO PLANT    
    {
    type = "item",
    name = "hydro-plant-4",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/hydro-plant.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    subgroup = "water-treatment-building",
    order = "b[hydro-plant4-]",
    place_result = "hydro-plant-4",
    stack_size = 10,
    },
	{
    type = "assembling-machine",
    name = "hydro-plant-4",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/hydro-plant.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
	flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "hydro-plant-4"},
	fast_replaceable_group = "hydro-plant",
    max_health = 300,
	corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"water-treatment"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.03 / 3.5
    },
    energy_usage = "350kW",
    ingredient_count = 4,
	animation ={
	layers={
	{
        filename = "__angelsrefining__/graphics/entity/hydro-plant/1hydro-plant.png",
		priority = "extra-high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
		animation_speed = 0.5
	},
	{
        filename = "__angelsrefining__/graphics/entity/hydro-plant/2hydro-plant-overlay.png",
		tint= {r=0.2, g=0.3, b=0.45},
		priority = "high",
        width = 288,
        height = 288,
        frame_count = 25,
		line_length = 5,
        shift = {0, 0},
	}
	}
	},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__angelsrefining__/sound/ore-leaching-plant.ogg" },
	  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
	fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = hydropipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, -4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepictures2(),
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {2, 4} }}
      },
	  {
        production_type = "output",
		pipe_picture = hydropipepictures(),
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {-2, 4} }}
      },
    },
	pipe_covers = pipecoverspictures(),
    },
--SALINATION PLANT
    {
        type = "item",
        name = "salination-plant-3",
        icons = {
            {
                icon = "__angelsrefining__/graphics/icons/salination-plant.png",
            },
            {
                icon = "__angelsrefining__/graphics/icons/num_3.png",
                tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                scale = 0.32,
                shift = {-12, -12},
            }
        },
        icon_size = 32,
        subgroup = "water-treatment-building",
        order = "d[salination-plant3]",
        place_result = "salination-plant-3",
        stack_size = 10,
        },
        {
        type = "assembling-machine",
        name = "salination-plant-3",
        icons = {
            {
                icon = "__angelsrefining__/graphics/icons/salination-plant.png",
            },
            {
                icon = "__angelsrefining__/graphics/icons/num_3.png",
                tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                scale = 0.32,
                shift = {-12, -12},
            }
        },
        icon_size = 32,
        flags = {"placeable-neutral","player-creation"},
        minable = {mining_time = 1, result = "salination-plant-3"},
        fast_replaceable_group = "salination-plant",
        max_health = 300,
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
        selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
        module_specification =
        {
          module_slots = 3
        },
        allowed_effects = {"consumption", "speed", "productivity", "pollution"},
        crafting_categories = {"salination-plant"},
        crafting_speed = 3,
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          emissions = 0.03 / 3.5
        },
        energy_usage = "200kW",
        ingredient_count = 4,
        animation ={
            filename = "__angelsrefining__/graphics/entity/salination-plant/salination-plant.png",
            priority = "extra-high",
            width = 288,
            height = 320,
            frame_count = 36,
            line_length = 6,
            shift = {0, -0.5},
            animation_speed = 0.5
        },
        vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        working_sound =
        {
          sound = { filename = "__angelsrefining__/sound/ore-leaching-plant.ogg" },
          idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
          apparent_volume = 2.5,
        },
        fluid_boxes =
        {
          {
            production_type = "input",
            --pipe_picture = salinationpipepictures(),
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{ type="input", position = {-1, -4} }}
          },
          {
            production_type = "output",
            --pipe_picture = salinationpipepictures2(),
            pipe_covers = pipecoverspictures(),
            base_level = 1,
            pipe_connections = {{ position = {1, 4} }}
          },
        },
        pipe_covers = pipecoverspictures(),
        },        
--WASHING PLANT
        {
            type = "item",
            name = "washing-plant-3",
            icons = {
                {
                    icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png",
                },
                {
                    icon = "__angelsrefining__/graphics/icons/num_3.png",
                    tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                    scale = 0.32,
                    shift = {-12, -12},
                }
            },
            icon_size = 32,
            subgroup = "washing-building",
            order = "c",
            place_result = "washing-plant-3",
            stack_size = 10,
          },
          {
            type = "assembling-machine",
            name = "washing-plant-3",
            icons = {
                {
                    icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png",
                },
                {
                    icon = "__angelsrefining__/graphics/icons/num_3.png",
                    tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                    scale = 0.32,
                    shift = {-12, -12},
                }
            },
            icon_size = 32,
            flags = {"placeable-neutral","player-creation"},
            minable = {mining_time = 1, result = "washing-plant-3"},
            fast_replaceable_group = "washing-plant",
            next_upgrade = "washing-plant-4",
            max_health = 300,
            corpse = "big-remnants",
            dying_explosion = "medium-explosion",
            collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
            selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
            module_specification =
            {
              module_slots = 3
            },
            allowed_effects = {"consumption", "speed", "pollution", "productivity"},
            crafting_categories = {"washing-plant"},
            crafting_speed = 3,
            energy_source =
            {
              type = "electric",
              usage_priority = "secondary-input",
              emissions = 0.03 / 3.5
            },
            energy_usage = "200kW",
            ingredient_count = 4,
            animation ={
            layers={
            {
                filename = "__angelsrefining__/graphics/entity/washing-plant/washing-plant.png",
                width = 224,
                height = 224,
                line_length = 5,
                frame_count = 25,
                shift = {0, 0},
            },
            -- {
                -- filename = "__angelsrefining__/graphics/entity/7x7-overlay.png",
                -- tint = {r=1, g=0, b=0},
                -- width = 224,
                -- height = 224,
                -- frame_count = 1,
                -- shift = {0, 0},
            -- },
            }
            },
             vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
            working_sound =
            {
              sound = { filename = "__base__/sound/oil-refinery.ogg" },
              idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
              apparent_volume = 2.5,
            },
            fluid_boxes =
            {
              {
                production_type = "input",
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {0, 3} }}
              },
              {
                production_type = "input",
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {3, 0} }}
              },
              {
                production_type = "output",
                pipe_covers = pipecoverspictures(),
                base_level = 1,
                pipe_connections = {{ position = {0, -3} }}
              },
            },
          },
          {
            type = "item",
            name = "washing-plant-4",
            icons = {
                {
                    icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png",
                },
                {
                    icon = "__angelsrefining__/graphics/icons/num_4.png",
                    tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                    scale = 0.32,
                    shift = {-12, -12},
                }
            },
            icon_size = 32,
            subgroup = "washing-building",
            order = "c",
            place_result = "washing-plant-4",
            stack_size = 10,
          },
          {
            type = "assembling-machine",
            name = "washing-plant-4",
            icons = {
                {
                    icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png",
                },
                {
                    icon = "__angelsrefining__/graphics/icons/num_4.png",
                    tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                    scale = 0.32,
                    shift = {-12, -12},
                }
            },
            icon_size = 32,
            flags = {"placeable-neutral","player-creation"},
            minable = {mining_time = 1, result = "washing-plant-4"},
            fast_replaceable_group = "washing-plant",
            max_health = 300,
            corpse = "big-remnants",
            dying_explosion = "medium-explosion",
            collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
            selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
            module_specification =
            {
              module_slots = 4
            },
            allowed_effects = {"consumption", "speed", "pollution", "productivity"},
            crafting_categories = {"washing-plant"},
            crafting_speed = 4,
            energy_source =
            {
              type = "electric",
              usage_priority = "secondary-input",
              emissions = 0.03 / 3.5
            },
            energy_usage = "250kW",
            ingredient_count = 4,
            animation ={
            layers={
            {
                filename = "__angelsrefining__/graphics/entity/washing-plant/washing-plant.png",
                width = 224,
                height = 224,
                line_length = 5,
                frame_count = 25,
                shift = {0, 0},
            },
            -- {
                -- filename = "__angelsrefining__/graphics/entity/7x7-overlay.png",
                -- tint = {r=1, g=0, b=0},
                -- width = 224,
                -- height = 224,
                -- frame_count = 1,
                -- shift = {0, 0},
            -- },
            }
            },
             vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
            working_sound =
            {
              sound = { filename = "__base__/sound/oil-refinery.ogg" },
              idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
              apparent_volume = 2.5,
            },
            fluid_boxes =
            {
              {
                production_type = "input",
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {0, 3} }}
              },
              {
                production_type = "input",
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {3, 0} }}
              },
              {
                production_type = "output",
                pipe_covers = pipecoverspictures(),
                base_level = 1,
                pipe_connections = {{ position = {0, -3} }}
              },
            },
            },
--ORE CRUSHER            
            {
                type = "item",
                name = "ore-crusher-4",
                icons = {
                    {
                        icon = "__angelsrefining__/graphics/icons/ore-crusher-3.png",
                    },
                    {
                        icon = "__angelsrefining__/graphics/icons/num_5.png",
                        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                        scale = 0.32,
                        shift = {-12, -12},
                    }
                },
                icon_size = 32,
                subgroup = "ore-crusher",
                order = "d[ore-crusher-4]",
                place_result = "ore-crusher-4",
                stack_size = 10,
                },
                {
                type = "assembling-machine",
                name = "ore-crusher-4",
                icons = {
                    {
                        icon = "__angelsrefining__/graphics/icons/ore-crusher-3.png",
                    },
                    {
                        icon = "__angelsrefining__/graphics/icons/num_5.png",
                        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                        scale = 0.32,
                        shift = {-12, -12},
                    }
                },
                icon_size = 32,
                flags = {"placeable-neutral","player-creation"},
                minable = {mining_time = 1, result = "ore-crusher-4"},
                fast_replaceable_group = "ore-crusher",
                max_health = 300,
                corpse = "big-remnants",
                dying_explosion = "medium-explosion",
                collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
                selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
                module_specification =
                {
                  module_slots = 4
                },
                allowed_effects = {"consumption", "speed", "pollution", "productivity"},
                crafting_categories = {"ore-sorting-t1"},
                crafting_speed = 4,
                energy_source =
                {
                  type = "electric",
                  usage_priority = "secondary-input",
                  emissions = 0.04 / 3.5
                },
                energy_usage = "175kW",
                ingredient_count = 3,
                animation ={
                layers={
                {
                    filename = "__angelsrefining__/graphics/entity/ore-crusher/1ore-crusher.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    frame_count = 16,
                    line_length = 4,
                    shift = {0.45, -0.25},
                    animation_speed = 0.5
                },
                {
                    filename = "__angelsrefining__/graphics/entity/ore-crusher/2ore-crusher-overlay.png",
                    tint= {r=0.50, g=0.1, b=0.05},
                    priority = "high",
                    width = 128,
                    height = 128,
                    frame_count = 16,
                    line_length = 4,
                    shift = {0.45, -0.25},
                }
                }
                },
                vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
                working_sound =
                {
                  sound = { filename = "__angelsrefining__/sound/ore-crusher.ogg" },
                  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
                  apparent_volume = 2,
                },
              },
--ORE FLOATATION CELL              
              {
                type = "item",
                name = "ore-floatation-cell-4",
                icons = {
                    {
                        icon = "__angelsrefining__/graphics/icons/ore-floatation-cell-3.png",
                    },
                    {
                        icon = "__angelsrefining__/graphics/icons/num_4.png",
                        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                        scale = 0.32,
                        shift = {-12, -12},
                    }
                },
                icon_size = 32,
                subgroup = "ore-floatation",
                order = "c[ore-floatation-cell-4]",
                place_result = "ore-floatation-cell-4",
                stack_size = 10,
                },
                {
                type = "assembling-machine",
                name = "ore-floatation-cell-4",
                icons = {
                    {
                        icon = "__angelsrefining__/graphics/icons/ore-floatation-cell-3.png",
                    },
                    {
                        icon = "__angelsrefining__/graphics/icons/num_4.png",
                        tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                        scale = 0.32,
                        shift = {-12, -12},
                    }
                },
                icon_size = 32,
                flags = {"placeable-neutral","player-creation"},
                minable = {mining_time = 1, result = "ore-floatation-cell-4"},
                fast_replaceable_group = "ore-floatation-cell",
                max_health = 300,
                corpse = "big-remnants",
                dying_explosion = "medium-explosion",
                collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
                selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
                module_specification =
                {
                  module_slots = 4
                },
                allowed_effects = {"consumption", "speed", "pollution", "productivity"},
                crafting_categories = {"ore-sorting-t2"},
                crafting_speed = 2,
                energy_source =
                {
                  type = "electric",
                  usage_priority = "secondary-input",
                  emissions = 0.04 / 3
                },
                energy_usage = "350kW",
                ingredient_count = 3,
                animation ={
                layers={
                {
                    filename = "__angelsrefining__/graphics/entity/ore-floatation-cell/1ore-floatation-cell.png",
                    priority = "extra-high",
                    width = 192,
                    height = 192,
                    frame_count = 16,
                    line_length = 4,
                    shift = {0.45, 0.7},
                    animation_speed = 0.5
                },
                {
                    filename = "__angelsrefining__/graphics/entity/ore-floatation-cell/2ore-floatation-cell-overlay.png",
                    tint= {r=0.50, g=0.1, b=0.05},
                    priority = "high",
                    width = 192,
                    height = 192,
                    frame_count = 16,
                    line_length = 4,
                    shift = {0.45, 0.7},
                }
                }
                },
                vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
                working_sound =
                {
                  sound = { filename = "__angelsrefining__/sound/ore-floatation-cell.ogg" },
                  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
                  apparent_volume = 2.5,
                },
                fluid_boxes =
                {
                  {
                    production_type = "input",
                    pipe_picture = floatationpipepictures(),
                    pipe_covers = pipecoverspictures(),
                    base_area = 10,
                    base_level = -1,
                    pipe_connections = {{ type="input", position = {0, 3} }}
                  },
                  {
                    production_type = "output",
                    pipe_picture = floatationpipepictures(),
                    pipe_covers = pipecoverspictures(),
                    base_level = 1,
                    pipe_connections = {{ position = {0, -3} }}
                  }
                },
                pipe_covers = pipecoverspictures()
              },
--ORE LEACHING PLANT              
{
    type = "item",
    name = "ore-leaching-plant-4",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-leaching-plant-3.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    subgroup = "ore-leaching",
    order = "c[ore-leaching-plant-4]",
    place_result = "ore-leaching-plant-4",
    stack_size = 10,
    },
	{
    type = "assembling-machine",
    name = "ore-leaching-plant-4",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-leaching-plant-3.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_4.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
	flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "ore-leaching-plant-4"},
	fast_replaceable_group = "ore-leaching-plant",
    max_health = 300,
	corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "pollution", "productivity"},
    crafting_categories = {"ore-sorting-t3"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.06 / 4
    },
    energy_usage = "350kW",
    ingredient_count = 4,
    animation ={
	layers={
	{
        filename = "__angelsrefining__/graphics/entity/ore-leaching-plant/1ore-leaching-plant.png",
		priority = "extra-high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
	},
	{
        filename = "__angelsrefining__/graphics/entity/ore-leaching-plant/2ore-leaching-plant-overlay.png",
		tint= {r=0.50, g=0.1, b=0.05},
		priority = "high",
        width = 192,
        height = 192,
        frame_count = 1,
        shift = {0.4, -0.14},
	}
	}
	},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__angelsrefining__/sound/ore-leaching-plant.ogg" },
	  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
	fluid_boxes =
    {
      {
        production_type = "input",
		pipe_picture = leachingpipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "output",
		pipe_picture = leachingpipepictures(),
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      },
    },
  }, 
 --ORE REFINERY
  {
    type = "item",
    name = "ore-refinery-3",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-refinery-2.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_3.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    subgroup = "ore-refining",
    order = "b[ore-refinery-3]",
    place_result = "ore-refinery-3",
    stack_size = 10,
    },
    {
    type = "assembling-machine",
    name = "ore-refinery-3",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/ore-refinery-2.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_3.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "ore-refinery-3"},
	fast_replaceable_group = "ore-refinery",
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "pollution", "productivity"},
    crafting_categories = {"ore-sorting-t4"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.03 / 2.5
    },
    energy_usage = "400kW",
    ingredient_count = 4,
    animation ={
	layers={
    {
        filename = "__angelsrefining__/graphics/entity/ore-refinery/1ore-refinery.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		animation_speed = 0.5,
        shift = {0.5, -0.5},
    },
    {
        filename = "__angelsrefining__/graphics/entity/ore-refinery/2ore-refinery-overlay.png",
        width = 256,
        height = 256,
        frame_count = 16,
		line_length = 4,
		tint= {r=0.2, g=0.3, b=0.45},
		animation_speed = 0.5,
        shift = {0.5, -0.5},
    },
	}
	},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__angelsrefining__/sound/ore-refinery.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    },
--CRYSTALLIZER
    {
        type = "item",
        name = "crystallizer-3",
        icons = {
		    {
			    icon = "__angelsrefining__/graphics/icons/crystallizer.png",
		    },
		    {
			    icon = "__angelsrefining__/graphics/icons/num_3.png",
			    tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			    scale = 0.32,
			    shift = {-12, -12},
		    }
	    },
	    icon_size = 32,
        subgroup = "refining-buildings",
        order = "e[crystallizer-3]",
        place_result = "crystallizer-3",
        stack_size = 10,
        },
        {
        type = "assembling-machine",
        name = "crystallizer-3",
        icons = {
            {
                icon = "__angelsrefining__/graphics/icons/crystallizer.png",
            },
            {
                icon = "__angelsrefining__/graphics/icons/num_3.png",
                tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
                scale = 0.32,
                shift = {-12, -12},
            }
        },
        icon_size = 32,
        flags = {"placeable-neutral","player-creation"},
        minable = {mining_time = 1, result = "crystallizer-3"},
        fast_replaceable_group = "crystallizer",
        max_health = 300,
        corpse = "big-remnants",
        dying_explosion = "medium-explosion",
        collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
        selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
        module_specification =
        {
          module_slots = 3
        },
        allowed_effects = {"consumption", "speed", "productivity", "pollution"},
        crafting_categories = {"crystallizing"},
        crafting_speed = 3,
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          emissions = 0.03 / 3.5
        },
        energy_usage = "350kW",
        ingredient_count = 4,
        animation ={
        layers={
        {
            filename = "__angelsrefining__/graphics/entity/crystallizer/crystallizer.png",
            width = 192,
            height = 192,
            frame_count = 1,
            shift = {0.5, -0.5},
        },
        -- {
            -- filename = "__angelsrefining__/graphics/entity/7x7-overlay.png",
            -- tint = {r=1, g=0, b=0},
            -- width = 224,
            -- height = 224,
            -- frame_count = 1,
            -- shift = {0, 0},
        -- },
        }
        },
         vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        working_sound =
        {
          sound = { filename = "__base__/sound/oil-refinery.ogg" },
          idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
          apparent_volume = 2.5,
        },
        fluid_boxes =
        {
          {
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            pipe_picture = crystallizerpipepictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{ type="input", position = {0, 3} }}
          },
          -- {
            -- production_type = "output",
            -- pipe_covers = pipecoverspictures(),
            -- base_level = 1,
            -- pipe_connections = {{ position = {0, -3} }}
          -- }
        },
        pipe_covers = pipecoverspictures(),
        off_when_no_fluid_recipe = true
        },
--FILTRATION UNIT
    {
    type = "item",
    name = "filtration-unit-3",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/filtration-unit.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_3.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    subgroup = "refining-buildings",
    order = "c[filtration-unit-3]",
    place_result = "filtration-unit-3",
    stack_size = 10,
  },{
    type = "assembling-machine",
    name = "filtration-unit-3",
    icons = {
		{
			icon = "__angelsrefining__/graphics/icons/filtration-unit.png",
		},
		{
			icon = "__angelsrefining__/graphics/icons/num_3.png",
			tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
			scale = 0.32,
			shift = {-12, -12},
		}
	},
	icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "filtration-unit-3"},
	fast_replaceable_group = "filtration-unit",
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "pollution", "productivity"},
    crafting_categories = {"filtering"},
    crafting_speed = 3,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.03 / 3.5
    },
    energy_usage = "200kW",
    ingredient_count = 4,
    animation ={
	layers={
    {
        filename = "__angelsrefining__/graphics/entity/filtration-unit/filtration-unit.png",
        width = 224,
        height = 224,
        frame_count = 1,
        shift = {0, -0.2},
    },
	-- {
        -- filename = "__angelsrefining__/graphics/entity/7x7-overlay.png",
		-- tint = {r=1, g=0, b=0},
        -- width = 224,
        -- height = 224,
        -- frame_count = 1,
        -- shift = {0, 0},
    -- },
	}
	},
     vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/oil-refinery.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
		pipe_picture = filtrationpipepictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {1, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
		pipe_picture = filtrationpipepictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
		pipe_picture = filtrationpipepictures(),
        base_level = 1,
        pipe_connections = {{ position = {1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
		pipe_picture = filtrationpipepictures(),
        base_level = 1,
        pipe_connections = {{ position = {-1, -3} }}
      }
    },
    },
  }
  )