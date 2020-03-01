data:extend({
  {
    type = "furnace",
    name = "air-filter-machine-mk1",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk1.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk1"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t1.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.15,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.08
    },
    energy_usage = "250kW",
    ingredient_count = 1,
    module_slots = 0
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk2",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk2.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk2"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t2.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.12,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
	
	module_specification =
    {
      module_slots = 1
    },
	allowed_effects = {"consumption", "speed"},	
	
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 2.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.085
    },
    energy_usage = "500kW",
    ingredient_count = 1
    --module_slots = 0
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk3",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk3.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk3"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t3.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.10,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
	
	module_specification =
    {
      module_slots = 1
    },
	allowed_effects = {"consumption", "speed"},	
	
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 5.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.09
    },
    energy_usage = "1.25MW",
    ingredient_count = 1
    --module_slots = 0
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk4",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk4.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk4"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t4.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.8,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
	
	module_specification =
    {
      module_slots = 2
    },
	allowed_effects = {"consumption", "speed"},	
	
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 7.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.095
    },
    energy_usage = "1.875MW",
    ingredient_count = 1
    --module_slots = 0
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk5",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk5.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk5"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t5.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.06,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
	
	module_specification =
    {
      module_slots = 2
    },
	allowed_effects = {"consumption", "speed"},	
	
	
    source_inventory_size = 1,
    result_inventory_size = 1,
    ingredient_count = 1,
    crafting_speed = 10.0,
    energy_usage = "2.5MW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.1
    },
    --module_specification =
    --{
    --  module_slots = 0,
    --},
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk6",
    icon = "__air-filtering-patched__/graphics/icons/air-filter-machine-mk6.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk6"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
	      filename = "__air-filtering-patched__/graphics/entity/ppm-t6.png",
          priority="high",
          width = 99,
          height = 112,
          frame_count = 8,
          line_length = 4,
		  animation_speed = 0.04,
          shift = util.by_pixel(8, -13),
          repeat_count = 4
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__base__/sound/electric-furnace.ogg", volume = 0.7 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"crafting-air-filter"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    ingredient_count = 1,
    crafting_speed = 15.0,
    energy_usage = "3.0MW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.11
    },
    module_specification =
    {
      module_slots = 3,
    },
	allowed_effects = {"consumption", "speed", "pollution"}
  }
})
