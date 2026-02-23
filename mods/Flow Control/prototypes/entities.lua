empty_sprite = { filename = "__core__/graphics/empty.png", size = 1, frame_count = 1 }
local pipe = data.raw["pipe"]["pipe"]

-- Pipe Elbow ****************************************************************************
pipe_elbow = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
pipe_elbow.name = "pipe-elbow"
pipe_elbow.icon = "__Flow Control__/graphics/icon/pipe-elbow.png"
pipe_elbow.icon_size = 64
pipe_elbow.minable = pipe.minable
pipe_elbow.corpse = "pipe-remnants"
pipe_elbow.max_health = pipe.max_health
pipe_elbow.resistances = pipe.resistances
pipe_elbow.fast_replaceable_group = pipe.fast_replaceable_group
pipe_elbow.next_upgrade = nil -- Make sure it's empty for mods that might add an upgrade to the storage tank
pipe_elbow.placeable_by = {item = "pipe", count = 1}
pipe_elbow.collision_box = pipe.collision_box
pipe_elbow.selection_box = {{-0.35, -0.35}, {0.5, 0.5}}
pipe_elbow.dying_explosion = pipe.dying_explosion
pipe_elbow.friendly_map_color = {69,130,165}
pipe_elbow.water_reflection = nil
pipe_elbow.icon_draw_specification  = pipe.icon_draw_specification
pipe_elbow.fluid_box =
{
  volume = 100,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { direction = defines.direction.east,   position = {0, 0} },
    { direction = defines.direction.south,  position = {0, 0} }
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
  { direction = defines.direction.east, position = {0, 0} },
  { direction = defines.direction.west, position = {0, 0} },
  { direction = defines.direction.south, position = {0, 0} }
}
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
  { direction = defines.direction.north, position = {0, 0} },
  { direction = defines.direction.south, position = {0, 0} }
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

data:extend(
{
  pipe_elbow,
  pipe_junction,
  pipe_straight
})
