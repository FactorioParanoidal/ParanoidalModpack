if settings.startup["bobmods-assembly-oilfurnaces"].value == true then

local function fluid_energy_source()
return
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
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          north_position = {0.7, -1.2},
          east_position = {0.7, -1.2},
          south_position = {0.7, -1.2},
          west_position = {0.7, -1.2},
          starting_vertical_speed = 0.08,
          starting_frame_deviation = 60
        }
      }
    }
end

data:extend(
{
  {
    type = "item",
    name = "oil-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "smelting-machine",
    order = "b[steela-furnace]",
    place_result = "oil-steel-furnace",
    stack_size = 50
  },
  util.merge
  {
    data.raw.furnace["steel-furnace"],
    {
      name = "oil-steel-furnace",
      minable = {result = "oil-steel-furnace"},
    }
  },
  {
    type = "recipe",
    name = "oil-steel-furnace",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-steel-furnace",
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
      },

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
data.raw.furnace["oil-steel-furnace"].energy_source = fluid_energy_source()


  if settings.startup["bobmods-plates-convert-recipes"] and settings.startup["bobmods-plates-convert-recipes"].value == true then
data:extend(
{
  {
    type = "recipe",
    name = "steel-furnace-from-oil-steel-furnace",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"oil-steel-furnace", 1},
    },
    results =
    {
      {"steel-furnace", 1},
      {"pipe", 2},
    },
    main_product = "steel-furnace",
    allow_as_intermediate = false,
  },
}
)

    bobmods.lib.tech.add_recipe_unlock("oil-steel-furnace", "steel-furnace-from-oil-steel-furnace")
    if data.raw["item-subgroup"]["bob-base-smelting-machine-convert"] then
      data.raw.recipe["steel-furnace-from-oil-steel-furnace"].subgroup = "bob-base-smelting-machine-convert"
    end
  end

