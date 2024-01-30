empty_sprite = { filename = "__core__/graphics/empty.png", size = 1, frame_count = 1 }
local pipe = data.raw["pipe"]["pipe"]

-- Pipe Elbow ****************************************************************************
pipe_elbow = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
pipe_elbow.name = "pipe-elbow"
pipe_elbow.icon = "__Flow Control__/graphics/icon/pipe-elbow.png"
pipe_elbow.icon_size = 64
pipe_elbow.icon_mipmaps = nil
pipe_elbow.minable = pipe.minable
-- pipe_elbow.corpse = "small-remnants"
pipe_elbow.corpse = "pipe-remnants"
pipe_elbow.max_health = pipe.max_health
pipe_elbow.resistances = pipe.resistances
pipe_elbow.fast_replaceable_group = pipe.fast_replaceable_group
pipe_elbow.placeable_by = {item = "pipe", count = 1}
pipe_elbow.collision_box = pipe.collision_box
pipe_elbow.selection_box = {{-0.35, -0.35}, {0.5, 0.5}}
pipe_elbow.dying_explosion = pipe.dying_explosion
pipe_elbow.friendly_map_color = {69,130,165}
pipe_elbow.water_reflection = nil
pipe_elbow.fluid_box =
{
  base_area = 1,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { position = {1, 0} },
    { position = {0, 1} }
  },
  hide_connection_info = true,
}
pipe_elbow.two_direction_only = false
pipe_elbow.pictures =
{
  picture =
  {
    north = pipepictures().corner_down_right,
    east = pipepictures().corner_down_left,
    south = pipepictures().corner_up_left,
    west = pipepictures().corner_up_right
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}
pipe_elbow.circuit_wire_max_distance = 0
pipe_elbow.working_sound = nil

-- Pipe Junction *************************************************************************
pipe_junction = util.table.deepcopy(pipe_elbow)
pipe_junction.name = "pipe-junction"
pipe_junction.icon = "__Flow Control__/graphics/icon/pipe-junction.png"
pipe_junction.selection_box = {{-0.5, -0.35}, {0.5, 0.5}}
pipe_junction.fluid_box.pipe_connections =
{
  { position = {1, 0} },
  { position = {0, 1} },
  { position = {-1, 0} }
}
-- pipe_junction.pictures.picture.sheet.filename =
  -- "__Flow Control__/graphics/entity/pipes/pipe-junction.png"
pipe_junction.pictures =
{
  picture =
  {
    north = pipepictures().t_down,
    east = pipepictures().t_left,
    south = pipepictures().t_up,
    west = pipepictures().t_right
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

-- Pipe Straight *************************************************************************
pipe_straight = util.table.deepcopy(pipe_elbow)
pipe_straight.name = "pipe-straight"
pipe_straight.icon = "__Flow Control__/graphics/icon/pipe-straight.png"
pipe_straight.selection_box = {{-0.35, -0.5}, {0.35, 0.5}}
pipe_straight.fluid_box.pipe_connections =
{
  { position = {0, -1} },
  { position = {0, 1} }
}
pipe_straight.pictures =
{
  picture =
  {
    north = pipepictures().straight_vertical,
    east = pipepictures().straight_horizontal,
    south = pipepictures().straight_vertical,
    west = pipepictures().straight_horizontal
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

-------------------------------------------------- VALVES ---------------------------------------------------------------------

-- Check Valve ***************************************************************************
check_valve = util.table.deepcopy(pipe_straight)
check_valve.name = "check-valve"
check_valve.icon = "__Flow Control__/graphics/icon/check-valve.png"
check_valve.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
check_valve.minable = {mining_time = 0.1, result = "check-valve"}
check_valve.placeable_by = nil
check_valve.fluid_box =
{
  base_area = 1,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { position = {0, 1}, type="output" },
    { position = {0, -1} }
  },
}
check_valve.pictures.picture =
{
  sheet =
  {
    filename = "__Flow Control__/graphics/entity/check-valve/check-valve.png",
    frames = 4,
    width = 64,
    height = 64,
    hr_version = {
      filename = "__Flow Control__/graphics/entity/check-valve/hr-check-valve.png",
      frames = 4,
      width = 128,
      height = 128,
      scale = 0.5,
    }
  }
}
check_valve.circuit_wire_connection_points = circuit_connector_definitions["inserter"].points
check_valve.circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites
check_valve.circuit_wire_max_distance = data.raw["storage-tank"]["storage-tank"].circuit_wire_max_distance

-- Overflow Valve ************************************************************************
overflow_valve = util.table.deepcopy(check_valve)
overflow_valve.name = "overflow-valve"
overflow_valve.icon = "__Flow Control__/graphics/icon/overflow-valve.png"
overflow_valve.minable.result = "overflow-valve"
overflow_valve.fluid_box.base_level = 0.8
overflow_valve.pictures.picture.sheet.filename = "__Flow Control__/graphics/entity/overflow-valve/overflow-valve.png"
overflow_valve.pictures.picture.sheet.hr_version.filename = "__Flow Control__/graphics/entity/overflow-valve/hr-overflow-valve.png"

-- Underflow Valve ***********************************************************************
underflow_valve = util.table.deepcopy(overflow_valve)
underflow_valve.name = "underflow-valve"
underflow_valve.icon = "__Flow Control__/graphics/icon/underflow-valve.png"
underflow_valve.minable.result = "underflow-valve"
underflow_valve.fluid_box.base_level = -0.2
underflow_valve.pictures.picture.sheet.filename = "__Flow Control__/graphics/entity/underflow-valve/underflow-valve.png"
underflow_valve.pictures.picture.sheet.hr_version.filename = "__Flow Control__/graphics/entity/underflow-valve/hr-underflow-valve.png"

data:extend(
{
  check_valve,
  overflow_valve,
  underflow_valve,
  pipe_elbow,
  pipe_junction,
  pipe_straight
})
