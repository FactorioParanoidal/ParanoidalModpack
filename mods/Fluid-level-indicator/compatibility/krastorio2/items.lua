-- steel fluid level indicator for krastorio 2

circuit_connector_definitions["fluid-level-indicator-k2"] = circuit_connector_definitions["fluid-level-indicator"]
circuit_connector_definitions["fluid-level-indicator-straight-k2"] = circuit_connector_definitions["fluid-level-indicator-straight"]

fluid_level_indicator_k2 = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_k2.name = "fluid-level-indicator-k2"
fluid_level_indicator_k2.icon = "__Fluid-level-indicator__/graphics/icons/T-icon64-ss.png"
fluid_level_indicator_k2.icon_size = 64
fluid_level_indicator_k2.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_k2.minable = {mining_time = 0.1, result = "fluid-level-indicator-k2"}
fluid_level_indicator_k2.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
fluid_level_indicator_k2.selection_box = {{-0.6, -0.6}, {0.6, 0.6}}
fluid_level_indicator_k2.apply_runtime_tint = true
fluid_level_indicator_k2.corpse = "pipe-remnants"
fluid_level_indicator_k2.dying_explosion = "pump-explosion"
fluid_level_indicator_k2.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator"].points
fluid_level_indicator_k2.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator"].sprites
fluid_level_indicator_k2.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_k2.se_allow_in_space = true
fluid_level_indicator_k2.max_health = 200
fluid_level_indicator_k2.circuit_connector = circuit_connector_definitions["fluid-level-indicator"]
fluid_level_indicator_k2.water_reflection = 
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

fluid_level_indicator_k2.fluid_box = 
{
  volume = 100,
  base_area = 1.00,
  base_level = 0,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { flow_direction = "input-output", direction = defines.direction.north, position = {0, -0.0001}, connection_category = "kr-steel-pipe" },
    { flow_direction = "input-output", direction = defines.direction.east, position = {0.001, 0}, connection_category = "kr-steel-pipe" },
    { flow_direction = "input-output", direction = defines.direction.south, position = {0, 0.001}, connection_category = "kr-steel-pipe" },
    { flow_direction = "input-output", direction = defines.direction.west, position = {-0.001, 0}, connection_category = "kr-steel-pipe" }
  },
  hide_connection_info = true
}
fluid_level_indicator_k2.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-cross-screen-ss.png",
        priority = "extra-high",
        frames = 1,
        width = 128,
        height = 128,
        scale = 0.5
      },
      {
        filename = "__Fluid-level-indicator__/graphics/entities/pipe-cross-shadow.png",
        priority = "extra-high",
        frames = 1,
        width = 128,
        height = 128,
        shift = util.by_pixel(0, -1),
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

-- steel fluid level indicator straight for krastorio 2

fluid_level_indicator_straight_k2 = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_straight_k2.name = "fluid-level-indicator-straight-k2"
fluid_level_indicator_straight_k2.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-ss.png"
fluid_level_indicator_straight_k2.icon_size = 128
fluid_level_indicator_straight_k2.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_straight_k2.minable = {mining_time = 0.1, result = "fluid-level-indicator-straight-k2"}
fluid_level_indicator_straight_k2.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_straight_k2.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_straight_k2.apply_runtime_tint = true
fluid_level_indicator_straight_k2.corpse = "pipe-remnants"
fluid_level_indicator_straight_k2.dying_explosion = "pump-explosion"
fluid_level_indicator_straight_k2.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_straight_k2.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_straight_k2.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_straight_k2.se_allow_in_space = true
fluid_level_indicator_straight_k2.max_health = 200
fluid_level_indicator_straight_k2.circuit_connector = circuit_connector_definitions["fluid-level-indicator-straight"]
fluid_level_indicator_straight_k2.water_reflection = 
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

fluid_level_indicator_straight_k2.fluid_box = 
{
  volume = 100,
  base_area = 1.00,
  base_level = 0,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { flow_direction = "input-output", direction = defines.direction.south, position = {0, -0.0001}, connection_category = "kr-steel-pipe" },
    { flow_direction = "input-output", direction = defines.direction.north, position = {0, 0.0001}, connection_category = "kr-steel-pipe" }
  },
  hide_connection_info = true
}
fluid_level_indicator_straight_k2.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-screen-ss.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        scale = 0.5,
      }
    },
    {
      filename = "__Fluid-level-indicator__/graphics/entities/pipe-straight-shadow.png",
      priority = "extra-high",
      frames = 2,
      width = 128,
      height = 128,
      shift = util.by_pixel(0, 0),
      scale = 0.5,
      draw_as_shadow = true
    }
  },
  gas_flow = empty_sprite,
  fluid_background = empty_sprite,
  window_background = empty_sprite,
  flow_sprite = empty_sprite
}

data:extend({
{
  type = "item",
  name = "fluid-level-indicator-k2",
  icon = "__Fluid-level-indicator__/graphics/icons/T-icon64-ss.png",
  icon_size = 64,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-z]",
  place_result = "fluid-level-indicator-k2",
  stack_size = 50
},
{
  type = "item",
  name = "fluid-level-indicator-straight-k2",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-ss.png",
  icon_size = 128,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-z2]",
  place_result = "fluid-level-indicator-straight-k2",
  stack_size = 50
},
fluid_level_indicator_k2,
fluid_level_indicator_straight_k2,
})