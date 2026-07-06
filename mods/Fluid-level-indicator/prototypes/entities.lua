empty_sprite = { 
  filename = "__core__/graphics/empty.png", 
  size = 1, 
  frame_count = 1 
}

local pipe = data.raw["pipe"]["pipe"]

-- Subgroup based on mods

local pipe_subgroup = "energy-pipe-distribution"
if mods["Flow Control"] and settings.startup["flow-control-new-group"]~=nil then
  if settings.startup["flow-control-new-group"].value == true then
    pipe_subgroup = "pipe-distribution"
  end
end
if mods["space-exploration"] then
  pipe_subgroup = "pipe"
end

-- Circuit connection definitions

circuit_connector_definitions["fluid-level-indicator"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 31,
      main_offset = util.by_pixel(10, 10),
      shadow_offset = util.by_pixel(11, 11),
      show_shadow = true },
    { variation = 31,
      main_offset = util.by_pixel(0, 0),
      shadow_offset = util.by_pixel(11, 11),
      show_shadow = true },
    { variation = 31,
      main_offset = util.by_pixel(0, 0),
      shadow_offset = util.by_pixel(11, 9),
      show_shadow = true },
    { variation = 31,
      main_offset = util.by_pixel(0, 0),
      shadow_offset = util.by_pixel(11, 9),
      show_shadow = true }
  }
)

circuit_connector_definitions["fluid-level-indicator-straight"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 31,
      main_offset = util.by_pixel(10, 10),
      shadow_offset = util.by_pixel(11, 9),
      show_shadow = true },
    { variation = 4,
      main_offset = util.by_pixel(4, -14),
      shadow_offset = util.by_pixel(2, -14),
      show_shadow = true },
    { variation = 3,
      main_offset = util.by_pixel(0, 0),
      shadow_offset = util.by_pixel(11, 9),
      show_shadow = true },
    { variation = 4,
      main_offset = util.by_pixel(0, 0),
      shadow_offset = util.by_pixel(8, 14),
      show_shadow = true }
  }
)

-- fluid level indicator 

fluid_level_indicator = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator.name = "fluid-level-indicator"
fluid_level_indicator.icon = "__Fluid-level-indicator__/graphics/icons/T-icon64.png"
fluid_level_indicator.icon_size = 64
fluid_level_indicator.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator.minable = {mining_time = 0.1, result = "fluid-level-indicator"}
fluid_level_indicator.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
fluid_level_indicator.selection_box = {{-0.6, -0.6}, {0.6, 0.6}}
fluid_level_indicator.apply_runtime_tint = true
fluid_level_indicator.corpse = "pipe-remnants"
fluid_level_indicator.dying_explosion = "pipe-explosion"
fluid_level_indicator.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator"].points
fluid_level_indicator.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator"].sprites
fluid_level_indicator.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator.se_allow_in_space = true
fluid_level_indicator.max_health = 100
fluid_level_indicator.circuit_connector = circuit_connector_definitions["fluid-level-indicator"]
fluid_level_indicator.water_reflection = 
{
  pictures =
  {
    filename = "__Fluid-level-indicator__/graphics/entities/fluid-level-reflection.png",
    priority = "extra-high",
    width = 24,
    height = 24,
    shift = util.by_pixel(5, 35),
    variation_count = 1,
    scale = 5
  },
  rotate = false,
  orientation_to_variation = false
}

fluid_level_indicator.fluid_box = 
{
  volume = 100,
  base_area = 1,
  base_level = 0,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { flow_direction = "input-output", direction = defines.direction.north, position = {0, -0.0001} },
    { flow_direction = "input-output", direction = defines.direction.east, position = {0.001, 0} },
    { flow_direction = "input-output", direction = defines.direction.south, position = {0, 0.001} },
    { flow_direction = "input-output", direction = defines.direction.west, position = {-0.001, 0} }
  },
  hide_connection_info = true
}
fluid_level_indicator.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/pipe-cross-screen-wshadow.png",
        priority = "extra-high",
        frames = 1,
        width = 128,
        height = 128,
        scale = 0.5
      }
    }
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

-- fluid level indicator straight

fluid_level_indicator_straight = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_straight.name = "fluid-level-indicator-straight"
fluid_level_indicator_straight.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128.png"
fluid_level_indicator_straight.icon_size = 128
fluid_level_indicator_straight.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_straight.minable = {mining_time = 0.1, result = "fluid-level-indicator-straight"}
fluid_level_indicator_straight.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_straight.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_straight.apply_runtime_tint = true
fluid_level_indicator_straight.corpse = "pipe-remnants"
fluid_level_indicator_straight.dying_explosion = "pipe-explosion"
fluid_level_indicator_straight.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_straight.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_straight.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_straight.se_allow_in_space = true
fluid_level_indicator_straight.max_health = 100
fluid_level_indicator_straight.circuit_connector = circuit_connector_definitions["fluid-level-indicator-straight"]
fluid_level_indicator_straight.water_reflection = 
{
  pictures =
  {
    filename = "__Fluid-level-indicator__/graphics/entities/fluid-level-reflection.png",
    priority = "extra-high",
    width = 24,
    height = 24,
    shift = util.by_pixel(5, 35),
    variation_count = 1,
    scale = 5
  },
  rotate = false,
  orientation_to_variation = false
}

fluid_level_indicator_straight.fluid_box = 
{
  volume = 100,
  base_area = 1,
  base_level = 0,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { flow_direction = "input-output", direction = defines.direction.south, position = {0, -0.0001} },
    { flow_direction = "input-output", direction = defines.direction.north, position = {0, 0.0001} }
  },
  hide_connection_info = true
}
fluid_level_indicator_straight.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/pipe-straight-screen-wshadow.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        scale = 0.5
      }
    }
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

empty_sprite.name = "flinumber "
empty_sprite.type = "sprite"

data:extend({
{
  type = "item",
  name = "fluid-level-indicator",
  icon = "__Fluid-level-indicator__/graphics/icons/T-icon64.png",
  icon_size = 64,
  flags = {},
  subgroup = pipe_subgroup,
  order = "f[fluid-level-indicator]",
  place_result = "fluid-level-indicator",
  stack_size = 50
},
{
  type = "item",
  name = "fluid-level-indicator-straight",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128.png",
  icon_size = 128,
  flags = {},
  subgroup = pipe_subgroup,
  order = "f[fluid-level-indicator-straight]",
  place_result = "fluid-level-indicator-straight",
  stack_size = 50
},
fluid_level_indicator,
fluid_level_indicator_straight,
empty_sprite
})
