if angelsmods.bioprocessing then

data:extend(
{
    {
      type = "item",
      name = "algae-farm-4",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/algae-farm.png"
        },
        {
          icon = "__angelsrefining__/graphics/icons/num_4.png",
          tint = angelsmods.bioprocessing.number_tint,
          scale = 0.32,
          shift = {-12, -12}
        }
      },
	    icon_size = 32,
      subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
      order = "a[algae]-d",
      place_result = "algae-farm-4",
      stack_size = 10,
    },
    {
      type = "assembling-machine",
      name = "algae-farm-4",
      icon = "__angelsbioprocessing__/graphics/icons/algae-farm.png",
	    icon_size = 32,
      flags = {"placeable-neutral","player-creation"},
      minable = {mining_time = 1, result = "algae-farm-4"},
      max_health = 300,
  	  corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
      selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
	    fast_replaceable_group = "algae-farm",
      module_specification =
      {
        module_slots = 4
      },
      allowed_effects = {"consumption", "speed", "productivity", "pollution"},
      crafting_categories = {"bio-processing"},
      crafting_speed = 3.0,
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions = -0.02 / 2
      },
      energy_usage = "250kW",
      ingredient_count = 4,
      animation=
      {
        filename = "__angelsbioprocessing__/graphics/entity/algae-farm/algae-farm.png",
        width = 288,
        height = 288,
	    	line_length = 6,
        frame_count = 36,
        shift = {0, 0},
    	  animation_speed = 0.4,
      },
	working_visualisations =
    {
      {
        animation =
		{
          filename = "__angelsbioprocessing__/graphics/entity/algae-farm/water-splash.png",
          line_length = 5,
		      frame_count = 10,
          width = 92,
          height = 99,
          scale = 0.4,
          shift = {-1.4, 0},
		      animation_speed = 0.2,
          run_mode="forward",
        },
		light = {intensity = 0.4, size = 6},
	  },
	 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
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
        pipe_connections = {{ type="input", position = {0, -4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 4} }}
      }
    },
    pipe_covers = pipecoverspictures()
  },

  --ARBORETUM
  {
    type = "item",
    name = "bio-arboretum-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
      },
    },
    icon_size = 32,
    subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
    order = "e",
    place_result = "bio-arboretum-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-arboretum-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
      },
    },
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-arboretum-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "bio-arboretum",
    next_upgrade = "bio-arboretum-3",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"angels-arboretum"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = -0.02 / 2
    },
    energy_usage = "200kW",
    ingredient_count = 4,
    animation = {
      layers={
        {
          filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-shadow.png",
          width = 224,
          height = 256,
          line_length = 1,
          frame_count = 1,
          shift = {0, -0.25},
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-base.png",
          width = 224,
          height = 256,
          line_length = 1,
          frame_count = 1,
          shift = {0, -0.25},
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-pipes.png",
          width = 224,
          height = 256,
          line_length = 1,
          frame_count = 1,
          shift = {0, -0.25},
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-off.png",
          width = 224,
          height = 256,
          line_length = 1,
          frame_count = 1,
          shift = {0, -0.25},
        },
      }
    },
    working_visualisations = {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-on.png",
          blend_mode = "additive",
          width = 224,
          height = 256,
          line_length = 1,
          frame_count = 1,
          shift = {0, -0.25},
        },
        -- {
        -- effect = "uranium-glow", -- changes alpha based on energy source light intensity
        -- light = {intensity = 0.6, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 1.0, b = 0.0}}
        -- }
        light = {intensity = 1, size = 8, color = {r = 0.5, g = 1.0, b = 0.5}}
      },
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, 3} }}
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
  },

