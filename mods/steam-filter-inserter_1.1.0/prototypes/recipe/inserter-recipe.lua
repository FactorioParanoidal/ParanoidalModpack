-- создание манипуляторов
data:extend(
{
  {
    type = "recipe",
    name = "steam-filter-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"burner-filter-inserter", 1},
      {"pipe", 1}
    },
    result = "steam-filter-inserter",
    requester_paste_multiplier = 4
  },
}
)

data:extend(
{
  {
    type = "recipe",
    name = "corner-steam-filter-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"burner-filter-inserter", 1},
      {"pipe", 1}
    },
    result = "corner-steam-filter-inserter",
    requester_paste_multiplier = 4
  },
}
)

-- переоборудование манипуляторов
data:extend(
{
  {
    type = "recipe",
    name = "straight-corner-steam-filter-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"steam-filter-inserter", 1},
    },
    result = "corner-steam-filter-inserter",
    requester_paste_multiplier = 4
  },
}
)

data:extend(
{
  {
    type = "recipe",
    name = "corner-straight-steam-filter-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"corner-steam-filter-inserter", 1},
    },
    result = "steam-filter-inserter",
    requester_paste_multiplier = 4
  },
}
)