if data.raw["assembling-machine"]["mixing-steel-furnace"] then
data:extend({
  {
    type = "item",
    name = "oil-mixing-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "bob-smelting-machine",
    order = "b[mixing-furnace-3]",
    place_result = "oil-mixing-steel-furnace",
    stack_size = 50
  },
  util.merge
  {
    data.raw["assembling-machine"]["mixing-steel-furnace"],
    {
      name = "oil-mixing-steel-furnace",
      minable = {result = "oil-mixing-steel-furnace"},
    }
  },
  {
    type = "recipe",
    name = "oil-mixing-steel-furnace",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"mixing-steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-mixing-steel-furnace",
  },
  {
    type = "technology",
    name = "oil-mixing-steel-furnace",
    icon_size = 128,
    icons =
    {
      {
        icon = "__base__/graphics/technology/advanced-material-processing.png",
        icon_size = 128,
      },
      {
        icon = "__bobassembly__/graphics/icons/technology/alloy-processing.png",
        icon_size = 128,
        scale = 0.5,
        shift = {-32, -32}
      }
    },
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
data.raw["assembling-machine"]["oil-mixing-steel-furnace"].energy_source = fluid_energy_source()

  if settings.startup["bobmods-plates-convert-recipes"] and settings.startup["bobmods-plates-convert-recipes"].value == true then
data:extend(
{
  {
    type = "recipe",
    name = "mixing-steel-furnace-from-oil-mixing-steel-furnace",
    subgroup = "bob-smelting-machine-convert",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"oil-mixing-steel-furnace", 1},
    },
    results =
    {
      {"mixing-steel-furnace", 1},
      {"pipe", 2},
    },
    main_product = "mixing-steel-furnace",
    allow_as_intermediate = false,
  },

  {
    type = "recipe",
    name = "oil-mixing-steel-furnace-from-oil-steel-furnace",
    subgroup = "bob-smelting-machine-convert",
    energy_required = 0.1,
    enabled = false,
    ingredients =
    {
      {"oil-steel-furnace", 1},
      {"pipe", 5},
    },
    result = "oil-mixing-steel-furnace",
  },
  {
    type = "recipe",
    name = "oil-steel-furnace-from-oil-mixing-steel-furnace",
    subgroup = "bob-base-smelting-machine-convert",
    energy_required = 0.1,
    enabled = false,
    ingredients =
    {
      {"oil-mixing-steel-furnace", 1},
    },
    results =
    {
      {"oil-steel-furnace", 1},
      {"pipe", 5},
    },
    main_product = "oil-steel-furnace",
    allow_as_intermediate = false,
  },
}
)

    bobmods.lib.tech.add_recipe_unlock("oil-mixing-steel-furnace", "mixing-steel-furnace-from-oil-mixing-steel-furnace")
    bobmods.lib.tech.add_recipe_unlock("oil-mixing-steel-furnace", "oil-mixing-steel-furnace-from-oil-steel-furnace")
    bobmods.lib.tech.add_recipe_unlock("oil-mixing-steel-furnace", "oil-steel-furnace-from-oil-mixing-steel-furnace")
  end
end

if data.raw["assembling-machine"]["chemical-steel-furnace"] then
data:extend({
  {
    type = "item",
    name = "oil-chemical-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "bob-smelting-machine",
    order = "b[chemical-boiler-3]",
    place_result = "oil-chemical-steel-furnace",
    stack_size = 50
  },
  util.merge
  {
    data.raw["assembling-machine"]["chemical-steel-furnace"],
    {
      name = "oil-chemical-steel-furnace",
      minable = {result = "oil-chemical-steel-furnace"},
    }
  },
  {
    type = "recipe",
    name = "oil-chemical-steel-furnace",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"chemical-steel-furnace", 1},
      {"pipe", 2},
    },
    result = "oil-chemical-steel-furnace",
  },
  {
    type = "technology",
    name = "oil-chemical-steel-furnace",
    icon_size = 128,
    icons =
    {
      {
        icon = "__base__/graphics/technology/advanced-material-processing.png",
        icon_size = 128,
      },
      {
        icon = "__bobassembly__/graphics/icons/technology/chemistry.png",
        icon_size = 64,
        shift = {-32, -32}
      }
    },
    prerequisites =
    {
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
data.raw["assembling-machine"]["oil-chemical-steel-furnace"].energy_source = fluid_energy_source()

  if settings.startup["bobmods-plates-convert-recipes"] and settings.startup["bobmods-plates-convert-recipes"].value == true then
data:extend(
{
  {
    type = "recipe",
    name = "chemical-steel-furnace-from-oil-chemical-steel-furnace",
    subgroup = "bob-smelting-machine-convert",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"oil-chemical-steel-furnace", 1},
    },
    results =
    {
      {"chemical-steel-furnace", 1},
      {"pipe", 2},
    },
    main_product = "chemical-steel-furnace",
    allow_as_intermediate = false,
  },

  {
    type = "recipe",
    name = "oil-chemical-steel-furnace-from-oil-steel-furnace",
    subgroup = "bob-smelting-machine-convert",
    energy_required = 0.1,
    enabled = false,
    ingredients =
    {
      {"oil-steel-furnace", 1},
      {"pipe", 5},
    },
    result = "oil-chemical-steel-furnace",
  },
  {
    type = "recipe",
    name = "oil-steel-furnace-from-oil-chemical-steel-furnace",
    subgroup = "bob-base-smelting-machine-convert",
    energy_required = 0.1,
    enabled = false,
    ingredients =
    {
      {"oil-chemical-steel-furnace", 1},
    },
    results =
    {
      {"oil-steel-furnace", 1},
      {"pipe", 5},
    },
    main_product = "oil-steel-furnace",
    allow_as_intermediate = false,
  },
}
)

    bobmods.lib.tech.add_recipe_unlock("oil-chemical-steel-furnace", "chemical-steel-furnace-from-oil-chemical-steel-furnace")
    bobmods.lib.tech.add_recipe_unlock("oil-chemical-steel-furnace", "oil-chemical-steel-furnace-from-oil-steel-furnace")
    bobmods.lib.tech.add_recipe_unlock("oil-chemical-steel-furnace", "oil-steel-furnace-from-oil-chemical-steel-furnace")
  end

if data.raw.technology["chemical-steel-furnace"] then
  bobmods.lib.tech.add_prerequisite("oil-chemical-steel-furnace", "chemical-steel-furnace")
else
  bobmods.lib.tech.add_prerequisite("oil-chemical-steel-furnace", "chemical-processing-2")
end

end
end
