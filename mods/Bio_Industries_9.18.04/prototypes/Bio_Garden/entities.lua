
require ("util")


--- Bio Gardens
data:extend({

--- Bio Garden 
  {
    type = "assembling-machine",
	name = "bi-bio-garden",
	icon = "__Bio_Industries__/graphics/icons/bio_garden_icon.png",
	icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-garden"},
    fast_replaceable_group = "bi-bio-garden",
    max_health = 150,
    corpse = "medium-remnants",	
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
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
      off_when_no_fluid_recipe = true
    },
	animation =
    {
      filename = "__Bio_Industries__/graphics/entities/biogarden/bio_garden_x.png",
      width = 160,
      height = 160,
	  frame_count = 12,
	  line_length = 4,
	  animation_speed = 0.025,
      shift = {0.45, 0}
	  
	  
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound =
    {
      sound = { { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.8 } },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"clean-air"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
	  emissions_per_minute = -45, -- the "-" means it Absorbs pollution. 
    },
    energy_usage = "200kW",
    ingredient_count = 1,
	module_specification =
    {
      module_slots = 1
    },
	allowed_effects = {"consumption", "speed"},
  },
 

  })
