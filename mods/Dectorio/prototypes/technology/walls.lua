-- technology/walls

if DECT.ENABLED["walls"] then
	-- Change stone wall tech to basic walls
	local base_stone_wall = data.raw["technology"]["stone-wall"]
	base_stone_wall.icon = "__Dectorio__/graphics/technology/basic-wall.png"
	base_stone_wall.icon_size = 256
	base_stone_wall.icon_mipmaps = 1

	data:extend(
		{
			{
				type = "technology",
				name = "dect-advanced-wall",
				icon = "__base__/graphics/technology/stone-wall.png",
				icon_size = 256,
				icon_mipmaps = 4,
				prerequisites = {"military-2", "concrete", "stone-wall"},
				unit = {
					count = 150,
					ingredients = {
						{"automation-science-pack", 1},
						{"logistic-science-pack", 1},
						{"military-science-pack", 1}
					},
					time = 30
				},
				effects = {
					{
						type = "unlock-recipe",
						recipe = "dect-chain-wall"
					},
					{
						type = "unlock-recipe",
						recipe = "dect-concrete-wall"
					},
					{
						type = "unlock-recipe",
						recipe = "dect-concrete-wall-from-stone-wall"
					}
				},
				order = "e-p-b-a"
			},
			{
				type = "technology",
				name = "dect-advanced-gate",
				icon = "__base__/graphics/technology/gate.png",
				icon_size = 256,
				icon_mipmaps = 4,
				prerequisites = {"gate", "dect-advanced-wall"},
				unit = {
					count = 150,
					ingredients = {
						{"automation-science-pack", 1},
						{"logistic-science-pack", 1},
						{"military-science-pack", 1}
					},
					time = 45
				},
				effects = {
					{
						type = "unlock-recipe",
						recipe = "dect-concrete-gate"
					},
					{
						type = "unlock-recipe",
						recipe = "dect-concrete-gate-from-stone-gate"
					}
				},
				order = "e-p-b-a"
			}
		}
	)
end
