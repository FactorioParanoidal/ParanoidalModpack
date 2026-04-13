data:extend({
  {
    type = "furnace",
    name = "air-filter-machine",
    icon = "__air-filtering__/graphics/icons/air-filter-machine.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    graphics_set = 
    { animation =
    {
      filename = "__air-filtering__/graphics/entity/air-filter-machine.png",
      priority = "high",
      width = 99,
      height = 102,
      frame_count = 32,
      line_length = 8,
      shift = {0.4, -0.06}
    }
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
      emissions_per_minute = { pollution = -180 }
    },
    energy_usage = "200kW",
    ingredient_count = 1,
    module_slots = 0,
    -- Basic circuit network properties
    circuit_wire_max_distance = 7.5,
    draw_copper_wires = true,
    draw_circuit_wires = true
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk2",
    icon = "__air-filtering__/graphics/icons/air-filter-machine-mk2.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk2"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    graphics_set = 
    { animation =
    {
      filename = "__air-filtering__/graphics/entity/air-filter-machine-mk2.png",
      priority = "high",
      width = 99,
      height = 102,
      frame_count = 32,
      line_length = 8,
      shift = {0.4, -0.06}
    }
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
    crafting_speed = 2.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = -480 }
    },
    energy_usage = "350kW",
    ingredient_count = 1,
    module_slots = 0,
    -- Basic circuit network properties
    circuit_wire_max_distance = 7.5,
    draw_copper_wires = true,
    draw_circuit_wires = true
  },
  {
    type = "furnace",
    name = "air-filter-machine-mk3",
    icon = "__air-filtering__/graphics/icons/air-filter-machine-mk3.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "air-filter-machine-mk3"},
    fast_replaceable_group = "air-filter-machine",
    max_health = 150,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    graphics_set = 
    { animation =
    {
      filename = "__air-filtering__/graphics/entity/air-filter-machine-mk3.png",
      priority = "high",
      width = 99,
      height = 102,
      frame_count = 32,
      line_length = 8,
      shift = {0.4, -0.06}
    }
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
    crafting_speed = 4.0,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = -2400 },
    },
    energy_usage = "1MW",
    ingredient_count = 1,
    module_slots = 0,
    -- Basic circuit network properties
    circuit_wire_max_distance = 7.5,
    draw_copper_wires = true,
    draw_circuit_wires = true
  }
})
