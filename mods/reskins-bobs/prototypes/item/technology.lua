-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["ScienceCostTweakerM"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.technology.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "technology",
	type = "tool",
	icon_name = "science-pack",
	tier_labels = false,
}

---@type CreateIconsFromListTable
local items = {
	["bob-advanced-logistic-science-pack"] = { flat_icon = true, subgroup = "science-pack" },
}

-- Color overhaul for science packs
if reskins.lib.settings.get_value("bobmods-tech-colorupdate") == true and reskins.lib.settings.get_value("reskins-lib-customize-tier-colors") == true then
	items["automation-science-pack"] = { tier = 1 }
	items["logistic-science-pack"] = { tier = 2 }
	items["chemical-science-pack"] = { tier = 3 }
	items["production-science-pack"] = { tier = 4 }
	items["utility-science-pack"] = { tier = 5 }
end

-- Alien science packs
if reskins.lib.settings.get_value("bobmods-enemies-enablenewartifacts") == true then
	items["bob-alien-science-pack"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-blue"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-orange"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-purple"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-yellow"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-green"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-alien-science-pack-red"] = { subgroup = "alien-science-pack", flat_icon = true }
	items["bob-science-pack-gold"] = { subgroup = "alien-science-pack", flat_icon = true }
end

reskins.internal.create_icons_from_list(items, inputs)
