local constants = require("prototypes.constants")

data:extend({
  {
    type = "recipe",
    name = "duct-underground",
    enabled = false,
    category = "crafting",
    energy_required = 6.0,
    ingredients = { { type = "item", name = "iron-plate", amount = 60 } },
    results = { { type = "item", name = "duct-underground", amount = 2 } },
  },
  {
    type = "item",
    name = "duct-underground",
    icon = "__FluidMustFlow__/graphics/icons/buildings/duct-to-ground.png",
    subgroup = "ducts",
    order = "d[pipe]-d[duct-underground]",
    place_result = "duct-underground",
    stack_size = 50,
  },
  {
    type = "pipe-to-ground",
    name = "duct-underground",
    icon = "__FluidMustFlow__/graphics/icons/buildings/duct-to-ground.png",
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.4, result = "duct-underground" },
    fast_replaceable_group = "ducts",
    collision_box = { { -0.79, -0.79 }, { 0.79, 0.7 } },
    selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
    heating_energy = feature_flags.freezing and "100kW" or nil,
    fluid_box = {
      volume = constants.volume * 2,
      pipe_connections = {
        { direction = defines.direction.north, connection_category = "ducts", position = { 0, -0.5 } },
        {
          connection_type = "underground",
          direction = defines.direction.south,
          connection_category = "ducts",
          position = { 0, 0.5 },
          max_underground_distance = settings.startup["fmf-underground-duct-max-length"].value --[[@as uint8]],
        },
      },
      hide_connection_info = true,
      max_pipeline_extent = constants.extent,
    },
    max_health = 800,
    corpse = "small-remnants",
    resistances = data.raw["pipe"]["pipe"].resistances,
    pictures = {
      north = {
        layers = {
          {
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
          {
            draw_as_shadow = true,
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up-shadow.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
        },
      },
      east = {
        layers = {
          {
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
          {
            draw_as_shadow = true,
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right-shadow.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
        },
      },
      south = {
        layers = {
          {
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
          {
            draw_as_shadow = true,
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down-shadow.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
        },
      },
      west = {
        layers = {
          {
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
          {
            draw_as_shadow = true,
            filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left-shadow.png",
            height = 256,
            priority = "high",
            scale = 0.5,
            width = 256,
          },
        },
      },
    },
    visualization = {
      north = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      east = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      south = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      west = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
    },
    disabled_visualization = {
      north = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      east = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      south = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
      west = {
        filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-visualization.png",
        size = 128,
        scale = 0.5,
        flags = { "icon" },
      },
    },
    underground_sprite = {
      filename = "__core__/graphics/arrows/underground-lines.png",
      priority = "high",
      width = 64,
      height = 64,
      scale = 0.5,
    },
  },
})
