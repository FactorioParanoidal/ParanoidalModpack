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

--[[local coal_bi_bio_farm_recipe = flib.copy_prototype(data.raw["recipe"]["bi-bio-farm"], "coal-bi-bio-farm")

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
		name = "wood",
		amount = 40,
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
]]
local salvaged_mining_drill_recipe = copy_salvaged_recipe("burner-mining-drill", "salvaged-mining-drill")
salvaged_mining_drill_recipe.ingredients = {
	{
		type = "item",
		name = "wood",
		amount = 120,
	},
	{
		type = "item",
		name = "salvaged-iron-gear-wheel",
		amount = 16,
	} --[[,
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
	},]],
}
--[[local salvaged_ore_crusher_recipe = copy_salvaged_recipe("burner-ore-crusher", "salvaged-ore-crusher")
salvaged_ore_crusher_recipe.ingredients = {
	{
		type = "item",
		name = "wood",
		amount = 120,
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
}]]
--извлечённые рецепты
data:extend({
	--copy_salvaged_recipe("mining-drill-bit-mk0", "salvaged-mining-drill-bit-mk0"),
	copy_salvaged_recipe("iron-gear-wheel", "salvaged-iron-gear-wheel"),
	copy_salvaged_recipe("lab", "salvaged-lab"),
	copy_salvaged_recipe("assembling-machine-1", "salvaged-assembling-machine"),
	--salvaged_offsore_pump_0_recipe,
	salvaged_mining_drill_recipe,
	--salvaged_ore_crusher_recipe,
	copy_salvaged_recipe("automation-science-pack", "salvaged-automation-science-pack"),
	copy_salvaged_recipe("accumulator", "salvaged-generator"),
})
--[[data:extend({
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
})]]

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

local function addRecipeEffectsToTechnologies()
	local technologies = data.raw["technology"]
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["nuclear-power"],
		"used-up-uranium-fuel-cell"
	)
end
addRecipeEffectsToTechnologies()
