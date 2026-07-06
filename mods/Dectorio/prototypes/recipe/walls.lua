-- recipe/walls

if DECT.ENABLED["walls"] then
	-- Add new recipes
	data:extend(
		{
			{
				type = "recipe",
				name = "dect-concrete-wall",
				enabled = false,
				ingredients = {
					{type = "item", name = "concrete", amount = 5},
					{type = "item", name = "iron-stick", amount = 2}
				},
				results = {
					{type = "item", name = "dect-concrete-wall", amount = 1},
				}
			},
			{
				type = "recipe",
				name = "dect-concrete-wall-from-stone-wall",
				localised_name = {"recipe-name.dect-concrete-wall-from-stone-wall"},
				icon = "__Dectorio__/graphics/icons/concrete-wall-from-stone-wall.png",
				icon_size = 64,
				icon_mipmaps = 1,
				energy_required = 1,
				enabled = false,
				ingredients = {
					{type = "item", name = "stone-wall", amount = 1},
					{type = "item", name = "concrete", amount = 2}
				},
				results = {
					{type = "item", name = "dect-concrete-wall", amount = 1},
				}
			},
			{
				type = "recipe",
				name = "dect-chain-wall",
				enabled = false,
				ingredients = {
					{type = "item", name = "iron-stick", amount = 2},
					{type = "item", name = "steel-plate", amount = 2}
				},
				results = {
					{type = "item", name = "dect-chain-wall", amount = 1},
				}
			},
			{
				type = "recipe",
				name = "dect-wood-wall",
				enabled = true,
				ingredients = {{type = "item", name = "wood", amount = 3}},
				results = {
					{type = "item", name = "dect-wood-wall", amount = 1},
				}
			},
			{
				type = "recipe",
				name = "dect-concrete-gate",
				enabled = false,
				ingredients = {
					{type = "item", name = "dect-concrete-wall", amount = 1},
					{type = "item", name = "steel-plate", amount = 2},
					{type = "item", name = "advanced-circuit", amount = 2}
				},
				results = {
					{type = "item", name = "dect-concrete-gate", amount = 1},
				}
			},
			{
				type = "recipe",
				name = "dect-concrete-gate-from-stone-gate",
				localised_name = {"recipe-name.dect-concrete-gate-from-stone-gate"},
				icon = "__Dectorio__/graphics/icons/concrete-gate-from-stone-gate.png",
				icon_size = 64,
				icon_mipmaps = 1,
				energy_required = 1,
				enabled = false,
				ingredients = {
					{type = "item", name = "gate", amount = 1},
					{type = "item", name = "concrete", amount = 2},
					{type = "item", name = "advanced-circuit", amount = 1}
				},
				results = {
					{type = "item", name = "dect-concrete-gate", amount = 1},
				}
			}
		}
	)

	-- Change base gates to simpler recipe
	data.raw["recipe"]["gate"].ingredients = {
		{type = "item", name = "stone-wall", amount = 1},
		{type = "item", name = "iron-plate", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2}
	}
end
