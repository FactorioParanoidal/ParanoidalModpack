-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.mining.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "inserters",
	type = "technology",
	technology_icon_size = 256,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local technologies = {
	-- ["bob-long-inserters-1"] = {},
	-- ["bob-long-inserters-2"] = {},
	-- ["bob-near-inserters"] = {},
	-- ["bob-more-inserters-1"] = {},
	-- ["bob-more-inserters-2"] = {},
}

-- For non-overhaul condition, long-handed inserters are unlocked by this technology
if reskins.lib.settings.get_value("bobmods-logistics-inserteroverhaul") ~= true then
	-- technologies["long-inserters-1"] = nil
end

reskins.internal.create_icons_from_list(technologies, inputs)
