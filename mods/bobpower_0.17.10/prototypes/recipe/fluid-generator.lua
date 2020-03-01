if settings.startup["bobmods-power-fluidgenerator"].value == true then

data:extend(
{
  {
    type = "recipe",
    name = "fluid-generator",
    normal =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"iron-gear-wheel", 8},
        {"steel-plate", 10},
        {"pipe", 5},
        {"electric-engine-unit", 4},
      },
      result = "fluid-generator"
    },
    expensive =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"iron-gear-wheel", 10},
        {"steel-plate", 50},
        {"pipe", 5},
        {"electric-engine-unit", 6},
      },
      result = "fluid-generator"
    }
  },

  {
    type = "recipe",
    name = "fluid-generator-2",
    normal =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator", 1},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
        {"electronic-circuit", 5},
      },
      result = "fluid-generator-2",
    },
    expensive =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator", 1},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
        {"electronic-circuit", 5},
      },
      result = "fluid-generator-2",
    }
  },

  {
    type = "recipe",
    name = "fluid-generator-3",
    normal =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator-2", 1},
        {"advanced-circuit", 5},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
      },
      result = "fluid-generator-3",
    },
    expensive =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator-2", 1},
        {"advanced-circuit", 10},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "fluid-generator-3",
    }
  },
}
)

if mods["bobrevamp"] and data.raw.fluid.hydrogen and data.raw.fluid.oxygen and data.raw.fluid.nitrogen then
data:extend(
{
  {
    type = "recipe",
    name = "hydrazine-generator",
    normal =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator-3", 1},
        {"processing-unit", 5},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
      },
      result = "hydrazine-generator",
    },
    expensive =
    {
      energy_required = 2,
      enabled = "false",
      ingredients =
      {
        {"fluid-generator-3", 1},
        {"processing-unit", 10},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "hydrazine-generator",
    }
  },
}
)
end

end
