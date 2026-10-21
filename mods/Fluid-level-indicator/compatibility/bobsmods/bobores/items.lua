-- tungsten fluid level indicator straight for bobs ores

fluid_level_indicator_bobtungsten = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_bobtungsten.name = "fluid-level-indicator-st-bobs-tungsten"
fluid_level_indicator_bobtungsten.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK4.png"
fluid_level_indicator_bobtungsten.icon_size = 128
fluid_level_indicator_bobtungsten.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_bobtungsten.minable = {mining_time = 0.1, result = "fluid-level-indicator-st-bobs-tungsten"}
fluid_level_indicator_bobtungsten.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_bobtungsten.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_bobtungsten.apply_runtime_tint = true
fluid_level_indicator_bobtungsten.corpse = "pipe-remnants"
fluid_level_indicator_bobtungsten.dying_explosion = "pump-explosion"
fluid_level_indicator_bobtungsten.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_bobtungsten.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_bobtungsten.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_bobtungsten.se_allow_in_space = true
fluid_level_indicator_bobtungsten.max_health = 100
fluid_level_indicator_bobtungsten.water_reflection = 
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

fluid_level_indicator_bobtungsten.fluid_box = 
{
      base_area = 1,
      base_level = 0,
      height = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { position = {0, -1} },
        { position = {0, 1} }
      },
      hide_connection_info = true
}
fluid_level_indicator_bobtungsten.pictures = 
{
      picture =
      {
        sheets =
        {
          {
            filename = "__Fluid-level-indicator__/graphics/entities/pipe-straight-screen.png",
            priority = "extra-high",
            frames = 2,
            width = 64,
            height = 64,
            --scale = 0.5,
            hr_version =
            {
              filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-screen.png",
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
            width = 64,
            height = 64,
            shift = util.by_pixel(0, 0),
            --scale = 0.5,
            draw_as_shadow = true,
            hr_version =
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
        }
      },
      gas_flow = empty_sprite,
      fluid_background = empty_sprite,
      window_background = empty_sprite,
      flow_sprite = empty_sprite,
}

-- copper-tungsten fluid level indicator straight for bobs ores

fluid_level_indicator_bobcoppertungsten = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_level_indicator_bobcoppertungsten.name = "fluid-level-indicator-st-bobs-coppertungsten"
fluid_level_indicator_bobcoppertungsten.icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK5.png"
fluid_level_indicator_bobcoppertungsten.icon_size = 128
fluid_level_indicator_bobcoppertungsten.flags = {"hide-alt-info", "placeable-player", "player-creation", "placeable-neutral", "placeable-enemy"}
fluid_level_indicator_bobcoppertungsten.minable = {mining_time = 0.1, result = "fluid-level-indicator-st-bobs-coppertungsten"}
fluid_level_indicator_bobcoppertungsten.collision_box = {{-0.32, -0.4}, {0.32, 0.4}}
fluid_level_indicator_bobcoppertungsten.selection_box = {{-0.4, -0.5}, {0.4, 0.5}}
fluid_level_indicator_bobcoppertungsten.apply_runtime_tint = true
fluid_level_indicator_bobcoppertungsten.corpse = "pipe-remnants"
fluid_level_indicator_bobcoppertungsten.dying_explosion = "pump-explosion"
fluid_level_indicator_bobcoppertungsten.circuit_wire_connection_points = circuit_connector_definitions["fluid-level-indicator-straight"].points
fluid_level_indicator_bobcoppertungsten.circuit_connector_sprites = circuit_connector_definitions["fluid-level-indicator-straight"].sprites
fluid_level_indicator_bobcoppertungsten.circuit_wire_max_distance = default_circuit_wire_max_distance
fluid_level_indicator_bobcoppertungsten.se_allow_in_space = true
fluid_level_indicator_bobcoppertungsten.max_health = 100
fluid_level_indicator_bobcoppertungsten.water_reflection = 
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

fluid_level_indicator_bobcoppertungsten.fluid_box = 
{
      base_area = 1,
      base_level = 0,
      height = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { position = {0, -1} },
        { position = {0, 1} }
      },
      hide_connection_info = true
}
fluid_level_indicator_bobcoppertungsten.pictures = 
{
      picture =
      {
        sheets =
        {
          {
            filename = "__Fluid-level-indicator__/graphics/entities/pipe-straight-screen.png",
            priority = "extra-high",
            frames = 2,
            width = 64,
            height = 64,
            --scale = 0.5,
            hr_version =
            {
              filename = "__Fluid-level-indicator__/graphics/entities/hr-pipe-straight-screen.png",
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
            width = 64,
            height = 64,
            shift = util.by_pixel(0, 0),
            --scale = 0.5,
            draw_as_shadow = true,
            hr_version =
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
        }
      },
      gas_flow = empty_sprite,
      fluid_background = empty_sprite,
      window_background = empty_sprite,
      flow_sprite = empty_sprite
}

if settings.startup["bobmods-logistics-highpipes"].value == true then
    fluid_level_indicator_bobtungsten.fluid_box.height = 3.25
    fluid_level_indicator_bobcoppertungsten.fluid_box.height = 5
end


data:extend({
{
  type = "item",
  name = "fluid-level-indicator-st-bobs-tungsten",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK4.png",
  icon_size = 128,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-b3]",
  place_result = "fluid-level-indicator-st-bobs-tungsten",
  stack_size = 50
},
{
  type = "item",
  name = "fluid-level-indicator-st-bobs-coppertungsten",
  icon = "__Fluid-level-indicator__/graphics/icons/straight-icon128-MK5.png",
  icon_size = 128,
  flags = {},
  subgroup = "energy-pipe-distribution",
  order = "fg[fluid-level-indicator-b4]",
  place_result = "fluid-level-indicator-st-bobs-coppertungsten",
  stack_size = 50
},

fluid_level_indicator_bobtungsten,
fluid_level_indicator_bobcoppertungsten
})