-- recipe/landscaping

if DECT.ENABLED["landscaping"] then

	local base_tiles = DECT.CONFIG.BASE_TILES

	-- Create new landscaping recipes for base ground tiles
	for _, tile in pairs(base_tiles) do
		if data.raw["tile"][tile] then
			data:extend({
				{
					type = "recipe",
					name = "dect-base-"..tile,
					energy_required = 5,
					enabled = false,
					category = "crafting",
					ingredients = {
						{type = "item", name = "stone", amount = 2}
					},
					results = {
						{type = "item", name = "dect-base-"..tile, amount = 10},
					}
				}
			})
		end
	end

end

if DECT.ENABLED["lawnmower"] then

	-- Create Lawnmower recipe
	data:extend({
		{
			type = "recipe",
			name = "dect-lawnmower",
			energy_required = 3,
			enabled = false,
			ingredients = {
				{type = "item", name = "steel-plate", amount = 2},
				{type = "item", name = "iron-gear-wheel", amount = 6},
				{type = "item", name = "engine-unit", amount = 1}
			},
			results = {
				{type = "item", name = "dect-lawnmower", amount = 1},
			}
		}
	})

end

if DECT.ENABLED["waterfill"] then

	local water_tiles = DECT.CONFIG.BASE_WATER_TILES

	-- Create new landscaping recipes for base water tiles
	for _, tile in pairs(water_tiles) do
		if data.raw["tile"][tile] then
			data:extend({
				{
					type = "recipe",
					name = "dect-base-"..tile,
					energy_required = 10,
					enabled = false,
					category = "crafting-with-fluid",
					ingredients = {
						{type = "item", name = "explosives", amount = 5},
						{type = "fluid", name = "water", amount = 100}
					},
					results = {
						{type = "item", name = "dect-base-"..tile, amount = 1},
					}
				}
			})
		end
	end

end

if DECT.ENABLED["landscaping"] then

	local base_trees = DECT.CONFIG.BASE_TREES
	local base_rocks = DECT.CONFIG.BASE_ROCKS

	-- calculate the cost of the entity based upon what it gives when mined
	local function entity_ingredients(name, type)
		local entity = data.raw[type][name]
		local ingredients = {}
		if entity.minable then
			if entity.minable.results then
				for _, result in pairs(entity.minable.results) do
					if result.amount_max then
						table.insert(ingredients, {type = "item", name = result.name, amount = result.amount_max * 1.1})
					elseif result.amount then
						table.insert(ingredients, {type = "item", name = result.name, amount = result.amount * 1.5})
					end
				end
			elseif entity.minable.result then
				table.insert(ingredients, {type = "item", name = entity.minable.result, amount = entity.minable.count * 1.5})
			end
		end
		return ingredients
	end

	-- Create new landscaping recipes for base trees
	for _, tree in pairs(base_trees) do
		data:extend({
			{
				type = "recipe",
				name = "dect-base-"..tree,
				energy_required = 2,
				enabled = false,
				category = "crafting",
				ingredients = entity_ingredients(tree, "tree"),
				results = {
					{type = "item", name = "dect-base-"..tree, amount = 1},
				}
			}
		})
	end

	-- Create new landscaping recipes for base rock decoratives
	for _, rock in pairs(base_rocks) do
		data:extend({
			{
				type = "recipe",
				name = "dect-base-"..rock,
				energy_required = 2,
				enabled = false,
				category = "crafting",
				ingredients = entity_ingredients(rock, "simple-entity"),
				results = {
					{type = "item", name = "dect-base-"..rock, amount = 1},
				}
			}
		})
	end

end
