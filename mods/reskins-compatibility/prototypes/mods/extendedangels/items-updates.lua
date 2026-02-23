-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then
	return
end
if not (reskins.angels and reskins.angels.triggers.smelting.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "compatibility",
	group = "extendedangels",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local intermediates = {
	-- Items
	["angels-powder-tungsten-carbide"] = { subgroup = "powders/tungsten-carbide", image = "powder-tungsten-carbide" },
	-- Recipes
	["angels-tungsten-carbide-smelting-1"] = { type = "recipe", subgroup = "powders/tungsten-carbide", image = "powder-tungsten-carbide", icon_extras = reskins.angels.num_tier(1, "smelting") },
	["angels-tungsten-carbide-smelting-2"] = { type = "recipe", subgroup = "powders/tungsten-carbide", image = "powder-tungsten-carbide", icon_extras = reskins.angels.num_tier(2, "smelting") },
	["angels-tungsten-carbide-smelting-3"] = { type = "recipe", subgroup = "powders/tungsten-carbide", image = "powder-tungsten-carbide", icon_extras = reskins.angels.num_tier(3, "smelting") },
}

reskins.internal.create_icons_from_list(intermediates, inputs)

-- Setup powder variations
local powder = data.raw.item["angels-powder-tungsten-carbide"]

if powder then
	powder.pictures = {}

	for i = 1, 6, 1 do
		table.insert(powder.pictures, {
			filename = "__reskins-compatibility__/graphics/icons/extendedangels/powders/tungsten-carbide/powder-tungsten-carbide-" .. i .. ".png",
			flags = { "icon" },
			size = 64,
			mipmap_count = 4,
			scale = 0.25,
		})
	end
end
