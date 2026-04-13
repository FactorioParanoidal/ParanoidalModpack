local constants = require("prototypes.constants")

data:extend({
  {
    type = "recipe",
    name = "duct-small",
    enabled = false,
    category = "crafting",
    energy_required = 2.0,
    ingredients = { { type = "item", name = "iron-plate", amount = 4 } },
    results = { { type = "item", name = "duct-small", amount = 1 } },
  },
  {
    type = "item",
    name = "duct-small",
    icon = "__FluidMustFlow__/graphics/icons/buildings/duct-small.png",
    subgroup = "ducts",
    order = "d[pipe]-a[duct-small]",
    place_result = "duct-small",
    stack_size = 50,
  },
  {
    type = "storage-tank",
    name = "duct-small",
    icon = "__FluidMustFlow__/graphics/icons/buildings/duct-small.png",
    flags = { "placeable-player", "player-creation" },
    minable = { mining_time = 0.8, result = "duct-small" },
    fast_replaceable_group = "ducts",
    collision_box = { { -0.79, -0.49 }, { 0.79, 0.49 } },
    selection_box = { { -1, -0.5 }, { 1, 0.5 } },
    heating_energy = feature_flags.freezing and "50kW" or nil,
    fluid_box = {
      volume = constants.volume,
      pipe_covers = nil,
      pipe_connections = {
        { direction = defines.direction.north, connection_category = "ducts", position = { 0, -0.25 } },
        { direction = defines.direction.south, connection_category = "ducts", position = { 0, 0.25 } },
      },
      hide_connection_info = true,
      max_pipeline_extent = constants.extent,
    },
    max_health = 400,
    corpse = "small-remnants",
    dying_explosion = "storage-tank-explosion",
    resistances = data.raw["pipe"]["pipe"].resistances,
    working_sound = {
      sound = { { filename = "__base__/sound/pipe.ogg", volume = 0.25 } },
      match_volume_to_activity = true,
      max_sounds_per_type = 3,
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    pictures = {
      picture = {
        north = {
          layers = {
            {
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-vertical.png",
              height = 160,
              priority = "high",
              scale = 0.5,
              width = 256,
            },
            {
              draw_as_shadow = true,
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-vertical-shadow.png",
              height = 160,
              priority = "high",
              scale = 0.5,
              width = 256,
            },
          },
        },
        east = {
          layers = {
            {
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-horizontal.png",
              height = 256,
              priority = "high",
              scale = 0.5,
              width = 128,
            },
            {
              draw_as_shadow = true,
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-horizontal-shadow.png",
              height = 256,
              priority = "high",
              scale = 0.5,
              shift = {
                0.5,
                0,
              },
              width = 128,
            },
          },
        },
        south = {
          layers = {
            {
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-vertical.png",
              height = 160,
              priority = "high",
              scale = 0.5,
              width = 256,
            },
            {
              draw_as_shadow = true,
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-vertical-shadow.png",
              height = 160,
              priority = "high",
              scale = 0.5,
              width = 256,
            },
          },
        },
        west = {
          layers = {
            {
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-horizontal.png",
              height = 256,
              priority = "high",
              scale = 0.5,
              width = 128,
            },
            {
              draw_as_shadow = true,
              filename = "__FluidMustFlow__/graphics/buildings/duct-small/duct-small-straight-horizontal-shadow.png",
              height = 256,
              priority = "high",
              scale = 0.5,
              shift = {
                0.5,
                0,
              },
              width = 128,
            },
          },
        },
      },
      gas_flow = util.empty_sprite(),
      fluid_background = util.empty_sprite(),
      window_background = util.empty_sprite(),
      flow_sprite = util.empty_sprite(),
    },
    window_bounding_box = { { 0, 0 }, { 0, 0 } },
    flow_length_in_ticks = 360,
    circuit_connector = constants.duct_circuit_connector,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
  },
})
