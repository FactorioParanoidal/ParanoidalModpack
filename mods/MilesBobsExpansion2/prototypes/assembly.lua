require "util"
data:extend( 
{
  {
    type = "item",
    name = "assembling-machine-7",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-7.png",
    icon_size = 64,
    subgroup = "bob-assembly-machine",
    order = "c[bob-assembling-machine-7]",
    place_result = "assembling-machine-7",
    stack_size = 10
  },

  {
    type = "assembling-machine",
    name = "assembling-machine-7",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-7.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player","player-creation"},
    minable = {hardness = 0.2, mining_time = 1, results = {{type="item", name="assembling-machine-7", amount=1}}},
    max_health = 800,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
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
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="input", position = {0, -2} }}
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="output", position = {0, 2} }}
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "assembling-machine",
    next_upgrade = "assembling-machine-8",
    animation =
    {
      layers =
      {
        {
		filename = "__MilesBobsExpansion2__/graphics/assembling-machine/assembling-machine-7.png",
          priority = "high",
          width = 192,
          height = 256,
          frame_count = 60,
          line_length = 10,
		  animation_speed = 0.125,
          --shift = util.by_pixel(0, -0.5),
          shift = util.by_pixel(0, -15),
		  scale = 0.55
        },
      }
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        },
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting", "advanced-crafting", "crafting-with-fluid"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 6 }
    },
    energy_usage = "1000kW",
	ingredient_count = 20,
    module_specification =
    {
      module_slots = 7,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
  },

  {
    type = "recipe",
    name = "assembling-machine-7",
    enabled = false,
    ingredients =
    {
      {type="item", name="bob-assembling-machine-6", amount=2},
      {type="item", name="bob-brass-gear-wheel", amount=250},
	    {type="item", name="bob-speed-module-5", amount=10},
    },
    results = {{type="item", name="assembling-machine-7", amount=1}}
  },

  {
    type = "technology",
    name = "automation-7",
    icon = "__MilesBobsExpansion2__/graphics/technology/assembling-machine-7.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembling-machine-7"
      }
    },
    prerequisites = {"automation-6"},
    unit =
    {
      count = 200,
      ingredients = -- 2.0: набор науки выровнен по bob automation-6 (Bob's поднял тир-6 до space)
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 100
    },
    upgrade = true,
  },

  {
    type = "recipe",
    name = "assembling-machine-8",
    enabled = false,
    ingredients =
    {
      {type="item", name="assembling-machine-7", amount=2},
      {type="item", name="bob-cobalt-steel-gear-wheel", amount=500},
      {type="item", name="bob-speed-module-5", amount=10},
    },
    results = {{type="item", name="assembling-machine-8", amount=1}}
  },

  {
    type = "technology",
    name = "automation-8",
    icon = "__MilesBobsExpansion2__/graphics/technology/assembling-machine-8.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembling-machine-8"
      }
    },
    prerequisites = {"automation-7"},
    unit =
    {
      count = 250,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 150
	  },
	upgrade = true,
  },

  {
    type = "recipe",
    name = "assembling-machine-9",
    enabled = false,
    ingredients =
    {
      {type="item", name="assembling-machine-8", amount=2},
  	  {type="item", name="bob-speed-module-5", amount=5},
    },
    results = {{type="item", name="assembling-machine-9", amount=1}}
  },

  {
    type = "technology",
    name = "automation-9",
    icon = "__MilesBobsExpansion2__/graphics/technology/assembling-machine-9.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "assembling-machine-9"
      }
    },
    prerequisites = {"automation-8"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 2},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 200
	  },
	upgrade = true,
  },
 
 {
    type = "item",
    name = "assembling-machine-8",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-8.png",
    icon_size = 64,
    subgroup = "bob-assembly-machine",
    order = "c[bob-assembling-machine-8]",
    place_result = "assembling-machine-8",
    stack_size = 10
  },
 
    {
    type = "assembling-machine",
    name = "assembling-machine-8",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-8.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player","player-creation"},
    minable = {hardness = 0.2, mining_time = 1, results = {{type="item", name="assembling-machine-8", amount=1}}},
    max_health = 900,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
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
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="input", position = {0, -2} }}
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="output", position = {0, 2} }}
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "assembling-machine",
    next_upgrade = "assembling-machine-9",
    animation =
    {
      layers =
      {
        {
		filename = "__MilesBobsExpansion2__/graphics/assembling-machine/assembling-machine-8.png",
          priority = "high",
          width = 192,
          height = 256,
          frame_count = 60,
          line_length = 10,
		  animation_speed = 0.125,
          --shift = util.by_pixel(0, -0.5),
          shift = util.by_pixel(0, -15),
		  scale = 0.55
        },
      }
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        },
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting", "advanced-crafting", "crafting-with-fluid"},
    crafting_speed = 4.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 6 }
    },
    energy_usage = "1500kW",
	ingredient_count = 20,
    module_specification =
    {
      module_slots = 8,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
  },
  
 
 {
    type = "item",
    name = "assembling-machine-9",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-9.png",
    icon_size = 64,
    subgroup = "bob-assembly-machine",
    order = "c[bob-assembling-machine-9]",
    place_result = "assembling-machine-9",
    stack_size = 10
  },
 
    {
    type = "assembling-machine",
    name = "assembling-machine-9",
    icon = "__MilesBobsExpansion2__/graphics/icons/assembling-machine-9.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player","player-creation"},
    minable = {hardness = 0.2, mining_time = 1, results = {{type="item", name="assembling-machine-9", amount=1}}},
    max_health = 1000,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
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
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="input", position = {0, -2} }}
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {{ type="output", position = {0, 2} }}
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "assembling-machine",
    --next_upgrade = "assembling-machine-9",
    animation =
    {
      layers =
      {
        {
		filename = "__MilesBobsExpansion2__/graphics/assembling-machine/assembling-machine-9.png",
          priority = "high",
          width = 192,
          height = 256,
          frame_count = 60,
          line_length = 10,
		  animation_speed = 0.125,
          --shift = util.by_pixel(0, -0.5),
          shift = util.by_pixel(0, -15),
		  scale = 0.55
        },
      }
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        },
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting", "advanced-crafting", "crafting-with-fluid"},
    crafting_speed = 5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 6 }
    },
    energy_usage = "2000kW",
	ingredient_count = 20,
    module_specification =
    {
      module_slots = 9,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
  },
  
}
)
