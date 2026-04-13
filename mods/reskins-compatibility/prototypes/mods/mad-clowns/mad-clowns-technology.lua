-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.mad_clowns.is_active) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "compatibility",
	group = "mad-clowns",
	type = "technology",
	technology_icon_size = 256,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local technologies = {
	["advanced-depleted-uranium-smelting-1"] = { subgroup = "casting", image = "casting-depleted-uranium-technology-icon" },
	["advanced-depleted-uranium-smelting-2"] = { subgroup = "casting", image = "casting-depleted-uranium-technology-icon" },
	["advanced-magnesium-smelting"] = { subgroup = "casting", image = "casting-magnesium-technology-icon" },
	["advanced-osmium-smelting"] = { subgroup = "casting", image = "casting-osmium-technology-icon" },
}

reskins.internal.create_icons_from_list(technologies, inputs)
