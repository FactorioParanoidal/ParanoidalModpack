-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "angels",
	group = "refining",
	type = "technology",
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {}

reskins.internal.create_icons_from_list(technologies, inputs)