{
  type = "item",
  name = "bio-arboretum-3",
  icons = {
    {
      icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
    },
  },
  icon_size = 32,
  subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
  order = "e",
  place_result = "bio-arboretum-3",
  stack_size = 10,
},
{
  type = "assembling-machine",
  name = "bio-arboretum-3",
  icons = {
    {
      icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
    },
  },
  icon_size = 32,
  flags = {"placeable-neutral","player-creation"},
  minable = {mining_time = 1, result = "bio-arboretum-3"},
  max_health = 300,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
  selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
  fast_replaceable_group= "bio-arboretum",
  module_specification =
  {
    module_slots = 6
  },
  allowed_effects = {"consumption", "speed", "productivity", "pollution"},
  crafting_categories = {"angels-arboretum"},
  crafting_speed = 2,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions = -0.02 / 2
  },
  energy_usage = "400kW",
  ingredient_count = 4,
  animation = {
    layers={
      {
        filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-shadow.png",
        width = 224,
        height = 256,
        line_length = 1,
        frame_count = 1,
        shift = {0, -0.25},
      },
      {
        filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-base.png",
        width = 224,
        height = 256,
        line_length = 1,
        frame_count = 1,
        shift = {0, -0.25},
      },
      {
        filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-pipes.png",
        width = 224,
        height = 256,
        line_length = 1,
        frame_count = 1,
        shift = {0, -0.25},
      },
      {
        filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-off.png",
        width = 224,
        height = 256,
        line_length = 1,
        frame_count = 1,
        shift = {0, -0.25},
      },
    }
  },
  working_visualisations = {
    {
      apply_recipe_tint = "primary",
      animation =
      {
        filename = "__angelsbioprocessing__/graphics/entity/trees/bio-arboretum-on.png",
        blend_mode = "additive",
        width = 224,
        height = 256,
        line_length = 1,
        frame_count = 1,
        shift = {0, -0.25},
      },
      -- {
      -- effect = "uranium-glow", -- changes alpha based on energy source light intensity
      -- light = {intensity = 0.6, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 1.0, b = 0.0}}
      -- }
      light = {intensity = 1, size = 8, color = {r = 0.5, g = 1.0, b = 0.5}}
    },
  },
  fluid_boxes =
  {
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 10,
      base_level = -1,
      pipe_connections = {{ type="input", position = {0, -3} }}
    },
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 10,
      base_level = -1,
      pipe_connections = {{ type="input", position = {0, 3} }}
    }
  },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    sound = { filename = "__base__/sound/chemical-plant.ogg" },
    idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
    apparent_volume = 2.5,
  },
},
--TREE GENERATOR
{
type = "item",
name = "bio-generator-temperate-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-temperate-2",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-temperate-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-temperate-2"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
next_upgrade = "bio-generator-temperate-3",
module_specification =
{
  module_slots = 4
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-temperate", "angels-tree"},
crafting_speed = 1,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "200kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-1.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},
{
type = "item",
name = "bio-generator-swamp-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-swamp-2",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-swamp-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-swamp-2"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
next_upgrade = "bio-generator-swamp-3",
module_specification =
{
  module_slots = 4
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-swamp", "angels-tree"},
crafting_speed = 1,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "200kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-2.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},
{
type = "item",
name = "bio-generator-desert-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-desert-2",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-desert-2",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-desert-2"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
next_upgrade = "bio-generator-desert-3",
module_specification =
{
  module_slots = 4
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-desert", "angels-tree"},
crafting_speed = 1,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "200kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-3.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},

{
type = "item",
name = "bio-generator-temperate-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-temperate-3",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-temperate-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-temperate-3"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
module_specification =
{
  module_slots = 6
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-temperate", "angels-tree"},
crafting_speed = 2,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "400kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-1.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},
{
type = "item",
name = "bio-generator-swamp-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-swamp-3",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-swamp-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-swamp-3"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
module_specification =
{
  module_slots = 6
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-swamp", "angels-tree"},
crafting_speed = 2,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "400kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-2.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},
{
type = "item",
name = "bio-generator-desert-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
  },
},
icon_size = 32,
subgroup = "bio-processing-buildings-a", --DrD "bio-processing-buildings-nauvis-a"
order = "e",
place_result = "bio-generator-desert-3",
stack_size = 10,
},
{
type = "assembling-machine",
name = "bio-generator-desert-3",
icons = {
  {
    icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
  },
},
icon_size = 32,
flags = {"placeable-neutral","player-creation"},
minable = {mining_time = 1, result = "bio-generator-desert-3"},
max_health = 300,
corpse = "big-remnants",
dying_explosion = "medium-explosion",
collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
drawing_box = {{-2, -2.5}, {1.5, 1.5}},
fast_replaceable_group= "bio-generator",
module_specification =
{
  module_slots = 6
},
allowed_effects = {"consumption", "speed", "productivity", "pollution"},
crafting_categories = {"angels-tree-desert", "angels-tree"},
crafting_speed = 2,
energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions = -0.02 / 2
},
energy_usage = "400kW",
ingredient_count = 4,
animation={
  layers={
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-3.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
  }
},
working_visualisations = {
  {
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
      priority = "high",
      width = 160,
      height = 160,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
    },
    light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
  },
},
fluid_boxes =
{
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, -2} }}
  },
  {
    production_type = "input",
    pipe_covers = pipecoverspictures(),
    base_area = 10,
    base_level = -1,
    pipe_connections = {{ type="input", position = {0, 2} }}
  }
},
vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
working_sound =
{
  sound = { filename = "__base__/sound/chemical-plant.ogg" },
  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
  apparent_volume = 2.5,
},
},
}
  )

end