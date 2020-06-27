if angelsmods.bioprocessing then

data:extend(
{
  --Algae Farm
  --[[
  BuildGen:import("alage-farm-3"):
    setName("algae-farm-4"):
    setSpeed("3.0"):
    setModSlots("4"):
    addSmallIcon("__angelsrefining__/graphics/icons/num_4.png",3):
    extend()
--]]
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
      subgroup = "bio-processing-buildings-nauvis-a",
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
        emissions_per_minute = -0.05 * 60
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
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-nauvis-a",
    order = "c[arboretum]-a",
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
      emissions_per_minute = -0.03 * 60
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
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
  icon_size = 32,
  subgroup = "bio-processing-buildings-nauvis-a",
  order = "c[arboretum]-a",
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
    emissions_per_minute = -0.04 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_2.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-a",
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
  emissions_per_minute = 0.05 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_2.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-b",
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
  emissions_per_minute = -0.03 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_2.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-c",
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
  emissions_per_minute = -0.03 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_3.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-a",
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
  emissions_per_minute = -0.04 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_3.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-b",
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
  emissions_per_minute = -0.04 * 60
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
  {
    icon = "__angelsrefining__/graphics/icons/num_3.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
  },
icon_size = 32,
subgroup = "bio-processing-buildings-nauvis-a",
order = "b[generator]-c",
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
  --Bio Press
{
  type = "item",
  name = "bio-press-2",
  icons = {
    {
      icon = "__angelsbioprocessing__/graphics/icons/bio-press.png"
  },
  {
    icon = "__angelsrefining__/graphics/icons/num_2.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
},
  icon_size = 32,
  subgroup = "bio-processing-buildings-vegetabilis-b",
  order = "d",
  place_result = "bio-press-2",
  stack_size = 10,
},
{
  type = "assembling-machine",
  name = "bio-press-2",
  icon = "__angelsbioprocessing__/graphics/icons/bio-press.png",
  icon_size = 32,
  flags = {"placeable-neutral","player-creation"},
  minable = {mining_time = 1, result = "bio-press-2"},
  max_health = 300,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  fast_replaceable_group= "bio-press",
  next_upgrade = "bio-press-3",
  module_specification =
  {
    module_slots = 3
  },
  allowed_effects = {"consumption", "speed", "productivity", "pollution"},
  crafting_categories = {"bio-pressing"},
  crafting_speed = 1.5,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 0.03 * 60
  },
  energy_usage = "190kW",
  --ingredient_count = 4,
  animation=
  {
      filename = "__angelsbioprocessing__/graphics/entity/bio-press/bio-press.png",
      width = 160,
      height = 160,
      line_length = 5,
      frame_count = 25,
      shift = {0, 0},
      animation_speed = 0.5,
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
      production_type = "output",
      pipe_covers = pipecoverspictures(),
      base_level = 1,
      pipe_connections = {{ position = {0, 2} }}
    },
  },
},
{
  type = "item",
  name = "bio-press-3",
  icons = {
    {
      icon = "__angelsbioprocessing__/graphics/icons/bio-press.png"
  },
  {
    icon = "__angelsrefining__/graphics/icons/num_3.png",
    tint = angelsmods.bioprocessing.number_tint,
    scale = 0.32,
    shift = {-12, -12}
  }
},
  icon_size = 32,
  subgroup = "bio-processing-buildings-vegetabilis-b",
  order = "d",
  place_result = "bio-press-3",
  stack_size = 10,
},
{
  type = "assembling-machine",
  name = "bio-press-3",
  icon = "__angelsbioprocessing__/graphics/icons/bio-press.png",
  icon_size = 32,
  flags = {"placeable-neutral","player-creation"},
  minable = {mining_time = 1, result = "bio-press-3"},
  max_health = 300,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  fast_replaceable_group= "bio-press",
  module_specification =
  {
    module_slots = 4
  },
  allowed_effects = {"consumption", "speed", "productivity", "pollution"},
  crafting_categories = {"bio-pressing"},
  crafting_speed = 2,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 0.03 * 60
  },
  energy_usage = "225kW",
  --ingredient_count = 4,
  animation=
  {
      filename = "__angelsbioprocessing__/graphics/entity/bio-press/bio-press.png",
      width = 160,
      height = 160,
      line_length = 5,
      frame_count = 25,
      shift = {0, 0},
      animation_speed = 0.5,
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
      production_type = "output",
      pipe_covers = pipecoverspictures(),
      base_level = 1,
      pipe_connections = {{ position = {0, 2} }}
    },
  },
},

