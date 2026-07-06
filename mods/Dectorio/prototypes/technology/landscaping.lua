-- technology/landscaping

if DECT.ENABLED["landscaping"] then

	local base_tiles = DECT.CONFIG.BASE_TILES
	local base_trees = DECT.CONFIG.BASE_TREES
	local base_rocks = DECT.CONFIG.BASE_ROCKS

	-- Add new Landscaping technoogy
	local landscaping_effects = {}
	for _, tile in pairs(base_tiles) do
		if data.raw["tile"][tile] then
			table.insert(landscaping_effects, {type = "unlock-recipe", recipe = "dect-base-"..tile})
		end
	end
	for _, tree in pairs(base_trees) do
		if data.raw["tree"][tree] then
			table.insert(landscaping_effects, {type = "unlock-recipe", recipe = "dect-base-"..tree})
		end
	end
	for _, rock in pairs(base_rocks) do
		if data.raw["simple-entity"][rock] then
			table.insert(landscaping_effects, {type = "unlock-recipe", recipe = "dect-base-"..rock})
		end
	end

	data:extend({
		{
			type = "technology",
			name = "dect-landscaping",
			icon = "__Dectorio__/graphics/technology/landscaping.png",
			icon_size = 256,
			icon_mipmaps = 1,
			unit = {
				count = 15,
				ingredients = {
					{"automation-science-pack", 1},
				},
				time = 10
			},
			effects = landscaping_effects,
			order = "a"
		}
	})

	-- Move base landfill tech underneath landscaping
	local base_landfill = data.raw["technology"]["landfill"]
	if not base_landfill.prerequisites then
		base_landfill.prerequisites = {}
	end
	table.insert(base_landfill.prerequisites, "dect-landscaping")

end

if DECT.ENABLED["lawnmower"] then
	if DECT.ENABLED["landscaping"] then
		lawnmower_prereq = {"dect-landscaping", "engine"}
	else
		lawnmower_prereq = {"engine"}
	end
	data:extend({
		{
			type = "technology",
			name = "dect-lawnmower",
			icon = "__Dectorio__/graphics/technology/lawnmower.png",
			icon_size = 256,
			icon_mipmaps = 1,
			prerequisites = lawnmower_prereq,
			unit = {
				count = 30,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
				},
				time = 15
			},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "dect-lawnmower"
				}
			},
			order = "b-d-a"
		}
	})
end

if DECT.ENABLED["waterfill"] then

	-- Add waterfill items to Earthworks technology
	local water_tiles = DECT.CONFIG.BASE_WATER_TILES
	local earthworks_effects = {}
	for _, tile in pairs(water_tiles) do
		if data.raw["tile"][tile] then
			table.insert(earthworks_effects, {type = "unlock-recipe", recipe = "dect-base-"..tile})
		end
	end

	data:extend({
		{
			type = "technology",
			name = "dect-earthworks",
			icon = "__Dectorio__/graphics/technology/landscaping.png",
			icon_size = 256,
			icon_mipmaps = 1,
			prerequisites = {"landfill", "explosives"},
			unit = {
				count = 200,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
				},
				time = 15
			},
			effects = earthworks_effects,
			order = "b-d-a"
		}
	})

end
