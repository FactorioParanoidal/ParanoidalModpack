-- item/landscaping

if DECT.ENABLED["landscaping"] then
	-- Add subgroup for base tiles
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "landscaping",
				group = DECT.ITEM_GROUP,
				order = "l-a"
			}
		}
	)

	-- Add new items
	local base_tiles = DECT.CONFIG.BASE_TILES
	for _, tile in pairs(base_tiles) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-base-" .. tile,
					icon = "__Dectorio__/graphics/icons/base-" .. tile .. ".png",
					icon_size = 64,
					subgroup = "landscaping",
					order = "a[base-" .. tile .. "]",
					stack_size = DECT.CONFIG.SETTINGS["landscaping_stack_size"],
					place_as_tile = {
						result = tile,
						condition_size = 1,
						condition = {layers = {water_tile = true}}
					},
					localised_name = {"tile-name." .. tile}
				}
			}
		)
	end
end

if DECT.ENABLED["waterfill"] or DECT.ENABLED["landscaping"] or DECT.ENABLED["lawnmower"] then
	-- Add subgroup for base water
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "landscaping-earthworks",
				group = DECT.ITEM_GROUP,
				order = "l-b"
			}
		}
	)
end

if DECT.ENABLED["waterfill"] then
	-- Add new items
	local water_tiles = DECT.CONFIG.BASE_WATER_TILES
	for _, tile in pairs(water_tiles) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-base-" .. tile,
					icon = "__Dectorio__/graphics/icons/base-" .. tile .. ".png",
					icon_size = 64,
					subgroup = "landscaping-earthworks",
					order = "a[" .. _ .. "base-" .. tile .. "]",
					stack_size = DECT.CONFIG.SETTINGS["landscaping_stack_size"],
					place_as_tile = {
						result = tile,
						condition_size = 1,
						condition = {layers = {water_tile = true}}
					},
					localised_name = {"tile-name." .. tile}
				}
			}
		)

		-- If this is deep water, then it can only be placed in water
		if string.find(tile, "deep") then
			data.raw["item"]["dect-base-" .. tile].place_as_tile.condition = {layers = {ground_tile = true}}
		end
	end
end

if DECT.ENABLED["landscaping"] then
	-- Add subgroup for base trees
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "landscaping-trees",
				group = DECT.ITEM_GROUP,
				order = "l-c"
			}
		}
	)

	-- Add items for placing trees
	local base_trees = DECT.CONFIG.BASE_TREES
	for _, tree in pairs(base_trees) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-base-" .. tree,
					icon = data.raw["tree"][tree].icon,
					icon_size = 64,
					icon_mipmaps = 4,
					subgroup = "landscaping-trees",
					order = "a[base-" .. tree .. "]",
					stack_size = DECT.CONFIG.SETTINGS["landscaping_stack_size"],
					place_result = tree,
					localised_name = {"entity-name." .. tree}
				}
			}
		)
	end

	-- Add subgroup for base rocks
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "landscaping-rocks",
				group = DECT.ITEM_GROUP,
				order = "l-d"
			}
		}
	)

	-- Add items for placing rocks
	local base_rocks = DECT.CONFIG.BASE_ROCKS
	for _, rock in pairs(base_rocks) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-base-" .. rock,
					icon = data.raw["simple-entity"][rock].icon,
					icon_size = 64,
					icon_mipmaps = 4,
					subgroup = "landscaping-rocks",
					order = "a[base-" .. rock .. "]",
					stack_size = DECT.CONFIG.SETTINGS["landscaping_stack_size"],
					place_result = rock,
					localised_name = {"entity-name." .. rock}
				}
			}
		)
	end
end

if DECT.ENABLED["lawnmower"] then
	-- Add Lawnmower item
	data:extend(
		{
			{
				type = "selection-tool",
				name = "dect-lawnmower",
				icon = "__Dectorio__/graphics/icons/lawnmower.png",
				icon_size = 64,
				icon_mipmaps = 1,
				stack_size = 1,
				stackable = false,
				subgroup = "landscaping-earthworks",
				order = "d[lawnmower]",
				select =
					{
						border_color = {r = 0.10, g = 0.46, b = 0.13, a = 0.33},
						mode = {"any-entity"},
						cursor_box_type = "not-allowed",
					},
				alt_select =
					{
						border_color = {r = 0.72, g = 0.69, b = 0.17, a = 0.33},
						mode = {"nothing"},
						cursor_box_type = "entity",
					},
				can_be_mod_opened = false,
				show_in_library = false
			},
			{
				type = "sound",
				name = "dect-lawnmower",
				variations = {
					{filename = "__Dectorio__/sound/lawnmower-01.ogg", volume = 0.9},
					{filename = "__Dectorio__/sound/lawnmower-02.ogg", volume = 1}
				}
			}
		}
	)
end

if DECT.ENABLED["waterfill"] or DECT.ENABLED["landscaping"] then
	-- Modify base landfill and cliff explosives
	local base_landfill = data.raw["item"]["landfill"]
	local base_cliff_explosives = data.raw["capsule"]["cliff-explosives"]
	base_landfill.subgroup = "landscaping-earthworks"
	base_landfill.order = "b[landfill]"
	base_landfill.stack_size = DECT.CONFIG.SETTINGS["landscaping_stack_size"]
	base_cliff_explosives.subgroup = "landscaping-earthworks"
	base_cliff_explosives.order = "c[cliff-explosives]"
end
