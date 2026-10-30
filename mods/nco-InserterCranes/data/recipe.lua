local util = require("util")

local make_layered_icon = require("icon")

local function crushing_category()
	for _, name in pairs({"kr-crushing", "crushing"}) do
		if data.raw["recipe-category"][name] then
			return name
		end
	end
end

local function make_crane_recipe(recipeName, newName, wide)
	local scale = 5.5
	if wide then
		scale = 16
	end
	local recipe = util.table.deepcopy(data.raw["recipe"][recipeName])
	if recipe.icon or recipe.icons then
		make_layered_icon(recipe, wide)
	end
	recipe.name = newName
	recipe.energy_required = (recipe.energy_required or 1) * scale
	recipe.results = {{type = "item", name = newName, amount = 1}}
	recipe.main_product = nil
	recipe.enabled = false
	recipe.subgroup = "inserter-cranes"
	local ingredients = {}
	for _, v in pairs(recipe.ingredients or {}) do
		table.insert(ingredients, {type = v.type or "item", name = v.name or v[1], amount = math.ceil((v.amount or v[2]) * scale)})
	end
	recipe.ingredients = ingredients
	data:extend({recipe})
	-- add k2 crushing recipe
	local category = mods["Krastorio2"] and crushing_category()
	if category then
		local crushing_recipe = {
			type = "recipe",
			name = newName .. "-to-parts",
			icon = "__base__/graphics/icons/inserter.png",
			icon_size = 64,
			category = category,
			subgroup = "inserter-cranes",
			hide_from_player_crafting = true,
			always_show_made_in = true,
			allow_as_intermediate = false,
			allow_intermediates = false,
			always_show_products = true,
			energy_required = 1,
			enabled = true,
			ingredients = {
				{type = "item", name = newName, amount = 1}
			},
			results = {}
		}
		for _, v in pairs(ingredients) do
			if v.type == "item" then
				table.insert(crushing_recipe.results, {type = "item", name = v.name, amount = v.amount, probability = 0.65})
			end
		end
		data:extend({crushing_recipe})
	end
end

return make_crane_recipe
