require("__automated-utility-protocol__.util.tree-recipe-util")
local function copy_salvaged_recipe(name, new_name)
	local result = flib.copy_prototype(data.raw["recipe"][name], new_name)
	result.ingredients = {}
	result.result = new_name
	if result.normal then
		result.normal = nil
	end
	if result.expensive then
		result.expensive = nil
	end
	return result
end

local coal_bi_bio_farm_recipe = flib.copy_prototype(data.raw["recipe"]["bi-bio-farm"], "coal-bi-bio-farm")

local function fixBiBioFarmIngredients(ingredients)
	table.insert(ingredients, {
		type = "item",
		name = "stone-furnace",
		amount = 5,
	})
	_table.each(ingredients, function(ingredient)
		if ingredient.name == "bi-bio-greenhouse" then
			ingredient.name = "coal-bi-bio-greenhouse"
		end
		if ingredient.name == "glass" then
			ingredient.name = "iron-plate"
		end
	end)
end
fixBiBioFarmIngredients(coal_bi_bio_farm_recipe.normal.ingredients)
fixBiBioFarmIngredients(coal_bi_bio_farm_recipe.expensive.ingredients)

local function fixBiBioFarmResult(recipeData)
	recipeData.result = "coal-bi-bio-farm"
end

fixBiBioFarmResult(coal_bi_bio_farm_recipe.normal)
fixBiBioFarmResult(coal_bi_bio_farm_recipe.expensive)

local coal_bi_bio_greenhouse_recipe =
	flib.copy_prototype(data.raw["recipe"]["bi-bio-greenhouse"], "coal-bi-bio-greenhouse")

local function fixBiBioGreenHouseIngredients(ingredients)
	table.insert(ingredients, {
		type = "item",
		name = "stone-furnace",
		amount = 1,
	})
	_table.each(ingredients, function(ingredient)
		if ingredient.name == "small-lamp" then
			ingredient.name = "deadlock-copper-lamp"
		end
	end)
end

local function fixBiBioGreenHouseResult(recipeData)
	recipeData.result = "coal-bi-bio-greenhouse"
end

fixBiBioGreenHouseIngredients(coal_bi_bio_greenhouse_recipe.normal.ingredients)
fixBiBioGreenHouseIngredients(coal_bi_bio_greenhouse_recipe.expensive.ingredients)
fixBiBioGreenHouseResult(coal_bi_bio_greenhouse_recipe.normal)
fixBiBioGreenHouseResult(coal_bi_bio_greenhouse_recipe.expensive)

-- скопипащенные рецепты.
data:extend({
	coal_bi_bio_farm_recipe,
	coal_bi_bio_greenhouse_recipe,
})

local salvaged_offsore_pump_0_recipe = copy_salvaged_recipe("offshore-pump-0", "salvaged-offshore-pump-0")

salvaged_offsore_pump_0_recipe.ingredients = {
	{
		type = "item",
		name = "stone",
		amount = 20,
	},
	{
		type = "item",
		name = "salvaged-iron-gear-wheel",
		amount = 8,
	},
	{
		type = "item",
		name = "bi-wood-pipe",
		amount = 3,
	},
}
data.raw["recipe"]["bi-wood-pipe"]["normal"].ingredients = { { "wood", 12 } }
data.raw["recipe"]["bi-wood-pipe"]["expensive"].ingredients = { { "wood", 16 } }
data.raw["recipe"]["bi-wood-pipe-to-ground"]["normal"].ingredients = { { "wood", 16 }, { "bi-wood-pipe", 5 } }
data.raw["recipe"]["bi-wood-pipe-to-ground"]["expensive"].ingredients = { { "wood", 20 }, { "bi-wood-pipe", 6 } }

