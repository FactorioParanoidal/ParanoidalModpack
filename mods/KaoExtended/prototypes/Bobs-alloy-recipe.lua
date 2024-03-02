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
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "nickel-plate", amount = 2 },
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
  ]]
	--

	{
		type = "recipe",
		name = "nickel-electrolysis-x",
		icons = {
			{
				icon = "__bobicons__/graphics/icons/plate/nickel-plate-128.png",
				icon_size = 128,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobicons__/graphics/icons/ores/nickel-ore/nickel-ore-1-64.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-nickel]-d",
		category = "petrochem-electrolyser",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "item", name = "nickel-ore", amount = 10 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "item", name = "nickel-plate", amount = 1 },
			{ type = "fluid", name = "gas-oxygen", amount = 20 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "zinc-electrolysis-x",
		icons = {
			{
				icon = "__bobicons__/graphics/icons/plate/zinc-plate-128.png",
				icon_size = 128,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobicons__/graphics/icons/ores/zinc-ore/zinc-ore-1-64.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "petrochem-electrolyser",
		enabled = false,
		energy_required = 14,
		ingredients = {
			{ type = "item", name = "zinc-ore", amount = 10 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "item", name = "zinc-plate", amount = 1 },
			{ type = "fluid", name = "gas-oxygen", amount = 25 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "cobalat-electrolysis-x",
		icons = {
			{
				icon = "__bobicons__/graphics/icons/plate/cobalt-plate-128.png",
				icon_size = 128,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobicons__/graphics/icons/ores/cobalt-ore-64.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "petrochem-electrolyser",
		enabled = false,
		energy_required = 17,
		ingredients = {
			{ type = "item", name = "cobalt-ore", amount = 14 },
			{ type = "item", name = "angels-electrode", amount = 1 },
			{ type = "fluid", name = "water-purified", amount = 100 },
		},
		results = {
			{ type = "item", name = "cobalt-plate", amount = 1 },
			{ type = "fluid", name = "gas-oxygen", amount = 25 },
			{ type = "fluid", name = "gas-hydrogen", amount = 35 },
			{ type = "item", name = "slag", amount = 8 },
			{ type = "item", name = "angels-electrode-used", amount = 1, catalyst_amount = 1 },
		},
		allow_decomposition = false,
	},

	{
		type = "recipe",
		name = "titanium-electrolysis-x",
		icons = {
			{
				icon = "__bobicons__/graphics/icons/plate/titanium-plate-128.png",
				icon_size = 128,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobicons__/graphics/icons/ores/rutile-ore-64.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		subgroup = "angels-smelting",
		order = "f[ingot-zinc]-d",
		category = "petrochem-electrolyser",
		enabled = false,
		energy_required = 22,
		ingredients = {
			{ type = "item", name = "rutile-ore", amount = 14 },
			{ type = "item", name = "angels-electrode", amount = 1 },
			{ type = "fluid", name = "water-purified", amount = 100 },
		},
		results = {
			{ type = "item", name = "titanium-plate", amount = 1 },
			{ type = "fluid", name = "gas-oxygen", amount = 30 },
			{ type = "fluid", name = "gas-hydrogen", amount = 40 },
			{ type = "item", name = "slag", amount = 9 },
			{ type = "item", name = "angels-electrode-used", amount = 1, catalyst_amount = 1 },
		},
		allow_decomposition = false,
	},
})

bobmods.lib.tech.add_recipe_unlock("tungsten-alloy-processing", "tungsten-carbide-x")
bobmods.lib.tech.add_recipe_unlock("tungsten-alloy-processing", "tungsten-carbide-2x")
bobmods.lib.tech.add_recipe_unlock("angels-nickel-smelting-1", "nickel-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-zinc-smelting-1", "zinc-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-cobalt-smelting-1", "cobalat-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-titanium-smelting-1", "titanium-electrolysis-x")
