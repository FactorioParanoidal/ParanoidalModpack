-- technology/flooring

if DECT.ENABLED["wood-floor"] then
	data:extend(
		{
			{
				type = "technology",
				name = "dect-wood-floor",
				icon = "__Dectorio__/graphics/technology/wood-floor.png",
				icon_size = 256,
				icon_mipmaps = 1,
				unit = {
					count = 10,
					ingredients = {
						{"automation-science-pack", 1}
					},
					time = 10
				},
				effects = {
					{
						type = "unlock-recipe",
						recipe = "dect-wood-floor"
					}
				},
				order = "a-j-z"
			}
		}
	)
end

if DECT.ENABLED["painted-concrete"] then
	local painted_concrete_effects = {}
	table.insert(painted_concrete_effects, {type = "unlock-recipe", recipe = "hazard-concrete"})
	table.insert(painted_concrete_effects, {type = "unlock-recipe", recipe = "refined-hazard-concrete"})
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		if data.raw["tile"]["dect-paint-" .. variant.name .. "-left"] then
			table.insert(painted_concrete_effects, {type = "unlock-recipe", recipe = "dect-paint-" .. variant.name})
		end
		if data.raw["tile"]["dect-paint-refined-" .. variant.name .. "-left"] then
			table.insert(painted_concrete_effects, {type = "unlock-recipe", recipe = "dect-paint-refined-" .. variant.name})
		end
	end
	for _, color in pairs(DECT.CONFIG.BASE_COLORS) do
		if data.raw["tile"][color.name .. "-refined-concrete"] then
			table.insert(
				painted_concrete_effects,
				{type = "unlock-recipe", recipe = "dect-" .. color.name .. "-refined-concrete"}
			)
		end
	end

	data:extend(
		{
			{
				type = "technology",
				name = "dect-concrete-paint",
				icon = "__Dectorio__/graphics/technology/concrete-paint.png",
				icon_size = 256,
				icon_mipmaps = 1,
				prerequisites = {"concrete"},
				unit = {
					count = 150,
					ingredients = {
						{"automation-science-pack", 1},
						{"logistic-science-pack", 1}
					},
					time = 20
				},
				effects = painted_concrete_effects
			}
		}
	)

	-- Remove Hazard concrete from Concrete tech (as it's now under the painted concrete tech)
	local base_concrete_effects = data.raw["technology"]["concrete"].effects
	for i = 1, #base_concrete_effects do
		effect = base_concrete_effects[i]
		if effect.type == "unlock-recipe" and effect.recipe == "hazard-concrete" then
			index = i
		end
	end
	table.remove(base_concrete_effects, index)
	local base_concrete_effects = data.raw["technology"]["concrete"].effects
	for i = 1, #base_concrete_effects do
		effect = base_concrete_effects[i]
		if effect.type == "unlock-recipe" and effect.recipe == "refined-hazard-concrete" then
			index = i
		end
	end
	table.remove(base_concrete_effects, index)
end

if DECT.ENABLED["concrete"] then
	-- Add grid-based concrete to base Concrete tech
	local base_concrete_effects = data.raw["technology"]["concrete"].effects
	table.insert(base_concrete_effects, {type = "unlock-recipe", recipe = "dect-concrete-grid"})
end
