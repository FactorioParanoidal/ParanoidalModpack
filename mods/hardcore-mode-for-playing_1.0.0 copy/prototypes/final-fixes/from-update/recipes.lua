
data:extend({
	{
		type = "recipe",
		name = "used-up-uranium-fuel-cell",
		icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "uranium-fuel-cell", amount = 1 } },
		result = "used-up-uranium-fuel-cell",
		result_count = 1,
	},
})
data:extend({
	{
		type = "recipe",
		name = "used-up-thorium-fuel-cell",
		icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "thorium-fuel-cell", amount = 1 } },
		result = "used-up-thorium-fuel-cell",
		result_count = 1,
	},
})
data:extend({
	{
		type = "recipe",
		name = "used-up-deuterium-fuel-cell",
		icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "deuterium-fuel-cell", amount = 1 } },
		result = "used-up-deuterium-fuel-cell",
		result_count = 1,
	},
})

data:extend({
	{
		type = "recipe",
		name = "used-up-RITEG-1",
		icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "RITEG-1", amount = 1 } },
		result = "used-up-RITEG-1",
		result_count = 1,
	},
})

data:extend({
	{
		type = "recipe",
		name = "CW-used-air-filter",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-cleaning.png",
		icon_size = 32,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[CW-used-air-filter]",
		ingredients = { { type = "item", name = "CW-air-filter", amount = 1 } },
		result = "CW-used-air-filter",
		result_count = 1,
	},
})

data:extend({
	{
		type = "recipe",
		name = "used-up-advanced-tritium-breeder-fuel-cell",
		icon = "__True-Nukes__/graphics/tritium-extraction.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "advanced-tritium-breeder-fuel-cell", amount = 1 } },
		result = "used-up-advanced-tritium-breeder-fuel-cell",
		result_count = 1,
	},
})

local function disableRecipe(recipe_name)
	if data.raw["recipe"][recipe_name] then
		data.raw["recipe"][recipe_name].enabled = false
		if data.raw["recipe"][recipe_name].normal then
			data.raw["recipe"][recipe_name].normal.enabled = false
		end
		if data.raw["recipe"][recipe_name].expensive then
			data.raw["recipe"][recipe_name].expensive.enabled = false
		end
	end
end

local function disableRecipes()
	disableRecipe("mining-drill-bit-mk0")
	disableRecipe("angelsore1-crushed-hand")
	disableRecipe("angelsore3-crushed-hand")
	disableRecipe("angels-rod-iron-plate")
end

disableRecipes()
