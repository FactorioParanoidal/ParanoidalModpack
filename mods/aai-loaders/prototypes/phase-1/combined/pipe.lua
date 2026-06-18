local pipe = data.raw.pipe.pipe
local pipe_to_ground = data.raw["pipe-to-ground"]["pipe-to-ground"]
if pipe then
  pipe.pictures.straight_vertical_single =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-straight-vertical-single.png",
    priority = "extra-high",
    width = 160,
    height = 160,
    scale = 0.5
  }
  pipe.pictures.straight_vertical =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-straight-vertical.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.straight_vertical_window =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-straight-vertical-window.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.straight_horizontal_window =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-straight-horizontal-window.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.straight_horizontal =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-straight-horizontal.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.corner_up_right =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-corner-up-right.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.corner_up_left =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-corner-up-left.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.corner_down_right =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-corner-down-right.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.corner_down_left =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-corner-down-left.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.t_up =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-t-up.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.t_down =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-t-down.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.t_right =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-t-right.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.t_left =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-t-left.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.cross =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-cross.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.ending_up =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-ending-up.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.ending_down =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-ending-down.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.ending_right =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-ending-right.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.ending_left =
  {
    filename = "__aai-loaders__/graphics/entity/pipe/pipe-ending-left.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.horizontal_window_background =
  {
    filename = "__base__/graphics/entity/pipe/pipe-horizontal-window-background.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.vertical_window_background =
  {
    filename = "__base__/graphics/entity/pipe/pipe-vertical-window-background.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe.pictures.fluid_background =
  {
    filename = "__base__/graphics/entity/pipe/fluid-background.png",
    priority = "extra-high",
    width = 64,
    height = 40,
    scale = 0.5
  }
  pipe.pictures.low_temperature_flow =
  {
    filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
    priority = "extra-high",
    width = 160,
    height = 18
  }
  pipe.pictures.middle_temperature_flow =
  {
    filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
    priority = "extra-high",
    width = 160,
    height = 18
  }
  pipe.pictures.high_temperature_flow =
  {
    filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
    priority = "extra-high",
    width = 160,
    height = 18
  }
  pipe.pictures.gas_flow =
  {
    filename = "__base__/graphics/entity/pipe/steam.png",
    priority = "extra-high",
    line_length = 10,
    width = 48,
    height = 30,
    frame_count = 60,
    axially_symmetrical = false,
    direction_count = 1
  }
end
if pipe_to_ground then
  pipe_to_ground.pictures.north =
  {
    filename = "__aai-loaders__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe_to_ground.pictures.south =
  {
    filename = "__aai-loaders__/graphics/entity/pipe-to-ground/pipe-to-ground-down.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe_to_ground.pictures.west =
  {
    filename = "__aai-loaders__/graphics/entity/pipe-to-ground/pipe-to-ground-left.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
  pipe_to_ground.pictures.east =
  {
    filename = "__aai-loaders__/graphics/entity/pipe-to-ground/pipe-to-ground-right.png",
    priority = "extra-high",
    width = 128,
    height = 128,
    scale = 0.5
  }
end