local salvaged_mining_drill_recipe = copy_salvaged_recipe("burner-mining-drill", "salvaged-mining-drill")
salvaged_mining_drill_recipe.ingredients = {
	{
		type = "item",
		name = "stone",
		amount = 60,
	},
	{
		type = "item",
		name = "salvaged-iron-gear-wheel",
		amount = 16,
	},
	{
		type = "item",
		name = "salvaged-mining-drill-bit-mk0",
		amount = 2,
	},
	-- для жидкостей
	{
		type = "item",
		name = "bi-wood-pipe",
		amount = 6,
	},
}
local salvaged_ore_crusher_recipe = copy_salvaged_recipe("burner-ore-crusher", "salvaged-ore-crusher")
salvaged_ore_crusher_recipe.ingredients = {
	{
		type = "item",
		name = "stone",
		amount = 60,
	},
	{
		type = "item",
		name = "salvaged-iron-gear-wheel",
		amount = 16,
	},
	{
		type = "item",
		name = "salvaged-mining-drill-bit-mk0",
		amount = 4,
	},
	-- для жидкостей
	{
		type = "item",
		name = "bi-wood-pipe",
		amount = 6,
	},
}
--извлечённые рецепты
data:extend({
	copy_salvaged_recipe("mining-drill-bit-mk0", "salvaged-mining-drill-bit-mk0"),
	copy_salvaged_recipe("iron-gear-wheel", "salvaged-iron-gear-wheel"),
	copy_salvaged_recipe("burner-lab", "salvaged-lab"),
	copy_salvaged_recipe("burner-assembling-machine", "salvaged-assembling-machine"),
	salvaged_offsore_pump_0_recipe,
	salvaged_mining_drill_recipe,
	salvaged_ore_crusher_recipe,
	copy_salvaged_recipe("automation-science-pack", "salvaged-automation-science-pack"),
	copy_salvaged_recipe("accumulator", "salvaged-generator"),
})
data:extend({
	{
		type = "recipe",
		name = "basic-coal-production-wood",
		icons = {
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__base__/graphics/icons/fluid/water.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { -8, 8 },
			},
			{
				icon = "__base__/graphics/icons/coal.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { 0, 8 },
			},
		},
		ingredients = {
			{
				type = "fluid",
				name = "water",
				amount = 100,
			},
			{
				type = "item",
				name = "coal-seedling",
				amount = 4,
			},
			{
				type = "item",
				name = "coal",
				amount = 2,
			},
		},
		results = {
			{
				type = "item",
				name = "wood",
				amount = 9,
			},
			{
				type = "item",
				name = "coal-tree-seed",
				amount = 16,
			},
		},
		subgroup = "bio-bio-farm-fluid-1",
		category = "biofarm-mod-greenhouse",
		energy_required = 10,
		enabled = false,
	},
	{
		type = "recipe",
		name = "basic-coal-production-seedling",
		icons = {
			{
				icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/tree_seed.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__base__/graphics/icons/fluid/water.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { -8, 8 },
			},
			{
				icon = "__base__/graphics/icons/coal.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.25,
				shift = { 0, 8 },
			},
		},
		ingredients = {
			{
				type = "fluid",
				name = "water",
				amount = 100,
			},
			{
				type = "item",
				name = "coal-tree-seed",
				amount = 4,
			},
			{
				type = "item",
				name = "coal",
				amount = 2,
			},
		},
		results = {
			{
				type = "item",
				name = "coal-seedling",
				amount = 1,
			},
		},
		subgroup = "bio-bio-farm-fluid-1",
		category = "biofarm-mod-greenhouse",
		energy_required = 25,
		enabled = false,
	},
})

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
		name = "used-up-tritium-breeder-fuel-cell",
		icon = "__True-Nukes__/graphics/used-up-tritium-breeder-fuel-cell.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "r[used-up-uranium-fuel-cell]",
		ingredients = { { type = "item", name = "tritium-breeder-fuel-cell", amount = 1 } },
		result = "used-up-tritium-breeder-fuel-cell",
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
	if not data.raw["recipe"][recipe_name] then
		error("recipe " .. recipe_name .. " not found")
	end
	data.raw["recipe"][recipe_name].enabled = false
end

local function disableRecipes()
	disableRecipe("mining-drill-bit-mk0")
	disableRecipe("angelsore1-crushed-hand")
	disableRecipe("angelsore3-crushed-hand")
	disableRecipe("angels-rod-iron-plate")
end

disableRecipes()

local function addRecipeEffectsToTechnologies()
	local technologies = data.raw["technology"]
	local ore_crushing_technology = technologies["ore-crushing"]
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore5-crushed")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore6-crushed")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "iron-plate")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "copper-plate")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "lead-plate")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "tin-plate")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "glass-from-ore4")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore5-crushed-smelting")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore6-crushed-smelting")
	local steam_power_technology = technologies["steam-power"]
	if steam_power_technology then
		TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, createSteamRecipe().name)
		TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, "steam-assembling-machine")
		TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, "steam-mining-drill")
	end
	local logistic_0_technology = technologies["logistics-0"]
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(logistic_0_technology, "chute-miniloader")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["electricity"], "bob-burner-generator")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["nuclear-power"],
		"used-up-uranium-fuel-cell"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["nuclear-power"], "used-up-RITEG-1")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["mixed-oxide-fuel"],
		"used-up-thorium-fuel-cell"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["bob-nuclear-power-3"],
		"used-up-deuterium-fuel-cell"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["tritium-processing"],
		"used-up-tritium-breeder-fuel-cell"
	)
	--bob warfare mod восстанавливаем удалённые рецепты
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet-casing")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "magazine")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet-projectile")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["bob-bullets"],
		"uranium-bullet-projectile"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "uranium-bullet")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "shotgun-shell-casing")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["CW-air-filtering-1"],
		"CW-used-air-filter"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["dense-neutron-flux"],
		"used-up-advanced-tritium-breeder-fuel-cell"
	)
	local logistic_0_technology = technologies["logistics-0"]
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(logistic_0_technology, "basic-transport-belt")
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["military-2"],
		"copper-nickel-firearm-magazine"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["basic-fluid-handling"],
		"offshore-pump-0"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["electric-chemical-furnace"],
		"electric-chemical-furnace"
	)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["basic-chemistry"],
		"stone-chemical-furnace"
	)
end

local function showRecipes()
	local recipes = data.raw.recipe
	TreeRecipeUtil.showRecipeWithoutMode(recipes["bullet-casing"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["magazine"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["bullet-projectile"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["bullet"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["uranium-bullet-projectile"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["uranium-bullet"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["shotgun-shell-casing"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["electric-mixing-furnace"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["electric-chemical-furnace"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["stone-chemical-furnace"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["basic-oil-processing"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["bob-oil-processing"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["bob-resin-oil"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["sulfur-2"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["sulfur-3"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["sulfuric-acid-3"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["sulfur-dioxide"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["hydrogen-sulfide"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["nuclear-smelting-copper-plate"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["nuclear-smelting-iron-plate"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["nuclear-smelting-lead-plate"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["nuclear-smelting-silver-plate"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["nuclear-smelting-tin-plate"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["angels-stone-pipe-casting"])
	TreeRecipeUtil.showRecipeWithoutMode(recipes["angels-stone-pipe-to-ground-casting"])
end
addRecipeEffectsToTechnologies()
showRecipes()

data.raw["recipe"]["stone-chemical-furnace"].main_product = "stone-chemical-furnace"
data.raw["recipe"]["stone-chemical-furnace"].result = "stone-chemical-furnace"
data.raw["recipe"]["electric-chemical-furnace"].result = "electric-chemical-furnace"
