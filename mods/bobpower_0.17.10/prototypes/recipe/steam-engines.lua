if settings.startup["bobmods-power-steam"].value == true then

data:extend(
{
  {
    type = "recipe",
    name = "steam-engine-2",
    energy_required = 50, --DrD
    normal =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine", 2},
        {"steel-plate", 5},
        {"pipe", 5},
        {"iron-gear-wheel", 5},
      },
      result = "steam-engine-2",
    },
    expensive =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine", 2},
        {"steel-plate", 25},
        {"pipe", 5},
        {"iron-gear-wheel", 10},
      },
      result = "steam-engine-2",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-3",
	energy_required = 40, --DrD
    normal =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-2", 2},
        {"pipe", 5},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
      },
      result = "steam-engine-3",
    },
    expensive =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-2", 2},
        {"pipe", 5},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "steam-engine-3",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-4",
	energy_required = 30, --DrD
    normal =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-3", 2},
        {"pipe", 5},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
      },
      result = "steam-engine-4",
    },
    expensive =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-3", 2},
        {"pipe", 5},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "steam-engine-4",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-5",
	energy_required = 20, --DrD
    normal =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-4", 2},
        {"pipe", 5},
        {"steel-plate", 5},
        {"iron-gear-wheel", 5},
      },
      result = "steam-engine-5",
    },
    expensive =
    {
      enabled = "false",
      ingredients =
      {
        {"steam-engine-4", 2},
        {"pipe", 5},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "steam-engine-5",
    }
  },
}
)

end
