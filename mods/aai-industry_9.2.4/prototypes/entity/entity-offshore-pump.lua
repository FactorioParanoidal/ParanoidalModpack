--[[data.raw["offshore-pump"]["offshore-pump"] = nil
data:extend({{
  type = "offshore-pump",
  name = "offshore-pump",
  icon = "__aai-industry__/graphics/icons/offshore-pump.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation", "filter-directions"},
  minable = {mining_time = 1, result = "offshore-pump"},
  max_health = 150,
  corpse = "small-remnants",
  fluid = "water",
  resistances =   { { type = "fire", percent = 70 }, { type = "impact",   percent = 30 } },
  collision_box = {{-0.9, -0.45}, {0.9, 0.45}}, --{{-0.6, -0.45}, {0.6, 0.3}},
  collision_mask = { "ground-tile", "object-layer" },
  fluid_box_tile_collision_test = { "ground-tile" },
  adjacent_tile_collision_test = { "water-tile" },
  tile_width = 1,
  placeable_position_visualization =
  {
    filename = "__core__/graphics/cursor-boxes-32x32.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    scale = 0.5,
    x = 3*64
  },
  selection_box = {{-1, -1.5}, {1, 0.5}}, --{{-1, -1.49}, {1, 0.49}},
  fluid_box = {
    base_area = 1,
    base_level = 1,
    pipe_covers = pipecoverspictures(),
    pipe_connections = { { position = {0, -1} }, }, -- {0, 1}
  },
  pumping_speed = 20,
  tile_width = 1,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  picture = {
    north = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-north.png",
      priority = "high",
      shift = util.by_pixel(5, -18),
      width = 89,
      height = 69
    },
    east = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-east.png",
      priority = "high",
      shift = util.by_pixel(31, -5),
      width = 94,
      height = 78
    },
    south = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-south.png",
      priority = "high",
      shift = util.by_pixel(5, 22),
      width = 90,
      height = 76
    },
    west = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-west.png",
      priority = "high",
      shift = util.by_pixel(-17, -7),
      width = 66,
      height = 75
    }
  },
  circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points,
  circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites,
  circuit_wire_max_distance = default_circuit_wire_max_distance
}})]]--
local offshore_pump = data.raw["offshore-pump"]["offshore-pump"]
offshore_pump.icon = "__aai-industry__/graphics/icons/offshore-pump.png"
offshore_pump.icon_size = 32
--offshore_pump.fluid_box.pipe_connections = { { position = {0, -1} }, }
offshore_pump.fluid_box.pipe_connections = { { position = {0, 0.6} }, }
offshore_pump.collision_box = {{-0.6, -1.45}, {0.6, 0.45}} -- v0.2.2 {{-0.6, -0.45}, {0.6, 0.45}}
offshore_pump.picture = {
  north = {
    filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-north.png",
    priority = "high",
    shift = util.by_pixel(5, -18),
    width = 89,
    height = 69
  },
  east = {
    filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-east.png",
    priority = "high",
    shift = util.by_pixel(31, -5),
    width = 94,
    height = 78
  },
  south = {
    filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-south.png",
    priority = "high",
    shift = util.by_pixel(5, 22),
    width = 90,
    height = 76
  },
  west = {
    filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-west.png",
    priority = "high",
    shift = util.by_pixel(-17, -7),
    width = 66,
    height = 75
  }
}


