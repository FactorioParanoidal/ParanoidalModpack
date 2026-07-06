-- item/walls

if DECT.ENABLED["walls"] then
	data:extend(
		{
			{
				type = "item",
				name = "dect-concrete-wall",
				icon = "__base__/graphics/icons/wall.png",
				icon_size = 64,
				icon_mipmaps = 4,
				subgroup = "defensive-structure",
				order = "a[d-concrete-wall]",
				stack_size = DECT.CONFIG.SETTINGS["walls_stack_size"],
				place_result = "dect-concrete-wall"
			},
			{
				type = "item",
				name = "dect-chain-wall",
				icon = "__Dectorio__/graphics/icons/chain-wall.png",
				icon_size = 32,
				icon_mipmaps = 1,
				subgroup = "defensive-structure",
				order = "a[c-chain-wall]",
				stack_size = DECT.CONFIG.SETTINGS["walls_stack_size"],
				place_result = "dect-chain-wall"
			},
			{
				type = "item",
				name = "dect-wood-wall",
				icon = "__Dectorio__/graphics/icons/wood-wall.png",
				icon_size = 32,
				icon_mipmaps = 1,
				fuel_category = "chemical",
				fuel_value = "6MJ",
				subgroup = "defensive-structure",
				order = "a[a-wood-wall]",
				stack_size = DECT.CONFIG.SETTINGS["walls_stack_size"],
				place_result = "dect-wood-wall"
			},
			{
				type = "item",
				name = "dect-concrete-gate",
				icon = "__base__/graphics/icons/gate.png",
				icon_size = 64,
				icon_mipmaps = 4,
				subgroup = "defensive-structure",
				order = "a[x-concrete-gate]",
				place_result = "dect-concrete-gate",
				stack_size = 50
			}
		}
	)

	-- Change base stone wall
	local base_stone_wall = data.raw["item"]["stone-wall"]
	base_stone_wall.icon = "__Dectorio__/graphics/icons/stone-brick-wall.png"
	base_stone_wall.icon_size = 64
	base_stone_wall.icon_mipmaps = 1
	base_stone_wall.stack_size = DECT.CONFIG.SETTINGS["walls_stack_size"]
	base_stone_wall.order = "a[b-stone-wall]"

	-- Change base gate
	local base_gate = data.raw["item"]["gate"]
	base_gate.icon = "__Dectorio__/graphics/icons/stone-gate.png"
	base_gate.icon_size = 64
	base_gate.icon_mipmaps = 1
	base_gate.stack_size = DECT.CONFIG.SETTINGS["walls_stack_size"]
	base_gate.order = "a[w-stone-gate]"
end
