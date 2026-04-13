-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.enemies.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "enemies",
	make_icon_pictures = false,
	flat_icon = true,
}

---@type CreateIconsFromListTable
local items = {
	["bob-alien-artifact"] = { subgroup = "artifacts" },
	["bob-alien-artifact-blue"] = { subgroup = "artifacts" },
	["bob-alien-artifact-green"] = { subgroup = "artifacts" },
	["bob-alien-artifact-orange"] = { subgroup = "artifacts" },
	["bob-alien-artifact-purple"] = { subgroup = "artifacts" },
	["bob-alien-artifact-red"] = { subgroup = "artifacts" },
	["bob-alien-artifact-yellow"] = { subgroup = "artifacts" },

	["bob-small-alien-artifact"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-blue"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-green"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-orange"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-purple"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-red"] = { subgroup = "artifacts" },
	["bob-small-alien-artifact-yellow"] = { subgroup = "artifacts" },
}

reskins.internal.create_icons_from_list(items, inputs)
