if settings.startup["bobmods-assembly-electrolysers"].value and 
  data.raw.technology["electrolysis-1"] and
  data.raw.item["electrolyser"] and
  data.raw["recipe-category"]["electrolysis"]
then

data:extend(
{
  {
    type = "item-subgroup",
    name = "bob-electrolyser-machine",
    group = "production",
    order = "e-d",
  },
}
)


data.raw.item["electrolyser"].subgroup = "bob-electrolyser-machine"


function bob_chemical_plant_fluid_boxes()
  return {
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 10,
      base_level = -1,
      pipe_connections = {{ type="input", position = {-1, -2} }}
    },
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 10,
      base_level = -1,
      pipe_connections = {{ type="input", position = {1, -2} }}
    },
    {
      production_type = "output",
      pipe_covers = pipecoverspictures(),
      base_level = 1,
      pipe_connections = {{ position = {-1, 2} }}
    },
    {
      production_type = "output",
      pipe_covers = pipecoverspictures(),
      base_level = 1,
      pipe_connections = {{ position = {1, 2} }}
    }
  }
end


data:extend(
{
  {
    type = "item",
    name = "electrolyser-2",
    icon = "__bobassembly__/graphics/icons/electrolyser-2.png",
    icon_size = 32,
    
    subgroup = "bob-electrolyser-machine",
    order = "e[electrolyser-2]",
    place_result = "electrolyser-2",
    stack_size = 50
  },
  {
    type = "item",
    name = "electrolyser-3",
    icon = "__bobassembly__/graphics/icons/electrolyser-3.png",
    icon_size = 32,
    
    subgroup = "bob-electrolyser-machine",
    order = "e[electrolyser-3]",
    place_result = "electrolyser-3",
    stack_size = 50
  },
  {
    type = "item",
    name = "electrolyser-4",
    icon = "__bobassembly__/graphics/icons/electrolyser-4.png",
    icon_size = 32,
    
    subgroup = "bob-electrolyser-machine",
    order = "e[electrolyser-4]",
    place_result = "electrolyser-4",
    stack_size = 50
  },


  {
    type = "recipe",
    name = "electrolyser-2",
    energy_required = 5,
    enabled = "false",
    ingredients =
    {
      {"electrolyser", 2},
      {"plastic-bar", 10},
      {"steel-plate", 10},
      {"advanced-circuit", 5},
      {"pipe", 5},
    },
    result = "electrolyser-2"
  },

  {
    type = "recipe",
    name = "electrolyser-3",
    energy_required = 5,
    enabled = "false",
    ingredients =
    {
      {"electrolyser-2", 2},
      {"plastic-bar", 10},
      {"steel-plate", 10},
      {"iron-plate", 10},
      {"processing-unit", 10},
      {"pipe", 5},
    },
    result = "electrolyser-3"
  },

  {
    type = "recipe",
    name = "electrolyser-4",
    energy_required = 5,
    enabled = "false",
    ingredients =
    {
      {"electrolyser-3", 2},
      {"plastic-bar", 10},
      {"steel-plate", 10},
      {"iron-plate", 10},
      {"processing-unit", 10},
      {"pipe", 5},
    },
    result = "electrolyser-4"
  },


  {
    type = "assembling-machine",
    name = "electrolyser-2",
    icon = "__bobassembly__/graphics/icons/electrolyser-2.png",
    icon_size = 32,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "electrolyser-2"},
    fast_replaceable_group = "electrolyser",
    next_upgrade = "electrolyser-3",
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 275,
    crafting_categories = {"electrolysis"},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    module_specification =
    {
      module_slots = 3,
    },
    crafting_speed = 1.5,
    energy_usage = "750kW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_second_per_watt = 3 / 750000
    },
    fluid_boxes = bob_chemical_plant_fluid_boxes(),
    animation =
    {
      north =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt2u.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      west =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t2l.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      },
      south =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt2d.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      east =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t2r.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      }
    },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/chemical-plant.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
  },

  {
    type = "assembling-machine",
    name = "electrolyser-3",
    icon = "__bobassembly__/graphics/icons/electrolyser-3.png",
    icon_size = 32,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "electrolyser-3"},
    fast_replaceable_group = "electrolyser",
    next_upgrade = "electrolyser-4",
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 375,
    crafting_categories = {"electrolysis"},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    module_specification =
    {
      module_slots = 5,
    },
    crafting_speed = 2.5,
    energy_usage = "1125kW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_second_per_watt = 2 / 750000
    },
    fluid_boxes = bob_chemical_plant_fluid_boxes(),
    animation =
    {
      north =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt3u.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      west =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t3l.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      },
      south =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt3d.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      east =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t3r.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      }
    },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/chemical-plant.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
  },

  {
    type = "assembling-machine",
    name = "electrolyser-4",
    icon = "__bobassembly__/graphics/icons/electrolyser-4.png",
    icon_size = 32,
    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "electrolyser-4"},
    fast_replaceable_group = "electrolyser",
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 500,
    crafting_categories = {"electrolysis"},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    module_specification =
    {
      module_slots = 6,
    },
    crafting_speed = 3.5,
    energy_usage = "1400kW",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_second_per_watt = 1 / 750000
    },
    fluid_boxes = bob_chemical_plant_fluid_boxes(),
    animation =
    {
      north =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt4u.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      west =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t4l.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      },
      south =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-vt4d.png",
        width = 108,
        height = 130,
        frame_count = 1,
        shift = {0, -0.28125}
      },
      east =
      {
        filename = "__bobassembly__/graphics/entity/electrolyser/electro-h-t4r.png",
        width = 112,
        height = 120,
        frame_count = 1,
        shift = {0, -0.21875}
      }
    },
    working_sound =
    {
      sound = {
        {
          filename = "__base__/sound/chemical-plant.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5,
    },
  },


  {
    type = "technology",
	hidden = true, --DrD
    name = "electrolyser-2",
    icon = "__bobassembly__/graphics/icons/technology/electrolyser.png",
    icon_size = 128,
    prerequisites =
    {
      "electrolysis-1",
      "steel-processing",
      "advanced-electronics",
    },
    --[[ DrD
	effects =
    {
      {
        type = "unlock-recipe",
        recipe = "electrolyser-2"
      },
    },
	]]
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "d-e-a2"
  },

  {
    type = "technology",
		hidden = true, --DrD
    name = "electrolyser-3",
    icon = "__bobassembly__/graphics/icons/technology/electrolyser.png",
    icon_size = 128,
    prerequisites =
    {
      "electrolyser-2",
      "advanced-electronics-2",
    },
	    --[[ DrD
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "electrolyser-3"
      },
    },
]]
    unit =
    {
      count = 75,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "d-e-a3"
  },

  {
    type = "technology",
		hidden = true, --DrD
    name = "electrolyser-4",
    icon = "__bobassembly__/graphics/icons/technology/electrolyser.png",
    icon_size = 128,
    prerequisites =
    {
      "electrolyser-3",
    },
    --[[ DrD
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "electrolyser-4"
      },
    },
]]
    unit =
    {
      count = 100,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "d-e-a4"
  },
}
)


end
