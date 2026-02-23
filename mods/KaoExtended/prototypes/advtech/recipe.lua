local a = false
data:extend({
	{
		type = "recipe",
		name = "sci-component-1",
		category = "crafting",
		enabled = true,
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "stone", amount = 3},
			{ type = "item", name = "coal", amount = 2},
		},
		results ={{type="item", name= "sci-component-1", amount = 1}},
	},
	{
		type = "recipe",
		name = "sci-component-2",
		category = "crafting",
		enabled = false,
		energy_required = 7.5,
		ingredients = {
			{ type = "item", name = "sci-component-1", amount = 2},
			{ type = "item", name = "bob-lead-plate", amount = 12},
			{ type = "item", name = "bob-tin-plate", amount = 5},
			{ type = "item", name = "simple-io", amount = 1},
		},
		results ={{type="item", name= "sci-component-2", amount = 2}},
	},
	{
		type = "recipe",
		name = "sci-component-3",
		category = "crafting",
		enabled = false,
		energy_required = 15,
		ingredients = {
			{ type = "item", name = "sci-component-2", amount = 2},
			{ type = "item", name = "bob-silver-plate", amount = 14},
			{ type = "item", name = "bob-nickel-plate", amount = 7},
			{ type = "item", name = "bob-aluminium-plate", amount = 5},
			{ type = "item", name = "advsci-component-3", amount = 2},
		},
		results ={{type="item", name= "sci-component-3", amount = 2}},
	},
	{
		type = "recipe",
		name = "sci-component-4",
		category = "crafting",
		enabled = false,
		energy_required = 22,
		ingredients = {
			{ type = "item", name = "sci-component-1", amount = 10},
			{ type = "item", name = "sci-component-2", amount = 5},
			{ type = "item", name = "sci-component-3", amount = 2},

			{ type = "item", name = "bob-cobalt-steel-alloy", amount = 9},
			{ type = "item", name = "bob-invar-alloy", amount = 6},
			{ type = "item", name = "bob-gold-plate", amount = 10},
			{ type = "item", name = "bob-titanium-plate", amount = 12},
			{ type = "item", name = "bob-tungsten-plate", amount = 8},
		},
		results ={{type="item", name= "sci-component-4", amount = 2}},
	},
	{
		type = "recipe",
		name = "sci-component-m",
		category = "crafting",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "item", name = "sci-component-1", amount = 2},
			{ type = "item", name = "sci-component-2", amount = 2},
			{ type = "item", name = "steel-plate", amount = 5},
		},
		results ={{type="item", name= "sci-component-m", amount = 2}},
	},
	{
		type = "recipe",
		name = "sci-component-l",
		category = "crafting",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "item", name = "sci-component-1", amount = 3},
			{ type = "item", name = "sci-component-2", amount = 3},
			{ type = "item", name = "transport-belt", amount = 5},
			{ type = "item", name = "fast-transport-belt", amount = 5},
			{ type = "item", name = "express-transport-belt", amount = 5}, -- added at 017
		},
		results ={{type="item", name= "sci-component-l", amount = 2}},
	},
	{
		type = "recipe",
		name = "sci-component-5",
		category = "crafting",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "item", name = "sci-component-1", amount = 4},
			{ type = "item", name = "sci-component-2", amount = 4},
			{ type = "item", name = "assembling-machine-2", amount = 1},
			{ type = "item", name = "electric-engine-unit", amount = 4},
		},
		results ={{type="item", name= "sci-component-5", amount = 2}},
	},
	{
		type = "recipe",
		name = "advsci-component-3",
		category = "crafting",
		enabled = false,
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-bronze-alloy", amount = 1},
			{ type = "item", name = "bob-brass-alloy", amount = 1},
			{ type = "item", name = "bob-nickel-plate", amount = 2},
			{ type = "item", name = "bob-glass", amount = 2},
		},
		results ={{type="item", name= "advsci-component-3", amount = 1}},
	},
	{
		type = "recipe",
		name = "advsci-component-4",
		energy_required = 22,
		category = "crafting",
		enabled = false,
		ingredients = {
			{ type = "item", name = "bob-zinc-plate", amount = 7},
			{ type = "item", name = "bob-silver-plate", amount = 2},
			{ type = "item", name = "bob-gold-plate", amount = 3},
		},
		results ={{type="item", name= "advsci-component-4", amount = 1}},
	},
	{
		type = "recipe",
		name = "simple-io",
		category = "crafting",
		enabled = false,
		energy_required = 15,
		ingredients = {
			{ type = "item", name = "electronic-circuit", amount = 2},
			{ type = "item", name = "bob-basic-electronic-components", amount = 10},
			{ type = "item", name = "condensator", amount = 24},
			{ type = "item", name = "copper-cable", amount = 6},
			{ type = "item", name = "bob-solder", amount = 6},
		},
		results ={{type="item", name= "simple-io", amount = 1}},
	},
	{
		type = "recipe",
		name = "standart-io",
		category = "crafting",
		enabled = false,
		energy_required = 30,
		ingredients = {
			{ type = "item", name = "bob-basic-electronic-components", amount = 48},
			{ type = "item", name = "bob-electronic-components", amount = 18},
			{ type = "item", name = "condensator", amount = 20},
			{ type = "item", name = "condensator2", amount = 6},
			{ type = "item", name = "simple-io", amount = 3},
			{ type = "item", name = "bob-tinned-copper-cable", amount = 8},
			{ type = "item", name = "bob-solder", amount = 12},
		},
		results ={{type="item", name= "standart-io", amount = 1}},
	},
	{
		type = "recipe",
		name = "advanced-io",
		category = "crafting",
		enabled = false,
		energy_required = 45,
		ingredients = {
			{ type = "item", name = "bob-basic-electronic-components", amount = 20},
			{ type = "item", name = "bob-electronic-components", amount = 40},
			{ type = "item", name = "condensator2", amount = 16},
			{ type = "item", name = "bob-integrated-electronics", amount = 15},
			{ type = "item", name = "simple-io", amount = 6},
			{ type = "item", name = "standart-io", amount = 6},
			{ type = "item", name = "bob-insulated-cable", amount = 12},
			{ type = "item", name = "bob-solder", amount = 18},
		},
		results ={{type="item", name= "advanced-io", amount = 1}},
	},
	{
		type = "recipe",
		name = "predictive-io",
		category = "crafting",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{ type = "item", name = "bob-basic-electronic-components", amount = 28},
			{ type = "item", name = "bob-electronic-components", amount = 52},
			{ type = "item", name = "bob-integrated-electronics", amount = 24},
			{ type = "item", name = "bob-processing-electronics", amount = 4},
			{ type = "item", name = "condensator2", amount = 8},
			{ type = "item", name = "condensator3", amount = 14},
			{ type = "item", name = "simple-io", amount = 12},
			{ type = "item", name = "standart-io", amount = 10},
			{ type = "item", name = "advanced-io", amount = 8},
			{ type = "item", name = "bob-gilded-copper-cable", amount = 18},
			{ type = "item", name = "bob-solder", amount = 24},
		},
		results ={{type="item", name= "predictive-io", amount = 1}},
	},
	{
		type = "recipe",
		name = "intelligent-io",
		category = "crafting",
		enabled = false,
		energy_required = 75,
		ingredients = {
			{ type = "item", name = "bob-alien-artifact", amount = 1},
			{ type = "item", name = "bob-basic-electronic-components", amount = 36},
			{ type = "item", name = "bob-electronic-components", amount = 40},
			{ type = "item", name = "bob-integrated-electronics", amount = 32},
			{ type = "item", name = "bob-processing-electronics", amount = 16},
			{ type = "item", name = "condensator3", amount = 32},
			{ type = "item", name = "bob-speed-processor-3", amount = 8},
			{ type = "item", name = "bob-efficiency-processor-3", amount = 8},
			{ type = "item", name = "bob-productivity-processor-3", amount = 8},
			{ type = "item", name = "simple-io", amount = 16},
			{ type = "item", name = "standart-io", amount = 16},
			{ type = "item", name = "advanced-io", amount = 16},
			{ type = "item", name = "predictive-io", amount = 4},
			{ type = "item", name = "bob-gilded-copper-cable", amount = 40},
			{ type = "item", name = "bob-solder", amount = 30},
		},
		results ={{type="item", name= "intelligent-io", amount = 1}},
	},
	{
		type = "recipe",
		name = "condensator",
		category = "electronics",
		enabled = true,
		energy_required = 3,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 2},
			{ type = "item", name = "copper-cable", amount = 1},
		},
		results ={{type="item", name= "condensator", amount = 3}},
	},
	{
		type = "recipe",
		name = "condensator2",
		category = "electronics-with-fluid",
		enabled = false,
		energy_required = 6,
		ingredients = {
			{ type = "item", name = "condensator", amount = 2},
			{ type = "item", name = "bob-tinned-copper-cable", amount = 2},
			{ type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 10 },
		},
		results ={{type="item", name= "condensator2", amount = 2}},
	},
	{
		type = "recipe",
		name = "condensator3",
		category = "electronics-with-fluid",
		enabled = false,
		energy_required = 6,
		ingredients = {
			{ type = "item", name = "condensator2", amount = 1},
			{ type = "item", name = "bob-aluminium-plate", amount = 1},
			{ type = "item", name = "bob-resin", amount = 1},
		},
		results ={{type="item", name= "condensator3", amount = 1}},
	},
})