--Bio Processor

  {
    type = "item",
    name = "bio-processor-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-b",
    order = "cb",
    place_result = "bio-processor-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-processor-2",
    icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-processor-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "bio-processor",
    next_upgradge = "bio-processor-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-processor"},
    crafting_speed = 1.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.03 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation={
        filename = "__angelsbioprocessing__/graphics/entity/bio-processor/bio-processor.png",
        width = 224,
        height = 224,
        line_length = 5,
        frame_count = 25,
        shift = {0, 0},
        animation_speed = 0.5,
    },
    working_visualisations =
    {
      {
        --apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-processor/bio-processor-ani.png",
          line_length = 5,
          frame_count = 25,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.5,
        },
      },
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
      name = "bio-processor-3",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_3.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-vegetabilis-b",
      order = "cc",
      place_result = "bio-processor-3",
      stack_size = 10,
    },
    {
      type = "assembling-machine",
      name = "bio-processor-3",
      icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png",
      icon_size = 32,
      flags = {"placeable-neutral","player-creation"},
      minable = {mining_time = 1, result = "bio-processor-3"},
      max_health = 300,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
      selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
      fast_replaceable_group= "bio-processor",
      module_specification =
      {
        module_slots = 4
      },
      allowed_effects = {"consumption", "speed", "productivity", "pollution"},
      crafting_categories = {"bio-processor"},
      crafting_speed = 2,
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.03 * 60
      },
      energy_usage = "225kW",
      --ingredient_count = 4,
      animation={
          filename = "__angelsbioprocessing__/graphics/entity/bio-processor/bio-processor.png",
          width = 224,
          height = 224,
          line_length = 5,
          frame_count = 25,
          shift = {0, 0},
          animation_speed = 0.5,
      },
      working_visualisations =
      {
        {
          --apply_recipe_tint = "primary",
          animation =
          {
            filename = "__angelsbioprocessing__/graphics/entity/bio-processor/bio-processor-ani.png",
            line_length = 5,
            frame_count = 25,
            width = 224,
            height = 224,
            shift = {0, 0},
            animation_speed = 0.5,
          },
        },
       },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      working_sound =
      {
        sound = { filename = "__base__/sound/chemical-plant.ogg" },
        idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
        apparent_volume = 2.5,
      },
    },
      --Bucthery
    {
      type = "item",
      name = "bio-butchery-2",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_2.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-alien-a",
      order = "bb",
      place_result = "bio-butchery-2",
      stack_size = 10,
    },
    {
      type = "furnace",
      name = "bio-butchery-2",
      icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png",
      icon_size = 32,
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 1, result = "bio-butchery-2"},
      max_health = 100,
      fast_replaceable_group = "bio-butchery",
      next_upgrade = "bio-butchery-3",
      corpse = "small-remnants",
      collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      drawing_box = {{-1.5, -1.75}, {1.5, 1.5}},
      crafting_categories = {"bio-butchery"},
      module_specification =
      {
        module_slots = 3
      },
      allowed_effects = {"consumption", "speed", "pollution"},
      result_inventory_size = 3,
      crafting_speed = 3,
      source_inventory_size = 1,
      resistances =
      {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "explosion",
          percent = 30
        }
      },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.02 * 60
      },
      energy_usage = "190kW",
      animation =
      {
        layers = {
          {
            filename = "__angelsbioprocessing__/graphics/entity/bio-butchery/bio-butchery.png",
            width = 160,
            height = 160,
            frame_count = 36,
            line_length = 6,
            shift = {0, 0},
            animation_speed = 0.5
          },
        },
      },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    },

    {
      type = "item",
      name = "bio-butchery-3",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_3.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-alien-a",
      order = "bc",
      place_result = "bio-butchery-3",
      stack_size = 10,
    },
    {
      type = "furnace",
      name = "bio-butchery-3",
      icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png",
      icon_size = 32,
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 1, result = "bio-butchery-3"},
      max_health = 100,
      fast_replaceable_group = "bio-butchery",
      corpse = "small-remnants",
      collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      drawing_box = {{-1.5, -1.75}, {1.5, 1.5}},
      crafting_categories = {"bio-butchery"},
      module_specification =
      {
        module_slots = 4
      },
      allowed_effects = {"consumption", "speed", "pollution"},
      result_inventory_size = 3,
      crafting_speed = 4,
      source_inventory_size = 1,
      resistances =
      {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "explosion",
          percent = 30
        }
      },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.03 * 60
      },
      energy_usage = "225kW",
      animation =
      {
        layers = {
          {
            filename = "__angelsbioprocessing__/graphics/entity/bio-butchery/bio-butchery.png",
            width = 160,
            height = 160,
            frame_count = 36,
            line_length = 6,
            shift = {0, 0},
            animation_speed = 0.5
          },
        },
      },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    },
    {
      type = "item",
      name = "composter-2",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/composter.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_2.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-vegetabilis-b",
      order = "bb",
      place_result = "composter-2",
      stack_size = 10,
      },
      {
      type = "furnace",
      name = "composter-2",
      icon = "__angelsbioprocessing__/graphics/icons/composter.png",
      icon_size = 32,
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 1, result = "composter-2"},
      max_health = 100,
      fast_replaceable_group = "composter",
      next_upgrade = "composter-3",
      corpse = "small-remnants",
      collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      crafting_categories = {"angels-bio-void"},
      module_specification =
      {
        module_slots = 3
      },
      allowed_effects = {"consumption", "speed", "pollution"},
      result_inventory_size = 1,
      crafting_speed = 3,
      source_inventory_size = 1,
      resistances =
      {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "explosion",
          percent = 30
        }
      },
      -- fluid_boxes =
      -- {
        -- {
          -- production_type = "input",
          -- pipe_covers = pipecoverspictures(),
          -- base_area = 10,
          -- base_level = -1,
          -- pipe_connections = {{ type="input", position = {0, 3} }}
        -- },
      -- },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.02 * 60
      },
      energy_usage = "40kW",
      animation =
      {
          filename = "__angelsbioprocessing__/graphics/entity/composter/composter.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
      },
      working_visualisations =
      {
          filename = "__angelsbioprocessing__/graphics/entity/composter/composter-animation.png",
          width = 128,
          height = 32,
          frame_count = 25,
          line_length = 5,
          shift = {0, 1},
          animation_speed = 0.5
      },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    },
    {
      type = "item",
      name = "composter-3",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/composter.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_3.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-vegetabilis-b",
      order = "bc",
      place_result = "composter-3",
      stack_size = 10,
      },
      {
      type = "furnace",
      name = "composter-3",
      icon = "__angelsbioprocessing__/graphics/icons/composter.png",
      icon_size = 32,
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {mining_time = 1, result = "composter-3"},
      max_health = 100,
      fast_replaceable_group = "composter",
      corpse = "small-remnants",
      collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      crafting_categories = {"angels-bio-void"},
      module_specification =
      {
        module_slots = 4
      },
      allowed_effects = {"consumption", "speed", "pollution"},
      result_inventory_size = 1,
      crafting_speed = 4,
      source_inventory_size = 1,
      resistances =
      {
        {
          type = "fire",
          percent = 80
        },
        {
          type = "explosion",
          percent = 30
        }
      },
      -- fluid_boxes =
      -- {
        -- {
          -- production_type = "input",
          -- pipe_covers = pipecoverspictures(),
          -- base_area = 10,
          -- base_level = -1,
          -- pipe_connections = {{ type="input", position = {0, 3} }}
        -- },
      -- },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = 0.03 * 60
      },
      energy_usage = "45kW",
      animation =
      {
          filename = "__angelsbioprocessing__/graphics/entity/composter/composter.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
      },
      working_visualisations =
      {
          filename = "__angelsbioprocessing__/graphics/entity/composter/composter-animation.png",
          width = 128,
          height = 32,
          frame_count = 25,
          line_length = 5,
          shift = {0, 1},
          animation_speed = 0.5
      },
      vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
      repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    },
    {
      type = "item",
      name = "crop-farm-2",
      icons = {
        {
          icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png"
      },
      {
        icon = "__angelsrefining__/graphics/icons/num_2.png",
        tint = angelsmods.bioprocessing.number_tint,
        scale = 0.32,
        shift = {-12, -12}
      }
    },
      icon_size = 32,
      subgroup = "bio-processing-buildings-vegetabilis-a",
      order = "ab",
      place_result = "crop-farm-2",
      stack_size = 10,
    },
    {
      type = "assembling-machine",
      name = "crop-farm-2",
      icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
      icon_size = 32,
      flags = {"placeable-neutral","player-creation"},
      minable = {mining_time = 1, result = "crop-farm-2"},
      max_health = 300,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
      selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
      fast_replaceable_group= "crop-farm",
      next_upgrade= "crop-farm-3",
      module_specification =
      {
        module_slots = 3
      },
      allowed_effects = {"consumption", "speed", "productivity", "pollution"},
      crafting_categories = {"temperate-farming", "desert-farming", "swamp-farming"},
      crafting_speed = 1.5,
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = -0.03 * 60
      },
      energy_usage = "125kW",
      --ingredient_count = 4,
      animation={
          layers={
            {
              filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
              width = 224,
              height = 224,
              line_length = 1,
              frame_count = 1,
              shift = {0, 0},
            },
            {
              filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-basic.png",
              width = 224,
              height = 224,
              line_length = 1,
              frame_count = 1,
              shift = {0, 0},
            },
          }
      },
      working_visualisations =
      {
        {
          apply_recipe_tint = "primary",
          animation =
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-1.png",
            line_length = 6,
            frame_count = 36,
            width = 224,
            height = 224,
            shift = {0, 0},
            animation_speed = 0.005,
          },
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
          pipe_connections = {{ type="input", position = {0, -3} }}
        },
      },
    },
    {
    type = "item",
    name = "crop-farm-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "ac",
    place_result = "crop-farm-3",
    stack_size = 10,
  },

  {
    type = "assembling-machine",
    name = "crop-farm-3",
    icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "crop-farm-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"temperate-farming", "desert-farming", "swamp-farming"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.04 * 60
    },
    energy_usage = "150kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-basic.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-1.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.005,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "temperate-farm-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bb",
    place_result = "temperate-farm-2",
    stack_size = 10,
  },
  
  {
    type = "assembling-machine",
    name = "temperate-farm-2",
    icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "temperate-farm-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    next_upgrade = "temperate-farm-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"temperate-farming"},
    crafting_speed = 3,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.05 * 60
    },
    energy_usage = "155kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-temperate.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-2.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "temperate-farm-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bc",
    place_result = "temperate-farm-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "temperate-farm-3",
    icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "temperate-farm-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"temperate-farming"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.06 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-temperate.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-2.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "desert-farm-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "be",
    place_result = "desert-farm-2",
    stack_size = 10,
  },

  {
    type = "assembling-machine",
    name = "desert-farm-2",
    icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "desert-farm-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    next_upgrade= "desert-farm-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"desert-farming"},
    crafting_speed = 3,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.05 * 60
    },
    energy_usage = "155kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-desert.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-3.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "desert-farm-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bf",
    place_result = "desert-farm-3",
    stack_size = 10,
  },

  {
    type = "assembling-machine",
    name = "desert-farm-3",
    icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "desert-farm-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"desert-farming"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.06 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-desert.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-3.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "swamp-farm-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bh",
    place_result = "swamp-farm-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "swamp-farm-2",
    icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "swamp-farm-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    next_upgrade = "swamp-farm-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"swamp-farming"},
    crafting_speed = 3,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.05 * 60
    },
    energy_usage = "155kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-water.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-4.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "swamp-farm-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bi",
    place_result = "swamp-farm-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "swamp-farm-3",
    icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "swamp-farm-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group= "crop-farm",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"swamp-farming"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.06 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation={
        layers={
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-water.png",
            width = 224,
            height = 224,
            line_length = 1,
            frame_count = 1,
            shift = {0, 0},
          },
        }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-4.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = {0, 0},
          animation_speed = 0.01,
        },
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
        pipe_connections = {{ type="input", position = {0, -3} }}
      },
    },
  },

  {
    type = "item",
    name = "bio-hatchery-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "c",
    place_result = "bio-hatchery-2",
    stack_size = 10,
  },
  {
    type = "furnace",
    name = "bio-hatchery-2",
    icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "bio-hatchery-2"},
    max_health = 100,
    fast_replaceable_group = "bio-hatchery",
    corpse = "small-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    drawing_box = {{-1.5, -1.75}, {1.5, 1.5}},
    crafting_categories = {"bio-hatchery"},
    next_upgrade = "bio-hatchery-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "pollution"},
    result_inventory_size = 3,
    crafting_speed = 3,
    source_inventory_size = 1,
    resistances =
    {
      {
        type = "fire",
        percent = 80
      },
      {
        type = "explosion",
        percent = 30
      }
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.02 * 60
    },
    energy_usage = "190kW",
    animation =
    {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-shadow.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-off.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
        },
      },
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-animation.png",
          width = 160,
          height = 160,
          line_length = 5,
          frame_count = 25,
          shift = {0, 0},
          animation_speed = 0.35
        },
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  },

  {
    type = "item",
    name = "bio-hatchery-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "c",
    place_result = "bio-hatchery-3",
    stack_size = 10,
  },
  {
    type = "furnace",
    name = "bio-hatchery-3",
    icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "bio-hatchery-3"},
    max_health = 100,
    fast_replaceable_group = "bio-hatchery",
    corpse = "small-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    drawing_box = {{-1.5, -1.75}, {1.5, 1.5}},
    crafting_categories = {"bio-hatchery"},
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "pollution"},
    result_inventory_size = 3,
    crafting_speed = 4,
    source_inventory_size = 1,
    resistances =
    {
      {
        type = "fire",
        percent = 80
      },
      {
        type = "explosion",
        percent = 30
      }
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.03 * 60
    },
    energy_usage = "225kW",
    animation =
    {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-shadow.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-off.png",
          width = 160,
          height = 160,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          --animation_speed = 0.5
        },
      },
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-animation.png",
          width = 160,
          height = 160,
          line_length = 5,
          frame_count = 25,
          shift = {0, 0},
          animation_speed = 0.35
        },
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  },

  {
    type = "item",
    name = "nutrient-extractor-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-b",
    order = "d",
    place_result = "nutrient-extractor-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "nutrient-extractor-2",
    icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "nutrient-extractor-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group= "nutrient-extractor",
    next_upgrade = "nutrient-extractor-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"nutrient-extractor",},
    crafting_speed = 1.5,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.04 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation=
    {
        filename = "__angelsbioprocessing__/graphics/entity/nutrient-extractor/nutrient-extractor.png",
        width = 160,
        height = 160,
        line_length = 5,
        frame_count = 25,
        shift = {0, 0},
        animation_speed = 0.5,
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
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {0, 2} }}
      },
    },
  },

  {
    type = "item",
    name = "nutrient-extractor-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-b",
    order = "d",
    place_result = "nutrient-extractor-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "nutrient-extractor-3",
    icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "nutrient-extractor-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group= "nutrient-extractor",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"nutrient-extractor",},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.05 * 60
    },
    energy_usage = "225kW",
    --ingredient_count = 4,
    animation=
    {
        filename = "__angelsbioprocessing__/graphics/entity/nutrient-extractor/nutrient-extractor.png",
        width = 160,
        height = 160,
        line_length = 5,
        frame_count = 25,
        shift = {0, 0},
        animation_speed = 0.5,
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
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_level = 1,
        pipe_connections = {{ position = {0, 2} }}
      },
    },
  },

  {
    type = "item",
    name = "bio-refugium-fish-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "a",
    place_result = "bio-refugium-fish-2",
    stack_size = 10,
  },

  {
    type = "assembling-machine",
    name = "bio-refugium-fish-2",
    icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-fish-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    --drawing_box = {{-2.5, -3}, {2.5, 2.5}},
    fast_replaceable_group= "bio-refugium",
    next_upgrade = "bio-refugium-fish-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-fish"},
    crafting_speed = 1.25,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.03 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation=
    {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish-shadow.png",
          width = 288,
          height = 288,
          line_length = 1,
          frame_count = 1,
          shift = {0, 0},
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish-off.png",
          width = 288,
          height = 288,
          line_length = 1,
          frame_count = 1,
          shift = {0, 0},
        },
      }
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish.png",
          width = 288,
          height = 288,
          line_length = 7,
          frame_count = 49,
          shift = {0, 0},
          animation_speed = 49/90,
        }
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__angelsbioprocessing__/sound/aquarium.ogg", volume = 0.8 },
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
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0, -4} }}
      },
    },
  },

  {
    type = "item",
    name = "bio-refugium-fish-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "a",
    place_result = "bio-refugium-fish-3",
    stack_size = 10,
  },

  {
    type = "assembling-machine",
    name = "bio-refugium-fish-3",
    icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-fish-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    --drawing_box = {{-2.5, -3}, {2.5, 2.5}},
    fast_replaceable_group= "bio-refugium",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-fish"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.04 * 60
    },
    energy_usage = "225kW",
    --ingredient_count = 4,
    animation=
    {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish-shadow.png",
          width = 288,
          height = 288,
          line_length = 1,
          frame_count = 1,
          shift = {0, 0},
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish-off.png",
          width = 288,
          height = 288,
          line_length = 1,
          frame_count = 1,
          shift = {0, 0},
        },
      }
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-fish.png",
          width = 288,
          height = 288,
          line_length = 7,
          frame_count = 49,
          shift = {0, 0},
          animation_speed = 49/90,
        }
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__angelsbioprocessing__/sound/aquarium.ogg", volume = 0.8 },
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
        pipe_connections = {{ type="input", position = {1, 4} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-1, 4} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0, -4} }}
      },
    },
  },

  {
    type = "item",
    name = "bio-refugium-puffer-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "d",
    place_result = "bio-refugium-puffer-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-refugium-puffer-2",
    icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-puffer-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -3.5}, {2.5, 2.5}},
    fast_replaceable_group= "bio-refugium",
    next_upgrade = "bio-refugium-puffer-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-puffer"},
    crafting_speed = 1.25,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.03 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-puffer-off.png",
      width = 224,
      height = 256,
      line_length = 1,
      frame_count = 1,
      shift = {0, -0.5},
      animation_speed = 0.5,
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-puffer.png",
          width = 224,
          height = 256,
          line_length = 6,
          frame_count = 36,
          shift = {0, -0.5},
          animation_speed = 36/60,
        }
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        {
          filename = "__angelsbioprocessing__/sound/fart_1.ogg",
          volume = 1
        },
        {
          filename = "__angelsbioprocessing__/sound/fart_2.ogg",
          volume = 1
        },
      },
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
        pipe_connections = {{ type="input", position = {2, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {-1, -3} }}
      }
    },
  },

  {
    type = "item",
    name = "bio-refugium-puffer-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "d",
    place_result = "bio-refugium-puffer-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-refugium-puffer-3",
    icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-puffer-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -3.5}, {2.5, 2.5}},
    fast_replaceable_group= "bio-refugium",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-puffer"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.04 * 60
    },
    energy_usage = "225kW",
    --ingredient_count = 4,
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-puffer-off.png",
      width = 224,
      height = 256,
      line_length = 1,
      frame_count = 1,
      shift = {0, -0.5},
      animation_speed = 0.5,
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-puffer.png",
          width = 224,
          height = 256,
          line_length = 6,
          frame_count = 36,
          shift = {0, -0.5},
          animation_speed = 36/60,
        }
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        {
          filename = "__angelsbioprocessing__/sound/fart_1.ogg",
          volume = 1
        },
        {
          filename = "__angelsbioprocessing__/sound/fart_2.ogg",
          volume = 1
        },
      },
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
        pipe_connections = {{ type="input", position = {2, 3} }}
      },
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {-2, 3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {1, -3} }}
      },
      {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        -- base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {-1, -3} }}
      }
    },
  },

  {
    type = "item",
    name = "bio-refugium-biter-2",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "e",
    place_result = "bio-refugium-biter-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-refugium-biter-2",
    icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-biter-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    fast_replaceable_group= "bio-refugium",
    next_upgrade = "bio-refugium-biter-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-biter"},
    crafting_speed = 3,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.03 * 60
    },
    energy_usage = "190kW",
    --ingredient_count = 4,
    animation=
    {
      filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-biter-off.png",
      width = 288,
      height = 288,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
      --animation_speed = 0.5,
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-biter.png",
          width = 288,
          height = 288,
          line_length = 4,
          frame_count = 16,
          shift = {0, 0},
          animation_speed = 0.5 * 0.75/2,
        },
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
  },

  {
    type = "item",
    name = "bio-refugium-biter-3",
    icons = {
      {
        icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-alien-a",
    order = "e",
    place_result = "bio-refugium-biter-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "bio-refugium-biter-3",
    icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "bio-refugium-biter-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
    selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
    fast_replaceable_group= "bio-refugium",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"bio-refugium-biter"},
    crafting_speed = 4,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -0.04 * 60
    },
    energy_usage = "225kW",
    --ingredient_count = 4,
    animation=
    {
      filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-biter-off.png",
      width = 288,
      height = 288,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
      --animation_speed = 0.5,
    },
    working_visualisations =
    {
      {
        animation =
        {
          filename = "__angelsbioprocessing__/graphics/entity/bio-refugium/bio-refugium-biter.png",
          width = 288,
          height = 288,
          line_length = 4,
          frame_count = 16,
          shift = {0, 0},
          animation_speed = 0.5 * 0.75/2,
        },
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
  },

  {
    type = "item",
    name = "seed-extractor-2",
    icons = 
    {
    {
      icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_2.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-b",
    order = "a",
    place_result = "seed-extractor-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "seed-extractor-2",
    icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "seed-extractor-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group= "seed-extractor",
    next_upgrade = "seed-extractor-3",
    module_specification =
    {
      module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"seed-extractor"},
    crafting_speed = 1.25,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.04 * 60
    },
    energy_usage = "180kW",
    ingredient_count = 4,
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/seed-extractor/seed-extractor.png",
      width = 160,
      height = 160,
      frame_count = 25,
      line_length = 5,
      shift = {0, 0},
      animation_speed = 0.5,
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  },

  {
    type = "item",
    name = "seed-extractor-3",
    icons = 
    {
    {
      icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png"
    },
    {
      icon = "__angelsrefining__/graphics/icons/num_3.png",
      tint = angelsmods.bioprocessing.number_tint,
      scale = 0.32,
      shift = {-12, -12}
    }
  },
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-b",
    order = "a",
    place_result = "seed-extractor-3",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "seed-extractor-3",
    icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "seed-extractor-3"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group= "seed-extractor",
    module_specification =
    {
      module_slots = 4
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    crafting_categories = {"seed-extractor"},
    crafting_speed = 2,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 0.05 * 60
    },
    energy_usage = "220kW",
    ingredient_count = 4,
    animation =
    {
      filename = "__angelsbioprocessing__/graphics/entity/seed-extractor/seed-extractor.png",
      width = 160,
      height = 160,
      frame_count = 25,
      line_length = 5,
      shift = {0, 0},
      animation_speed = 0.5,
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  },

  }
  )

end