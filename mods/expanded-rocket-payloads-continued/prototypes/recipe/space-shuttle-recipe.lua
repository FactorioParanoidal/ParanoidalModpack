--recipes for normal, telescope and mining shuttle. Someday I will rename spy shuttle to telescope shuttle in the mod files.

data:extend({
  {
    type = "recipe",
    name = "space-shuttle",
    category = "satellite-crafting",
    energy_required = 480,
    subgroup = "Space-Shuttles",
    enabled = false,
    ingredients =
    {
      { type = "item", name = "satellite-thruster", amount = 20 },
      { type = "item", name = "shuttle-hull",       amount = 1 },
      { type = "item", name = "space-lab-payload",  amount = 1 },
    },
    results = { { type = "item", name = "space-shuttle", amount = 1 } },
  },
  {
    type = "recipe",
    name = "spy-shuttle",
    category = "satellite-crafting",
    energy_required = 480,
    enabled = false,
    subgroup = "Space-Shuttles",
    ingredients =
    {
      { type = "item", name = "satellite-thruster",   amount = 20 },
      { type = "item", name = "shuttle-hull",         amount = 1 },
      { type = "item", name = "telescope-components", amount = 3 },
    },
    results = { { type = "item", name = "spy-shuttle", amount = 1 } },
  },
  {
    type = "recipe",
    name = "mining-shuttle",
    category = "satellite-crafting",
    energy_required = 480,
    enabled = false,
    subgroup = "Space-Shuttles",
    ingredients =
    {
      { type = "item", name = "satellite-thruster",            amount = 30 },
      { type = "item", name = "autonomous-space-mining-drone", amount = 5 },
      { type = "item", name = "shuttle-hull",                  amount = 1 },
    },
    results = { { type = "item", name = "mining-shuttle", amount = 1 } }
  }
})
