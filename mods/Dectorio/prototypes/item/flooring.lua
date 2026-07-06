-- item/flooring

-- Add new subgroup for basic floorings
data:extend(
	{
		{
			type = "item-subgroup",
			name = "flooring-basic",
			group = DECT.ITEM_GROUP,
			order = "i-b"
		}
	}
)

-- Change base concrete & stone path
local base_refined_concrete = data.raw["item"]["refined-concrete"]
local base_concrete = data.raw["item"]["concrete"]
local base_stone_brick = data.raw["item"]["stone-brick"]
base_refined_concrete.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
base_refined_concrete.subgroup = "flooring-basic"
base_refined_concrete.order = "00[e-refined-concrete]"
base_concrete.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
base_concrete.subgroup = "flooring-basic"
base_concrete.order = "00[d-concrete]"
base_stone_brick.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
base_stone_brick.subgroup = "flooring-basic"
base_stone_brick.order = "00[b-stone-brick]"

if DECT.ENABLED["painted-concrete"] then
	-- Add new subgroup for painted concretes
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "flooring-painted",
				group = DECT.ITEM_GROUP,
				order = "i-c"
			}
		}
	)

	-- Add new items
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-paint-" .. variant.name,
					icon = "__Dectorio__/graphics/icons/paint-" .. variant.name .. ".png",
					icon_size = 64,
					icon_mipmaps = 1,
					subgroup = "flooring-painted",
					order = "00[b-" .. _ .. "-paint-" .. variant.name .. "]",
					stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
					place_as_tile = {
						result = "dect-paint-" .. variant.name .. "-left",
						condition_size = 1,
						condition = {layers = {water_tile = true}}
					}
				}
			}
		)
	end

	-- Add new subgroup for refined painted concretes
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "flooring-painted-refined",
				group = DECT.ITEM_GROUP,
				order = "i-d"
			}
		}
	)

	-- Add new items
	for _, variant in pairs(DECT.CONFIG.PAINT_VARIANTS) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-paint-refined-" .. variant.name,
					icon = "__Dectorio__/graphics/icons/paint-" .. variant.name .. "-refined.png",
					icon_size = 64,
					icon_mipmaps = 1,
					subgroup = "flooring-painted-refined",
					order = "00[b-" .. _ .. "-paint-refined-" .. variant.name .. "]",
					stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
					place_as_tile = {
						result = "dect-paint-refined-" .. variant.name .. "-left",
						condition_size = 1,
						condition = {layers = {water_tile = true}}
					}
				}
			}
		)
	end

	-- Make items for base colored refined concrete
	data:extend(
		{
			{
				type = "item-subgroup",
				name = "flooring-painted-refined-base",
				group = DECT.ITEM_GROUP,
				order = "i-e"
			}
		}
	)

	for _, color in pairs(DECT.CONFIG.BASE_COLORS) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-" .. color.name .. "-refined-concrete",
					localised_name = {"", {"color." .. color.name}, " ", {"tile-name.refined-concrete"}},
					icons = {
						{icon = "__base__/graphics/icons/refined-concrete.png", tint = color.tint}
					},
					icon_size = 64,
					icon_mipmaps = 1,
					subgroup = "flooring-painted-refined-base",
					order = "00[" .. color.name .. "-refined-concrete]",
					stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
					place_as_tile = {
						result = color.name .. "-refined-concrete",
						condition_size = 1,
						condition = {layers = {water_tile = true}}
					}
				}
			}
		)
	end

	-- Move base hazard concrete item under painted concrete
	local base_hazard_item = data.raw["item"]["hazard-concrete"]
	base_hazard_item.subgroup = "flooring-painted"
	base_hazard_item.order = "00[a-hazard-concrete]"
	base_hazard_item.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
	local base_refined_hazard_item = data.raw["item"]["refined-hazard-concrete"]
	base_refined_hazard_item.subgroup = "flooring-painted-refined"
	base_refined_hazard_item.order = "00[a-hazard-concrete]"
	base_refined_hazard_item.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]

	if not DECT.CONFIG.SETTINGS["vanilla_hazard_concrete"] then
		base_hazard_item.icon = "__Dectorio__/graphics/icons/paint-hazard.png"
		base_hazard_item.icon_size = 64
		base_hazard_item.icon_mipmaps = 1
		base_refined_hazard_item.icon = "__Dectorio__/graphics/icons/paint-hazard-refined.png"
		base_refined_hazard_item.icon_size = 64
		base_refined_hazard_item.icon_mipmaps = 1
	end
else
	-- Move base hazard concrete item under basic flooring
	local base_hazard_item = data.raw["item"]["hazard-concrete"]
	base_hazard_item.subgroup = "flooring-basic"
	base_hazard_item.order = "00[f-hazard-concrete]"
	base_hazard_item.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
	local base_refined_hazard_item = data.raw["item"]["refined-hazard-concrete"]
	base_refined_hazard_item.subgroup = "flooring-basic"
	base_refined_hazard_item.order = "00[f-refined-hazard-concrete]"
	base_refined_hazard_item.stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"]
end

if DECT.ENABLED["wood-floor"] then
	data:extend(
		{
			{
				type = "item",
				name = "dect-wood-floor",
				icon = "__Dectorio__/graphics/icons/wood-floor.png",
				icon_size = 64,
				icon_mipmaps = 1,
				fuel_category = "chemical",
				fuel_value = "2MJ",
				subgroup = "flooring-basic",
				order = "00[a-wood-floor]",
				stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
				place_as_tile = {
					result = "dect-wood-floor",
					condition_size = 1,
					condition = {layers = {water_tile = true}}
				}
			}
		}
	)
end

if DECT.ENABLED["concrete"] then
	data:extend(
		{
			{
				type = "item",
				name = "dect-concrete-grid",
				icon = "__Dectorio__/graphics/icons/concrete-grid.png",
				icon_size = 64,
				icon_mipmaps = 1,
				subgroup = "flooring-basic",
				order = "00[f-concrete-grid]",
				stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
				place_as_tile = {
					result = "dect-concrete-grid",
					condition_size = 1,
					condition = {layers = {water_tile = true}}
				}
			}
		}
	)
end

if DECT.ENABLED["gravel"] then
	-- Add new items
	for _, variant in pairs(DECT.CONFIG.GRAVEL_VARIANTS) do
		data:extend(
			{
				{
					type = "item",
					name = "dect-" .. variant.name .. "-gravel",
					icons = {
						{icon = "__Dectorio__/graphics/icons/gravel.png", tint = variant.color}
					},
					icon_size = 64,
					icon_mipmaps = 1,
					subgroup = "flooring-basic",
					order = "00[g-gravel-" .. variant.name .. "]",
					stack_size = DECT.CONFIG.SETTINGS["flooring_stack_size"],
					place_as_tile = {
						result = "dect-" .. variant.name .. "-gravel",
						condition_size = 2,
						condition = {layers = {water_tile = true}}
					}
				}
			}
		)
	end
end
