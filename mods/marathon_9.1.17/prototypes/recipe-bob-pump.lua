data:extend(
{
  {
    type = "recipe",
    name = "bob-pump-2",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {"pump", 2},
      {"aluminium-plate", 10},
      {"bronze-pipe", 6},
    },
    result= "bob-pump-2"
  },
  {
    type = "recipe",
    name = "bob-pump-3",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {"bob-pump-2", 2},
      {"titanium-plate", 10},
      {"brass-pipe", 6},
    },
    result= "bob-pump-3"
  },
  {
    type = "recipe",
    name = "bob-pump-4",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {"bob-pump-3", 2},
      {"nitinol-alloy", 10},
      {"copper-tungsten-pipe", 6},
    },
    result= "bob-pump-4"
  },
}
)