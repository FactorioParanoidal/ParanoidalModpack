data:extend({
  {
    type = "recipe",
    name = "bronze-alloy-x",
    enabled = false,
    hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "copper-plate", amount = 3 },
      { type = "item", name = "tin-plate", amount = 2 },
    },
    results = {
      { type = "item", name = "bronze-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "brass-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "copper-plate", amount = 3 },
      { type = "item", name = "zinc-plate", amount = 2 },
    },
    results = {
      { type = "item", name = "brass-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "copper-tungsten-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "copper-plate", amount = 2 },
      { type = "item", name = "powdered-tungsten", amount = 3 },
    },
    results = {
      { type = "item", name = "copper-tungsten-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "tungsten-carbide-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 25.6,
    ingredients = {
      { type = "item", name = "carbon", amount = 1 },
      { type = "item", name = "tungsten-oxide", amount = 1 },
    },
    results = {
      { type = "item", name = "tungsten-carbide", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "tungsten-carbide-2x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 25.6,
    ingredients = {
      { type = "item", name = "carbon", amount = 1 },
      { type = "item", name = "powdered-tungsten", amount = 1 },
    },
    results = {
      { type = "item", name = "tungsten-carbide", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "gunmetal-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "copper-plate", amount = 8 },
      { type = "item", name = "tin-plate", amount = 1 },
      { type = "item", name = "zinc-plate", amount = 1 },
    },
    results = {
      { type = "item", name = "gunmetal-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },

  {
    type = "recipe",
    name = "invar-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "nickel-plate", amount = 2 },
      { type = "item", name = "iron-plate", amount = 3 },
    },
    results = {
      { type = "item", name = "invar-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "nitinol-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "nickel-plate", amount = 3 },
      { type = "item", name = "titanium-plate", amount = 2 },
    },
    results = {
      { type = "item", name = "nitinol-alloy", amount = 1 },
    },
    allow_decomposition = false,
  },

  {
    type = "recipe",
    name = "cobalt-steel-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "iron-plate", amount = 14 },
      { type = "item", name = "cobalt-plate", amount = 1 },
    },
    result = "cobalt-steel-alloy",
    result_count = 1,
    allow_decomposition = false,
  },
  
  {
    type = "recipe",
    name = "cobalt-steel-alloy-x",
    enabled = false,
	hidden = false,
    category = "mixing-furnace",
    energy_required = 32,
    ingredients = {
      { type = "item", name = "iron-plate", amount = 14 },
      { type = "item", name = "cobalt-plate", amount = 1 },
    },
    result = "cobalt-steel-alloy",
    result_count = 1,
    allow_decomposition = false,
  },
  --[[
	{
      type = "recipe",
      name = "solder-x",
      category = "mixing-furnace",
      energy_required = 10,
      enabled = false,
	  hidden = false,
      ingredients = {
        { "solder-alloy", 4 },
        { "resin", 2 },
      },
      result = "solder",
      result_count = 1,
      allow_decomposition = false,
    },
  ]]--
  
})

bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bronze-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-brass-smelting-1", "brass-alloy-x")
bobmods.lib.tech.add_recipe_unlock("alloy-smelting", "copper-tungsten-alloy-x")
bobmods.lib.tech.add_recipe_unlock("tungsten-alloy-processing", "tungsten-carbide-x")
bobmods.lib.tech.add_recipe_unlock("tungsten-alloy-processing", "tungsten-carbide-2x")
bobmods.lib.tech.add_recipe_unlock("angels-gunmetal-smelting-1", "gunmetal-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-invar-smelting-1", "invar-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-nitinol-smelting-1", "nitinol-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-cobalt-steel-smelting-1", "cobalt-steel-alloy-x")