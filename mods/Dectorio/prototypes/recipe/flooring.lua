-- recipe/flooring

if DECT.ENABLED["painted-concrete"] then
	-- Add new recipes
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		data:extend(
			{
				{
					type = "recipe",
					name = "dect-paint-" .. variant.name,
					energy_required = 0.25,
					enabled = false,
					category = "crafting",
					ingredients = {
						{type = "item", name = "concrete", amount = 10}
					},
					results = {
						{type = "item", name = "dect-paint-" .. variant.name, amount = 10},
					}
				},
				{
					type = "recipe",
					name = "dect-paint-refined-" .. variant.name,
					energy_required = 0.25,
					enabled = false,
					category = "crafting",
					ingredients = {
						{type = "item", name = "refined-concrete", amount = 10}
					},
					results = {
						{type = "item", name = "dect-paint-refined-" .. variant.name, amount = 10},
					}
				}
			}
		)
	end

	-- Make recipes for base colored refined concrete
	for _, color in pairs(DECT.CONFIG.BASE_COLORS) do
		data:extend(
			{
				{
					type = "recipe",
					name = "dect-" .. color.name .. "-refined-concrete",
					energy_required = 0.25,
					enabled = false,
					category = "crafting",
					ingredients = {
						{type = "item", name = "refined-concrete", amount = 10}
					},
					results = {
						{type = "item", name = "dect-" .. color.name .. "-refined-concrete", amount = 10},
					}
				}
			}
		)
	end
end

if DECT.ENABLED["gravel"] then
	-- Add new recipes
	for _, variant in pairs(DECT.CONFIG.GRAVEL_VARIANTS) do
		data:extend(
			{
				{
					type = "recipe",
					name = "dect-" .. variant.name .. "-gravel",
					energy_required = 0.1,
					enabled = true,
					category = "crafting",
					ingredients = {
						{type = "item", name = variant.name, amount = 1}
					},
					results = {
						{type = "item", name = "dect-" .. variant.name .. "-gravel", amount = 1},
					}
				}
			}
		)
	end
end

if DECT.ENABLED["wood-floor"] then
	-- Add new recipes
	data:extend(
		{
			{
				-- Wooden floorboards
				type = "recipe",
				name = "dect-wood-floor",
				energy_required = 5,
				enabled = false,
				category = "crafting",
				ingredients = {
					{type = "item", name = "wood", amount = 10}
				},
				results = {
					{type = "item", name = "dect-wood-floor", amount = 10},
				}
			}
		}
	)
end

if DECT.ENABLED["concrete"] then
	-- Add new recipes
	data:extend(
		{
			{
				-- Concrete grid
				type = "recipe",
				name = "dect-concrete-grid",
				energy_required = 10,
				enabled = false,
				category = "crafting-with-fluid",
				ingredients = {
					{type = "item", name = "stone-brick", amount = 5},
					{type = "item", name = "iron-ore", amount = 1},
					{type = "fluid", name = "water", amount = 100}
				},
				results = {
					{type = "item", name = "dect-concrete-grid", amount = 10},
				}
			}
		}
	)
end
