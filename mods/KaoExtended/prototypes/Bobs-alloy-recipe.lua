data:extend({

	{
		type = "recipe",
		name = "bronze-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 3 },
			{ type = "item", name = "bob-tin-plate", amount = 2 },
		},
		results = {
			{ type = "item", name = "bob-bronze-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "angel-solder-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "bob-tin-plate", amount = 5 },
			{ type = "item", name = "bob-lead-plate", amount = 4 },
		},
		results = {
			{ type = "item", name = "bob-solder", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-brass-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 3 },
			{ type = "item", name = "bob-zinc-plate", amount = 2 },
		},
		results = {
			{ type = "item", name = "bob-brass-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "copper-tungsten-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 2 },
			{ type = "item", name = "bob-powdered-tungsten", amount = 3 },
		},
		results = {
			{ type = "item", name = "bob-copper-tungsten-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-tungsten-carbide-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 25.6,
		ingredients = {
			{ type = "item", name = "bob-carbon", amount = 1 },
			{ type = "item", name = "bob-tungsten-oxide", amount = 1 },
		},
		results = {
			{ type = "item", name = "bob-tungsten-carbide", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-tungsten-carbide-2x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 25.6,
		ingredients = {
			{ type = "item", name = "bob-carbon", amount = 1 },
			{ type = "item", name = "bob-powdered-tungsten", amount = 1 },
		},
		results = {
			{ type = "item", name = "bob-tungsten-carbide", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "gunmetal-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 8 },
			{ type = "item", name = "bob-tin-plate", amount = 1 },
			{ type = "item", name = "bob-zinc-plate", amount = 1 },
		},
		results = {
			{ type = "item", name = "bob-gunmetal-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-invar-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "bob-nickel-plate", amount = 2 },
		},
		results = {
			{ type = "item", name = "bob-invar-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "nitinol-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "bob-nickel-plate", amount = 3 },
			{ type = "item", name = "bob-titanium-plate", amount = 2 },
		},
		results = {
			{ type = "item", name = "bob-nitinol-alloy", amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-cobalt-steel-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 14 },
			{ type = "item", name = "bob-cobalt-plate", amount = 1 },
		},
		results = { { type = "item", name = "bob-cobalt-steel-alloy", amount = 1 } },
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-cobalt-steel-alloy-x",
		enabled = false,
		hidden = false,
		category = "bob-mixing-furnace",
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 14 },
			{ type = "item", name = "bob-cobalt-plate", amount = 1 },
		},
		results = { { type = "item", name = "bob-cobalt-steel-alloy", amount = 1 } },
		allow_decomposition = false,
	},
	--[[

{
      type = "recipe",
      name = "solder-x",
      category = "bob-mixing-furnace",
      energy_required = 10,
      enabled = false,
	  hidden = false,
      ingredients = {
        { type = "item", name = "bob-solder-alloy", amount = 4},
        { type = "item", name = "bob-resin", amount = 2},
      },
      results ={{type="item", name= "bob-solder", amount = 1}},
      allow_decomposition = false,
    },
  ]]
	--

	{
		type = "recipe",
		name = "bob-nickel-electrolysis-x",
		icons = {
			{
				icon = "__bobplates__/graphics/icons/plate/nickel-plate.png",
				icon_size = 32,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobores__/graphics/icons/nickel-ore.png",
				icon_size = 32,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-nickel]-d",
		category = "angels-petrochem-electrolyser",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "item", name = "bob-nickel-ore", amount = 10 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "item", name = "bob-nickel-plate", amount = 1 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 20 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-zinc-electrolysis-x",
		icons = {
			{
				icon = "__bobplates__/graphics/icons/plate/zinc-plate.png",
				icon_size = 32,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobores__/graphics/icons/zinc-ore.png",
				icon_size = 32,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "angels-petrochem-electrolyser",
		enabled = false,
		energy_required = 14,
		ingredients = {
			{ type = "item", name = "bob-zinc-ore", amount = 10 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "item", name = "bob-zinc-plate", amount = 1 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 25 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "cobalat-electrolysis-x",
		icons = {
			{
				icon = "__bobplates__/graphics/icons/plate/cobalt-plate.png",
				icon_size = 32,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobores__/graphics/icons/cobalt-ore.png",
				icon_size = 32,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "angels-petrochem-electrolyser",
		enabled = false,
		energy_required = 17,
		ingredients = {
			{ type = "item", name = "bob-cobalt-ore", amount = 14 },
			{ type = "item", name = "angels-electrode", amount = 1 },
			{ type = "fluid", name = "angels-water-purified", amount = 100 },
		},
		results = {
			{ type = "item", name = "bob-cobalt-plate", amount = 1 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 25 },
			{ type = "fluid", name = "angels-gas-hydrogen", amount = 35 },
			{ type = "item", name = "angels-slag", amount = 8 },
			{ type = "item", name = "angels-electrode-used", amount = 1, catalyst_amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "bob-titanium-electrolysis-x",
		icons = {
			{
				icon = "__bobplates__/graphics/icons/plate/titanium-plate.png",
				icon_size = 32,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobores__/graphics/icons/rutile-ore.png",
				icon_size = 32,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "angels-petrochem-electrolyser",
		enabled = false,
		energy_required = 22,
		ingredients = {
			{ type = "item", name = "bob-rutile-ore", amount = 14 },
			{ type = "item", name = "angels-electrode", amount = 1 },
			{ type = "fluid", name = "angels-water-purified", amount = 100 },
		},
		results = {
			{ type = "item", name = "bob-titanium-plate", amount = 1 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 30 },
			{ type = "fluid", name = "angels-gas-hydrogen", amount = 40 },
			{ type = "item", name = "angels-slag", amount = 9 },
			{ type = "item", name = "angels-electrode-used", amount = 1, catalyst_amount = 1 },
		},
		allow_decomposition = false,
	},
})

bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bronze-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-brass-smelting-1", "bob-brass-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-tungsten-smelting-1", "copper-tungsten-alloy-x")
bobmods.lib.tech.add_recipe_unlock("bob-tungsten-alloy-processing", "bob-tungsten-carbide-x")
bobmods.lib.tech.add_recipe_unlock("bob-tungsten-alloy-processing", "bob-tungsten-carbide-2x")
bobmods.lib.tech.add_recipe_unlock("angels-gunmetal-smelting-1", "gunmetal-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-invar-smelting-1", "bob-invar-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-nitinol-smelting-1", "nitinol-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-cobalt-steel-smelting-1", "bob-cobalt-steel-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-nickel-smelting-1", "bob-nickel-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-zinc-smelting-1", "bob-zinc-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-cobalt-smelting-1", "cobalat-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-titanium-smelting-1", "bob-titanium-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-solder-smelting-1", "angel-solder-alloy-x")
