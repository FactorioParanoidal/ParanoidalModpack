-- создание манипуляторов
if bobmods.logistics then
  data.raw.recipe["steam-inserter"].enabled = false
  data.raw.recipe["steam-inserter"].energy_required = 1
else
data:extend(
{
  {
    type = "recipe",
    name = "steam-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"burner-inserter", 1},
      {"pipe", 1}
    },
    result = "steam-inserter",
    requester_paste_multiplier = 4
  },
}
)
end

data:extend(
{
  {
    type = "recipe",
    name = "corner-steam-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"burner-inserter", 1},
      {"pipe", 1}
    },
    result = "corner-steam-inserter",
    requester_paste_multiplier = 4
  },
}
)

-- переоборудование манипуляторов
data:extend(
{
  {
    type = "recipe",
    name = "straight-corner-steam-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"steam-inserter", 1},
    },
    result = "corner-steam-inserter",
    requester_paste_multiplier = 4
  },
}
)

data:extend(
{
  {
    type = "recipe",
    name = "corner-straight-steam-inserter",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"corner-steam-inserter", 1},
    },
    result = "steam-inserter",
    requester_paste_multiplier = 4
  },
}
)