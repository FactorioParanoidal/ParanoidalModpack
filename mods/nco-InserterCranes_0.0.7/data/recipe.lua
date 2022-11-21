local util = require("util")

local make_layered_icon = require("icon")

local function make_crane_recipe(recipeName, newName, wide)
	local scale = 5.5
	if wide then
		scale = 16
	end
	local recipe = util.table.deepcopy(data.raw["recipe"][recipeName])
	--log(serpent.block(recipe))
	if recipe.icon or recipe.icons then
		make_layered_icon(recipe, wide)
	end
	recipe.name = newName
	recipe.energy_required = (recipe.energy_required or 1) * scale
	recipe.result = newName
	recipe.enabled = false
	recipe.subgroup = "inserter-cranes"
	local ingredients = {}
	local base_ingredients = recipe.ingredients
	if not base_ingredients then
		if recipe.normal then
			base_ingredients = recipe.normal.ingredients
		elseif recipe.expensive then
			base_ingredients = recipe.expensive.ingredients
		end
	end
	for _, v in pairs(base_ingredients) do
		local item_name = v["name"] or v[1]
		local amount = v["amount"] or v[2]
		--log(item_name)
		--log(amount)
		table.insert(ingredients, {name= item_name, amount = math.ceil(amount * scale), type = "item"})
	end
	recipe.ingredients = ingredients
	recipe.normal = nil
	recipe.expensive = nil
	--log("recipe"..serpent.block(recipe))
	data:extend({recipe})
	-- add k2 crushing recipe
	if mods["Krastorio2"] then
		local crushing_recipe = {
			type = "recipe",
			name = newName .. "-to-parts",
			icon = "__base__/graphics/icons/inserter.png",
			icon_size = 64,
			icon_mipmaps = 4,
			category = "crushing",
			subgroup = "inserter-cranes",
			hide_from_player_crafting = true,
			always_show_made_in = true,
			allow_as_intermediate = false,
			allow_intermediates = false,
			always_show_products = true,
			energy_required = 1,
			enabled = true,
			ingredients = {
				{newName, 1}
			},
			results = {}
		}
		for _, v in pairs(ingredients) do
			table.insert(crushing_recipe.results, {type = "item", name = v["name"],  amount = v["amount"], probability = 0.65})
		end
		data:extend({crushing_recipe})
	end
end

return make_crane_recipe
