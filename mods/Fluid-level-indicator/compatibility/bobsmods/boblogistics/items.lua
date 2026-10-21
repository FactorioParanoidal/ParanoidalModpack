-- steel fluid level indicator straight for bobs logistics

fluid_level_indicator_bobsteel = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_bobsteel.name = "fluid-level-indicator-st-bobs-steel"
fluid_level_indicator_bobsteel.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK2.png"
fluid_level_indicator_bobsteel.icon_size = 128
fluid_level_indicator_bobsteel.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_bobsteel.minable = {mining_time = 0.1, result = "fluid-level-indicator-st-bobs-steel"}
fluid_level_indicator_bobsteel.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_bobsteel.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_bobsteel.apply_runtime_tint = true
fluid_level_indicator_bobsteel.corpse = "pipe-remnants"
fluid_level_indicator_bobsteel.dying_explosion = "pump-explosion"
fluid_level_indicator_bobsteel.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_bobsteel.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_bobsteel.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_bobsteel.se_allow_in_space = true
fluid_level_indicator_bobsteel.max_health = 100
fluid_level_indicator_bobsteel.circuit_connector = circuit_connector_definitions["fluid-level-indicator-straight"]
fluid_level_indicator_bobsteel.water_reflection = 
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

fluid_level_indicator_bobsteel.fluid_box = 
{
  volume = 100,
  base_area = 1,
  base_level = 0,
  height = 1,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
  {
    { flow_direction = "input-output", direction = defines.direction.south, position = {0, -0.0001} },
    { flow_direction = "input-output", direction = defines.direction.north, position = {0, 0.0001} }
  },
      hide_connection_info = true
}
fluid_level_indicator_bobsteel.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-screen.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        scale = 0.5,
      },
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-shadow.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        shift = util.by_pixel(0, 0),
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

-- plastic fluid level indicator straight for bobs logistics

fluid_level_indicator_bobplastic = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_bobplastic.name = "fluid-level-indicator-st-bobs-plastic"
fluid_level_indicator_bobplastic.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK3.png"
fluid_level_indicator_bobplastic.icon_size = 128
fluid_level_indicator_bobplastic.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_bobplastic.minable = {mining_time = 0.1, result = "fluid-level-indicator-st-bobs-plastic"}
fluid_level_indicator_bobplastic.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_bobplastic.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_bobplastic.apply_runtime_tint = true
fluid_level_indicator_bobplastic.corpse = "pipe-remnants"
fluid_level_indicator_bobplastic.dying_explosion = "pump-explosion"
fluid_level_indicator_bobplastic.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_bobplastic.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_bobplastic.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_bobplastic.se_allow_in_space = true
fluid_level_indicator_bobplastic.max_health = 100
fluid_level_indicator_bobplastic.circuit_connector = circuit_connector_definitions["fluid-level-indicator-straight"]
fluid_level_indicator_bobplastic.water_reflection = 
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

fluid_level_indicator_bobplastic.fluid_box = 
{
  volume = 100,
  base_area = 1,
  base_level = 0,
  height = 1,
  pipe_covers = pipecoverspictures(),
  pipe_connections =
    {
      { flow_direction = "input-output", direction = defines.direction.south, position = {0, -0.0001} },
      { flow_direction = "input-output", direction = defines.direction.north, position = {0, 0.0001} }
    },
    hide_connection_info = true
}
fluid_level_indicator_bobplastic.pictures = 
{
  picture =
  {
    sheets =
    {
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-screen.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        scale = 0.5,
      },
      {
        filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-shadow.png",
        priority = "extra-high",
        frames = 2,
        width = 128,
        height = 128,
        shift = util.by_pixel(0, 0),
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

if settings.startup["bobmods-logistics-highpipes"].value == true then
  fluid_level_indicator_bobsteel.fluid_box.height = 1.5
  fluid_level_indicator_bobplastic.fluid_box.height = 2.25
end


data:extend({
{
  type = "item",
  name = "fluid-level-indicator-st-bobs-steel",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK2.png",
  icon_size = 128,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-b0]",
  place_result = "fluid-level-indicator-st-bobs-steel",
  stack_size = 50
},
{
  type = "item",
  name = "fluid-level-indicator-st-bobs-plastic",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK3.png",
  icon_size = 128,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-b1]",
  place_result = "fluid-level-indicator-st-bobs-plastic",
  stack_size = 50
},
fluid_level_indicator_bobsteel,
fluid_level_indicator_bobplastic
})