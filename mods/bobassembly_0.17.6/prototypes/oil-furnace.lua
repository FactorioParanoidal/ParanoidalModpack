if settings.startup["bobmods-assembly-oilfurnaces"].value == true then

data:extend({
  {
    type = "item",
    name = "oil-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 32,
    subgroup = "smelting-machine",
    order = "b[steela-furnace]",
    place_result = "oil-steel-furnace",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "oil-steel-furnace",
    enabled = false,
    ingredients =
    {
      {"steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-steel-furnace",
    energy_required = 5,
  },
  util.merge
  {
    data.raw.furnace["steel-furnace"],
    {
      name = "oil-steel-furnace",
      minable = {result = "oil-steel-furnace"},
      energy_source =
      {
        type = "fluid",
        emissions_per_minute = 3,
        burns_fluid = true,
        scale_fluid_usage = true,
        fluid_box =
        {
          base_area = 1,
          height = 2,
          base_level = -1,
          pipe_connections =
          {
            {type = "input-output", position = { 1.5, 0.5}},
            {type = "input-output", position = {-1.5, 0.5}}
          },
          pipe_covers = pipecoverspictures(),
          pipe_picture = assembler2pipepictures(),
          production_type = "input-output",
        },
      }
    }
  },
  {
    type = "technology",
    name = "oil-steel-furnace",
    icon_size = 128,
    icon = "__base__/graphics/technology/advanced-material-processing.png",
    prerequisites =
    {
      "advanced-material-processing",
      "oil-processing"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "oil-steel-furnace"
      }
    },
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "c-c-a"
  },
}
)

if data.raw["assembling-machine"]["mixing-steel-furnace"] then
data:extend({
  {
    type = "item",
    name = "oil-mixing-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 32,
    subgroup = "bob-smelting-machine",
    order = "b[mixing-furnace-3]",
    place_result = "oil-mixing-steel-furnace",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "oil-mixing-steel-furnace",
    enabled = false,
    ingredients =
    {
      {"mixing-steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-mixing-steel-furnace",
    energy_required = 5,
  },
  util.merge
  {
    data.raw["assembling-machine"]["mixing-steel-furnace"],
    {
      name = "oil-mixing-steel-furnace",
      minable = {result = "oil-mixing-steel-furnace"},
      energy_source =
      {
        type = "fluid",
        emissions_per_minute = 3,
        burns_fluid = true,
        scale_fluid_usage = true,
        fluid_box =
        {
          base_area = 1,
          height = 2,
          base_level = -1,
          pipe_connections =
          {
            {type = "input-output", position = { 1.5, 0.5}},
            {type = "input-output", position = {-1.5, 0.5}}
          },
          pipe_covers = pipecoverspictures(),
          pipe_picture = assembler2pipepictures(),
          production_type = "input-output",
        },
      }
    }
  },
  {
    type = "technology",
    name = "oil-mixing-steel-furnace",
    icon = "__bobassembly__/graphics/icons/technology/alloy-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "mixing-steel-furnace",
      "oil-processing"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "oil-mixing-steel-furnace"
      },
    },
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "c-c-a-b"
  },
}
)
end

if data.raw["assembling-machine"]["chemical-steel-furnace"] then
data:extend({
  {
    type = "item",
    name = "oil-chemical-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 32,
    subgroup = "bob-smelting-machine",
    order = "b[chemical-boiler-3]",
    place_result = "oil-chemical-steel-furnace",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "oil-chemical-steel-furnace",
    enabled = false,
    ingredients =
    {
      {"chemical-steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-chemical-steel-furnace",
    energy_required = 5,
  },
  util.merge
  {
    data.raw["assembling-machine"]["chemical-steel-furnace"],
    {
      name = "oil-chemical-steel-furnace",
      minable = {result = "oil-chemical-steel-furnace"},
      energy_source =
      {
        type = "fluid",
        emissions_per_minute = 3,
        burns_fluid = true,
        scale_fluid_usage = true,
        fluid_box =
        {
          base_area = 1,
          height = 2,
          base_level = -1,
          pipe_connections =
          {
            {type = "input-output", position = { 1.5, 0.5}},
            {type = "input-output", position = {-1.5, 0.5}}
          },
          pipe_covers = pipecoverspictures(),
          pipe_picture = assembler2pipepictures(),
          production_type = "input-output",
        },
      }
    }
  },
  {
    type = "technology",
    name = "oil-chemical-steel-furnace",
    icon = "__bobassembly__/graphics/icons/technology/chemical-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "chemical-processing-2",
      "oil-processing"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "oil-chemical-steel-furnace"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "c-c-a-c"
  },
}
)
end
end