data:extend({
	{
		type = "recipe",
		name = "barrel-recycling",
		category = "smelting",
		enabled = true,
		hidden = true,
		energy_required = 5,
		ingredients = { { type = "item", name = "barrel", amount = 5} },
		results = { { type = "item", name = "steel-plate", amount = 4} },
	},
})

if
	data.raw.item["bob-alien-artifact"]
	and data.raw.item["bob-alien-artifact-blue"]
	and data.raw.item["bob-alien-artifact-orange"]
	and data.raw.item["bob-alien-artifact-purple"]
	and data.raw.item["bob-alien-artifact-yellow"]
	and data.raw.item["bob-alien-artifact-green"]
	and data.raw.item["bob-alien-artifact-red"]
then
	data:extend({

		{
			type = "recipe",
			name = "sci-component-o",
			category = "crafting",
			enabled = false,
			energy_required = 15,
			ingredients = {
				{ type = "item", name = "sci-component-1", amount = 4},
				{ type = "item", name = "sci-component-2", amount = 4},
				{ type = "item", name = "bob-alien-artifact", amount = 5},
				{ type = "item", name = "bob-alien-artifact-blue", amount = 2},
				{ type = "item", name = "bob-alien-artifact-orange", amount = 2},
				{ type = "item", name = "bob-alien-artifact-purple", amount = 2},
				{ type = "item", name = "bob-alien-artifact-yellow", amount = 2},
				{ type = "item", name = "bob-alien-artifact-green", amount = 2},
				{ type = "item", name = "bob-alien-artifact-red", amount = 2},
			},
			results ={{type="item", name= "sci-component-o", amount = 2}},
		},
	})