local offshore_pump_output = {
  type = "pump",
  name = "offshore-pump-output",
  --selection_box = {{-1.1, -0.4}, {1.1, 0.4}},
  selectable_in_game = false,
  selection_box = {{-1, -1.5}, {1, 0.5}},
  collision_box = {{-0.9, -0}, {0.9, 0.65}},
  collision_mask = {"not-colliding-with-itself"},
  fluid_box =
  {
    base_area = 1,
    height = 2,
    pipe_covers = pipecoverspictures(),
    pipe_connections =
    {
      { position = {0, 0.9}, type="output" },
      { position = {0, -0.1}, type="input" },
    },
  },
  order="z",
  icon = "__aai-industry__/graphics/icons/offshore-pump.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation", "not-deconstructable", "not-blueprintable", "placeable-off-grid"},
  max_health = 150,
  resistances =
  {
    {
      type = "fire",
      percent = 70
    },
    {
      type = "impact",
      percent = 30
    }
  },
  corpse = "small-remnants",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions = 0.01 / 2.5
  },
  energy_usage = "3MW",
  --pumping_speed = 200, -- limited by offshore section
  pumping_speed = 10000, -- limited by offshore section
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  animations =
  {
    north =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-north-animation.png",
      width = 152/8,
      height = 80/4,
      line_length =8,
      frame_count =32,
      animation_speed = 0.5,
      shift = util.by_pixel(0, -25),
    },
    east =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-east-animation.png",
      width = 232/8,
      height = 164/4,
      line_length =8,
      frame_count =32,
      animation_speed = 0.5,
      shift = util.by_pixel(-16+32-7.5, 4-7),
    },
    south =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-south-animation.png",
      width = 152/8,
      height = 48/4,
      line_length =8,
      frame_count =32,
      animation_speed = 0.5,
      shift = util.by_pixel(0, -6),
    },
    west =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-west-animation.png",
      width = 216/8,
      height = 164/4,
      line_length =8,
      frame_count =32,
      animation_speed = 0.5,
      shift = util.by_pixel(-6, -2),
    },
  },
  fluid_animation =
  {
    north =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-north-liquid.png",
      width = 26,
      height = 55,
      line_length =8,
      frame_count =32,
      shift = util.by_pixel(0, -25),
      --shift = util.by_pixel(3, -11),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-north-liquid.png",
        width = 38,
        height = 45,
        scale = 0.5,
        line_length =8,
        frame_count =32,
        shift = util.by_pixel(0, -25),
        --shift = util.by_pixel(3, -11),
      },
    },
    east =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-east-liquid.png",
      width = 18,
      height = 24,
      line_length =8,
      frame_count =32,
      shift = util.by_pixel(10, -11),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-east-liquid.png",
        width = 35,
        height = 47,
        scale = 0.5,
        line_length =8,
        frame_count =32,
        shift = util.by_pixel(10, -11),
      },
    },
    south =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-south-liquid.png",
      apply_runtime_tint = true,
      width = 20,
      height = 13,
      line_length =8,
      frame_count =32,
      shift = util.by_pixel(-0.500, -6),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-south-liquid.png",
        apply_runtime_tint = true,
        width = 38,
        height = 22,
        scale = 0.5,
        line_length =8,
        frame_count =32,
        shift = util.by_pixel(-0.500, -6),
      }
    },
    west =
    {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-west-liquid.png",
      width = 18,
      height = 24,
      line_length =8,
      frame_count =32,
      shift = util.by_pixel(-9, -10),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-west-liquid.png",
        width = 35,
        height = 46,
        scale = 0.5,
        line_length =8,
        frame_count =32,
        shift = util.by_pixel(-9, -10),
      },
    },
  },
  glass_pictures =
  {
    north = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-north-glass.png",
      width = 18,
      height = 21,
      shift = util.by_pixel(-0.5, -26),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-north-glass.png",
        width = 18*2,
        height = 21*2,
        scale = 0.5,
        shift = util.by_pixel(-0.5, -26)
      },
    },
    east = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-east-glass.png",
      width = 16,
      height = 16,
      shift = util.by_pixel(9, -15),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-east-glass.png",
        width = 16*2,
        height = 16*2,
        scale = 0.5,
        shift = util.by_pixel(9, -15),
      },
    },
    south = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-south-glass.png",
      width = 17,
      height = 12,
      shift = util.by_pixel(0, -6),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-south-glass.png",
        width = 17*2,
        height = 12*2,
        scale = 0.5,
        shift = util.by_pixel(0, -6),
      },
    },
    west = {
      filename = "__aai-industry__/graphics/entity/offshore-pump/offshore-pump-west-glass.png",
      width = 15,
      height = 16,
      shift = util.by_pixel(-9, -13),
      hr_version = {
        shift = util.by_pixel(-9, -13),
        filename = "__aai-industry__/graphics/entity/offshore-pump/hr-offshore-pump-west-glass.png",
        width = 15*2,
        height = 16,
        scale = 0.5,
      },
    },
  },
  circuit_wire_max_distance = 0
}
data:extend({offshore_pump_output})
