--recipes to support the addition of autonomus fabrication including the entity, shuttle and fabricator recipes.

local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "recipe-category",
    name = "auto-fabricator"
  },
  {
    type = "recipe",
    name = "iron-delivery",
    enabled = false,
    auto_recycle = false,
    ingredients = {},
    results = { { type = "item", name = "iron-plate", amount = 100 } },
    energy_required = 2,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "copper-delivery",
    enabled = false,
    ingredients = {},
    auto_recycle = false,
    results = { { type = "item", name = "copper-plate", amount = 100 } },
    energy_required = 2,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "steel-delivery",
    enabled = false,
    ingredients = {},
    auto_recycle = false,
    results = { { type = "item", name = "steel-plate", amount = 100 } },
    energy_required = 4,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "stone-delivery",
    enabled = false,
    auto_recycle = false,
    ingredients = {},
    results = { { type = "item", name = "stone-brick", amount = 100 } },
    energy_required = 2,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "uranium-delivery",
    enabled = false,
    auto_recycle = false,
    ingredients = {},
    results = { { type = "item", name = "uranium-ore", amount = 50 } },
    energy_required = 2,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "coal-delivery",
    enabled = false,
    auto_recycle = false,
    ingredients = {},
    results = { { type = "item", name = "coal", amount = 50 } },
    energy_required = 2,
    category = "auto-fabricator",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "ground-auto-fabricator",
    auto_recycle = false,
    enabled = false,
    energy_required = 1000,
    ingredients =
    {
      { type = "item", name = "ground-fabricator-component", amount = 4 },
    },
    results = { { type = "item", name = "ground-auto-fabricator", amount = 1 } },
    icon = "__expanded-rocket-payloads-continued__/graphic/auto-fabricator-32.png",
    icon_size = 32,
    subgroup = "buildings",
    category = "satellite-crafting",
    order = "a"
  },
  {
    type = "recipe",
    name = "orbital-fabricator-component",
    energy_required = 1500,
    enabled = false,
    auto_recycle = false,
    ingredients =
        modutils.select(
          {
            { type = "item", name = "advanced-assembler",            amount = 100 },
            { type = "item", name = "autonomous-space-mining-drone", amount = 10 },
            { type = "item", name = "centrifuge",                    amount = 250 },
            { type = "item", name = "chemical-plant",                amount = 100 },
            { type = "item", name = "electric-furnace",              amount = 500 },
            { type = "item", name = "oil-refinery",                  amount = 50 },
            { type = "item", name = "satellite-bus",                 amount = 200 },
            { type = "item", name = "satellite-communications",      amount = 500 },
            { type = "item", name = "satellite-flight-computer",     amount = 250 },
            { type = "item", name = "bulk-inserter",                 amount = 500 },
          },
          nil,
          {
            { type = "item", name = modutils.electromagnetic_plant, amount = 100 },
            { type = "item", name = modutils.cryogenic_plant,       amount = 100 },
            { type = "item", name = modutils.foundry,               amount = 200 },
          }),
    results = { { type = "item", name = "orbital-fabricator-component", amount = 1 } },
    category = "satellite-crafting",
    subgroup = "space-mining",
  },
  {
    type = "recipe",
    name = "fabricator-shuttle",
    auto_recycle = false,
    category = "satellite-crafting",
    energy_required = 800,
    enabled = false,
    subgroup = "Space-Shuttles",
    ingredients =
    {
      { type = "item", name = "orbital-fabricator-component", amount = 1 },
      { type = "item", name = "satellite-thruster",           amount = 50 },
      { type = "item", name = "shuttle-hull",                 amount = 1 },
    },
    results = { { type = "item", name = "fabricator-shuttle", amount = 1 } },
  },
  {
    type = "recipe",
    name = "refurbish-fabricator-shuttle",
    energy_required = 800,
    enabled = false,
    auto_recycle = false,
    ingredients =
    {
      { type = "fluid", name = "water",                        amount = 20000 },
      { type = "item",  name = "landed-fabricator-shuttle",    amount = 1 },
      { type = "item",  name = "orbital-fabricator-component", amount = 1 },
      { type = "item",  name = "rocket-fuel",                  amount = 2000 },
      { type = "item",  name = "stone-brick",                  amount = 5000 },
    },
    results =
    {
      { type = "item", name = "fabricator-shuttle",          amount = 1 },
      { type = "item", name = "ground-fabricator-component", amount = 1 },
    },
    icon = "__expanded-rocket-payloads-continued__/graphic/landed-fabricator-shuttle-32.png",
    icon_size = 32,
    subgroup = "shuttle-processies",
    order = "b",
    category = "satellite-crafting",
  },
})

if mods["space-age"] then
  data:extend({

    {
      type = "recipe",
      name = "tungsten-plate-delivery",
      enabled = false,
      auto_recycle = false,
      ingredients = {},
      results = { { type = "item", name = "tungsten-plate", amount = 100 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

    {
      type = "recipe",
      name = "tungsten-carbide-delivery",
      auto_recycle = false,
      enabled = false,
      ingredients = {},
      results = { { type = "item", name = "tungsten-carbide", amount = 100 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

    {
      type = "recipe",
      name = "calcite-delivery",
      auto_recycle = false,
      enabled = false,
      ingredients = {},
      results = { { type = "item", name = "calcite", amount = 50 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

    {
      type = "recipe",
      name = "holmium-ore-delivery",
      auto_recycle = false,
      enabled = false,
      ingredients = {},
      results = { { type = "item", name = "holmium-ore", amount = 100 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

    {
      type = "recipe",
      name = "carbon-fiber-delivery",
      auto_recycle = false,
      enabled = false,
      ingredients = {},
      results = { { type = "item", name = "carbon-fiber", amount = 100 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

    {
      type = "recipe",
      name = "lithium-plate-delivery",
      auto_recycle = false,
      enabled = false,
      ingredients = {},
      results = { { type = "item", name = "lithium-plate", amount = 100 } },
      energy_required = 2,
      category = "auto-fabricator",
      subgroup = "building-recipies",
    },

  })
end
