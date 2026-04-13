-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.revamp.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "revamp",
	type = "technology",
}

---@type CreateIconsFromListTable
local technologies = {
	-- Chemical plant
	["bob-chemical-plant"] = { group = "assembly", tier = 1, prog_tier = 2, icon_name = "chemical-plant" },
}

reskins.internal.create_icons_from_list(technologies, inputs)
