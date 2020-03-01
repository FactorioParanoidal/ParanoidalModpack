if settings.startup["bobmods-power-steam"].value == true then

data:extend(
{
  {
    type = "recipe",
    name = "heat-exchanger",
    energy_required = 3,
    enabled = false,
    ingredients =
    {
      {"boiler-3", 1},
      {"heat-pipe", 4},
    },
    result = "heat-exchanger"
  },

  {
    type = "recipe",
    name = "heat-exchanger-2",
    enabled = "false",
    ingredients =
    {
      {"heat-exchanger", 1},
      {"steel-plate", 10},
    },
    result = "heat-exchanger-2",
  },

  {
    type = "recipe",
    name = "heat-exchanger-3",
    enabled = "false",
    ingredients =
    {
      {"heat-exchanger-2", 1},
      {"steel-plate", 10},
    },
    result = "heat-exchanger-3",
  },
}
)


end
