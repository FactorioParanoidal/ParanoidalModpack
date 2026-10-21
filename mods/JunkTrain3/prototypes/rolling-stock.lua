local function sound(name, volume)
  return {filename = "__JunkTrain3__/sound/" .. name .. ".ogg", volume = volume}
end

local impact_sounds = {}
for index = 2, 6 do
  impact_sounds[#impact_sounds + 1] = sound("car-metal-impact-" .. index, 0.5)
end

local function tie_trigger(volume)
  local sounds = {}
  for index = 1, 6 do
    sounds[#sounds + 1] = sound("train-tie-" .. index, volume)
  end
  return {type = "play-sound", sound = sounds}
end

local transparent_wheels = {
  rotated = {
    priority = "very-low",
    width = 1,
    height = 1,
    direction_count = 1,
    filename = "__JunkTrain3__/graphics/nothing.png",
  },
}

local back_light = {
  {
    minimum_darkness = 0.3,
    color = {r = 1, g = 0.1, b = 0.05, a = 0},
    shift = {-0.6, 1.75},
    size = 2,
    intensity = 0.6,
    add_perspective = true,
  },
  {
    minimum_darkness = 0.3,
    color = {r = 1, g = 0.1, b = 0.05, a = 0},
    shift = {0.6, 1.75},
    size = 2,
    intensity = 0.6,
    add_perspective = true,
  },
}

local locomotive = table.deepcopy(data.raw.locomotive.locomotive)
locomotive.name = "yir_usl"
locomotive.icon = "__JunkTrain3__/graphics/train/t0/usl_icon.png"
locomotive.icons = nil
locomotive.icon_size = 64
locomotive.flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
locomotive.minable = {mining_time = 1, result = "JunkTrain"}
locomotive.mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"}
locomotive.max_health = 1000
locomotive.corpse = "medium-remnants"
locomotive.dying_explosion = "medium-explosion"
locomotive.collision_box = {{-0.6, -1.5}, {0.6, 1.1}}
locomotive.selection_box = {{-0.7, -1.6}, {1, 1.2}}
locomotive.drawing_box = {{-2, -2}, {2, 2}}
locomotive.vertical_selection_shift = -0.5
locomotive.weight = 1000
locomotive.max_speed = 0.25
locomotive.max_power = "200kW"
locomotive.reversing_power_modifier = 0.5
locomotive.braking_force = 10
locomotive.friction_force = 0.5
locomotive.air_resistance = 0.005
locomotive.connection_distance = 2.2
locomotive.joint_distance = 1.1
locomotive.energy_per_hit_point = 5
locomotive.tie_distance = 50
locomotive.resistances = {
  {type = "physical", decrease = 30, percent = 50},
  {type = "impact", decrease = 50, percent = 60},
}
locomotive.energy_source = {
  type = "burner",
  fuel_categories = {"chemical"},
  effectivity = 0.5,
  fuel_inventory_size = 3,
  smoke = {
    {
      name = "train-smoke",
      deviation = {0.3, 0.3},
      frequency = 100,
      position = {0, 0.5},
      starting_frame = 0,
      starting_frame_deviation = 60,
      height = 2,
      height_deviation = 0.5,
      starting_vertical_speed = 0.2,
      starting_vertical_speed_deviation = 0.1,
    },
  },
}
locomotive.pictures = {
  rotated = {
    priority = "very-low",
    width = 256,
    height = 256,
    direction_count = 128,
    line_length = 8,
    lines_per_file = 8,
    filenames = {
      "__JunkTrain3__/graphics/train/t0/usl_sheet-0.png",
      "__JunkTrain3__/graphics/train/t0/usl_sheet-1.png",
    },
    shift = {0, -0.625},
    usage = "train",
  },
}
locomotive.wheels = transparent_wheels
locomotive.stop_trigger = {
  {
    type = "create-trivial-smoke",
    repeat_count = 75,
    smoke_name = "smoke-train-stop",
    initial_height = 0,
    speed = {-0.03, 0},
    speed_multiplier = 0.75,
    speed_multiplier_deviation = 1.1,
    offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}},
  },
  {
    type = "create-trivial-smoke",
    repeat_count = 75,
    smoke_name = "smoke-train-stop",
    initial_height = 0,
    speed = {0.03, 0},
    speed_multiplier = 0.75,
    speed_multiplier_deviation = 1.1,
    offset_deviation = {{0.3, -2.7}, {0.75, 2.7}},
  },
  {type = "play-sound", sound = sound("train-breaks", 0.3)},
  {
    type = "play-sound",
    sound = {
      sound("train-brake-screech", 0.3),
      sound("train-brake-screech-1", 0.3),
    },
  },
}
locomotive.drive_over_tie_trigger = tie_trigger(0.4)
locomotive.working_sound = {
  sound = sound("train-engine", 0.4),
  match_speed_to_activity = true,
  max_sounds_per_type = 2,
}
locomotive.open_sound = sound("train-door-open", 0.5)
locomotive.close_sound = sound("train-door-close", 0.4)
locomotive.vehicle_impact_sound = impact_sounds
locomotive.front_light = {
  {
    type = "oriented",
    minimum_darkness = 0.3,
    picture = {
      filename = "__core__/graphics/light-cone.png",
      priority = "extra-high",
      flags = {"light"},
      scale = 2,
      width = 200,
      height = 200,
    },
    shift = {0, -14},
    size = 2,
    intensity = 0.6,
    color = {r = 1, g = 0.9, b = 0.9},
  },
}
locomotive.back_light = back_light
locomotive.stand_by_light = nil
locomotive.allow_manual_color = false
locomotive.sound_minimum_speed = 0.1
locomotive.sound_scaling_ratio = 0.35
local wagon = table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
wagon.name = "yir_us_cargo"
wagon.icon = "__JunkTrain3__/graphics/train/t0/usw_icon.png"
wagon.icons = nil
wagon.icon_size = 64
wagon.flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
wagon.inventory_size = 10
wagon.minable = {mining_time = 1, result = "ScrapTrailer"}
wagon.mined_sound = {filename = "__core__/sound/deconstruct-medium.ogg"}
wagon.max_health = 400
wagon.corpse = "medium-remnants"
wagon.dying_explosion = "medium-explosion"
wagon.collision_box = {{-0.6, -1.5}, {0.6, 1.1}}
wagon.selection_box = {{-0.7, -1.6}, {1, 1.2}}
wagon.vertical_selection_shift = -0.5
wagon.weight = 500
wagon.max_speed = 0.5
wagon.braking_force = 2
wagon.friction_force = 0.0015
wagon.air_resistance = 0.002
wagon.connection_distance = 2.2
wagon.joint_distance = 1.1
wagon.energy_per_hit_point = 5
wagon.tie_distance = 50
wagon.resistances = {
  {type = "physical", decrease = 30, percent = 50},
  {type = "impact", decrease = 50, percent = 60},
  {type = "acid", decrease = 10, percent = 20},
}
wagon.pictures = {
  rotated = {
    priority = "very-low",
    width = 256,
    height = 256,
    direction_count = 64,
    line_length = 8,
    lines_per_file = 8,
    filename = "__JunkTrain3__/graphics/train/t0/usw_sheet.png",
    back_equals_front = true,
    shift = {0, -0.625},
    usage = "train",
  },
}
wagon.wheels = transparent_wheels
wagon.horizontal_doors = {
  layers = {
    {
      filename = "__JunkTrain3__/graphics/train/t0/usw_we.png",
      line_length = 1,
      width = 256,
      height = 256,
      frame_count = 1,
      shift = {0, -0.625},
      usage = "train",
    },
  },
}
wagon.vertical_doors = {
  layers = {
    {
      filename = "__JunkTrain3__/graphics/train/t0/usw_ns.png",
      line_length = 1,
      width = 256,
      height = 256,
      frame_count = 1,
      shift = {0, -0.625},
      usage = "train",
    },
  },
}
wagon.crash_trigger = {type = "play-sound", sound = sound("car-crash", 0)}
wagon.drive_over_tie_trigger = tie_trigger(0.6)
wagon.working_sound = {
  sound = sound("train-wheels", 0.6),
  match_speed_to_activity = true,
  max_sounds_per_type = 2,
}
wagon.open_sound = sound("cargo-wagon-open", 0.55)
wagon.close_sound = sound("cargo-wagon-close", 0.55)
wagon.vehicle_impact_sound = impact_sounds
wagon.back_light = back_light
wagon.stand_by_light = nil
wagon.allow_manual_color = false
wagon.sound_minimum_speed = 1
data:extend({locomotive, wagon})