else
	data:extend({

		{
			type = "recipe",
			name = "sci-component-o",
			category = "crafting",
			enabled = false,
			energy_required = 12,
			ingredients = {
				{ type = "item", name = "sci-component-1", amount = 4},
				{ type = "item", name = "sci-component-2", amount = 4},
				{ type = "item", name = "bob-alien-artifact", amount = 10},
			},
			results ={{type="item", name= "sci-component-o", amount = 2}},
		},
	})
end
data:extend({
	--IRON GEAR CASTING
	{
		type = "recipe",
		name = "angels-iron-gear-wheel-stack-casting",
		category = "angels-strand-casting",
		subgroup = "angels-iron-casting",
		normal = {
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-iron", amount = 80 },
				{ type = "fluid", name = "water", amount = 40 },
			},
			results = { { type = "item", name = "angels-iron-gear-wheel-stack", amount = 2 } },
		},
		expensive = {
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-iron", amount = 100 },
				{ type = "fluid", name = "water", amount = 40 },
			},
			results = { { type = "item", name = "angels-iron-gear-wheel-stack", amount = 2 } },
		},
		icons = {
			{
				icon = "__KaoExtended__/graphics/smelting/iron-gear-wheel-stack.png",
				icon_size = 64,
			},
			{
				icon = "__KaoExtended__/graphics/num_1-64.png",
				icon_size = 64,
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "g",
	},
	{
		type = "recipe",
		name = "angels-iron-gear-wheel-stack-casting-fast",
		category = "angels-strand-casting",
		subgroup = "angels-iron-casting",
		normal = {
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-iron", amount = 140 },
				{ type = "fluid", name = "angels-liquid-coolant", amount = 40, maximum_temperature = 50 },
			},
			results = {
				{ type = "item", name = "angels-iron-gear-wheel-stack", amount = 4 },
				{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
			},
			main_product = "angels-iron-gear-wheel-stack",
		},
		expensive = {
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-iron", amount = 180 },
				{ type = "fluid", name = "angels-liquid-coolant", amount = 40, maximum_temperature = 50 },
			},
			results = {
				{ type = "item", name = "angels-iron-gear-wheel-stack", amount = 4 },
				{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
			},
			main_product = "angels-iron-gear-wheel-stack",
		},
		icons = {
			{
				icon = "__KaoExtended__/graphics/smelting/iron-gear-wheel-stack.png",
				icon_size = 64,
			},
			{
				icon = "__KaoExtended__/graphics/num_2-64.png",
				icon_size = 64,
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "h",
	},
	--STEEL GEAR CASTING
	{
		type = "recipe",
		name = "angels-steel-gear-wheel-stack-casting",
		category = "angels-strand-casting",
		subgroup = "angels-steel-casting",
		normal = {
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-steel", amount = 80 },
				{ type = "fluid", name = "water", amount = 40 },
			},
			results = { { type = "item", name = "angels-steel-gear-wheel-stack", amount = 2 } },
		},
		expensive = {
			enabled = false,
			energy_required = 4,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-steel", amount = 100 },
				{ type = "fluid", name = "water", amount = 40 },
			},
			results = { { type = "item", name = "angels-steel-gear-wheel-stack", amount = 2 } },
		},
		icons = {
			{
				icon = "__KaoExtended__/graphics/smelting/steel-gear-wheel-stack.png",
				icon_size = 64,
			},
			{
				icon = "__KaoExtended__/graphics/num_1-64.png",
				icon_size = 64,
				tint = { r = 0, g = 1, b = 0, a = 0.2 },
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "g",
	},
	{
		type = "recipe",
		name = "angels-steel-gear-wheel-stack-casting-fast",
		category = "angels-strand-casting",
		subgroup = "angels-steel-casting",
		normal = {
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-steel", amount = 140 },
				{ type = "fluid", name = "angels-liquid-coolant", amount = 40, maximum_temperature = 50 },
			},
			results = {
				{ type = "item", name = "angels-steel-gear-wheel-stack", amount = 4 },
				{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
			},
			main_product = "angels-steel-gear-wheel-stack",
		},
		expensive = {
			enabled = false,
			energy_required = 2,
			ingredients = {
				{ type = "fluid", name = "angels-liquid-molten-steel", amount = 180 },
				{ type = "fluid", name = "angels-liquid-coolant", amount = 40, maximum_temperature = 50 },
			},
			results = {
				{ type = "item", name = "angels-steel-gear-wheel-stack", amount = 4 },
				{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
			},
			main_product = "angels-steel-gear-wheel-stack",
		},
		icons = {
			{
				icon = "__KaoExtended__/graphics/smelting/steel-gear-wheel-stack.png",
				icon_size = 64,
			},
			{
				icon = "__KaoExtended__/graphics/num_2-64.png",
				icon_size = 64,
				tint = { r = 1, g = 1, b = 1, a = 0.8 },
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "h",
	},
	--GEAR STACK PROCESSING (converting)

	{
		type = "recipe",
		name = "angels-iron-gear-wheel-stack-converting",
		category = "advanced-crafting",
		subgroup = "angels-iron-casting",
		energy_required = 0.5,
		allow_decomposition = false,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-iron-gear-wheel-stack", amount = 1 },
		},
		results = {
			{ type = "item", name = "iron-gear-wheel", amount = 5 },
		},
		icons = {
			{
				icon = data.raw.item["iron-gear-wheel"].icon,
				icon_size = data.raw.item["iron-gear-wheel"].iconsize,
			},
			{
				icon = "__KaoExtended__/graphics/smelting/iron-gear-wheel-stack.png",
				icon_size = 64,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "j",
	},
	{
		type = "recipe",
		name = "angels-steel-gear-wheel-stack-converting",
		category = "advanced-crafting",
		subgroup = "angels-steel-casting",
		energy_required = 0.5,
		enabled = false,
		allow_decomposition = false,
		ingredients = {
			{ type = "item", name = "angels-steel-gear-wheel-stack", amount = 1 },
		},
		results = {
			{ type = "item", name = "bob-steel-gear-wheel", amount = 5 },
		},
		icons = {
			{
				icon = "__bobplates__/graphics/icons/steel-gear-wheel.png",
				icon_size = 32,
			},
			{
				icon = "__KaoExtended__/graphics/smelting/steel-gear-wheel-stack.png",
				icon_size = 64,
				scale = 0.2,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "kc",
	},
})
