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

local salvaged_mining_drill_recipe = copy_salvaged_recipe("burner-mining-drill", "salvaged-mining-drill")
salvaged_mining_drill_recipe.ingredients = {
	{
		type = "item",
		name = "wood",
		amount = 120
	},
	{
		type = "item",
		name = "salvaged-iron-gear-wheel",
		amount = 16
	}
}
--извлечённые рецепты
data:extend(
	{
		copy_salvaged_recipe("iron-gear-wheel", "salvaged-iron-gear-wheel"),
		copy_salvaged_recipe("lab", "salvaged-lab"),
		copy_salvaged_recipe("assembling-machine-1", "salvaged-assembling-machine"),
		salvaged_mining_drill_recipe,
		copy_salvaged_recipe("automation-science-pack", "salvaged-automation-science-pack"),
		copy_salvaged_recipe("accumulator", "salvaged-generator")
	}
)
if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
	data:extend(
		{
			copy_salvaged_recipe("radar", "salvaged-radar")
		}
	)
end
data:extend(
	{
		{
			type = "recipe",
			name = "used-up-uranium-fuel-cell",
			icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png",
			icon_size = 64,
			icon_mipmaps = 4,
			subgroup = "intermediate-product",
			order = "r[used-up-uranium-fuel-cell]",
			ingredients = {{type = "item", name = "uranium-fuel-cell", amount = 1}},
			result = "used-up-uranium-fuel-cell",
			result_count = 1
		}
	}
)

local function add_recipes_to_technology_effects()
	local technologies = data.raw["technology"]
	TreeRecipeUtil.add_recipe_effect_to_technology_without_mode(technologies["nuclear-power"], "used-up-uranium-fuel-cell")
end
add_recipes_to_technology_effects()
