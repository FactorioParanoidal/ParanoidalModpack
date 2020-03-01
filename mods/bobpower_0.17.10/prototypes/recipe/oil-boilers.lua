if settings.startup["bobmods-power-steam"].value == true then

data:extend(
{
  {
    type = "recipe",
    name = "oil-boiler",
    enabled = "false",
    ingredients =
    {
      {"boiler-2", 1},
      {"pipe", 2},
    },
    result = "oil-boiler",
  },

  {
    type = "recipe",
    name = "oil-boiler-2",
    enabled = "false",
    ingredients =
    {
      {"oil-boiler", 1},
      {"steel-plate", 5},
    },
    result = "oil-boiler-2",
  },

  {
    type = "recipe",
    name = "oil-boiler-3",
    enabled = "false",
    ingredients =
    {
      {"oil-boiler-2", 1},
      {"steel-plate", 5},
    },
    result = "oil-boiler-3",
  },

  {
    type = "recipe",
    name = "oil-boiler-4",
    enabled = "false",
    ingredients =
    {
      {"oil-boiler-3", 1},
      {"steel-plate", 5},
    },
    result = "oil-boiler-4",
  },
}
)

end

