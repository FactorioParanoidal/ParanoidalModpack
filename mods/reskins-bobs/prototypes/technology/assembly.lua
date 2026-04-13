-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "assembly",
	type = "technology",
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {
	-- Assemblers
	["automation"] = { tier = 1, icon_name = "automation" },
	["automation-2"] = { tier = 2, icon_name = "automation" },
	["automation-3"] = { tier = 3, icon_name = "automation" },
	["automation-4"] = { tier = 4, icon_name = "automation" },
	["automation-5"] = { tier = 5, icon_name = "automation" },
	["automation-6"] = { tier = 6, icon_name = "automation" },

	-- Electronics Assemblers
	["bob-electronics-machine-1"] = { tier = 1, prog_tier = 2, icon_name = "electronics-machines" },
	["bob-electronics-machine-2"] = { tier = 2, prog_tier = 4, icon_name = "electronics-machines" },
	["bob-electronics-machine-3"] = { tier = 3, prog_tier = 6, icon_name = "electronics-machines" },

	-- Centrifuges
	["bob-centrifuge-2"] = { icon_name = "centrifuge", tier = 1, prog_tier = 4 },
	["bob-centrifuge-3"] = { icon_name = "centrifuge", tier = 2, prog_tier = 5 },

	-- Electrolysers
	["bob-electrolyser-2"] = { tier = 2, icon_name = "electrolyser", icon_base = "electrolyser-2", icon_mask = "electrolyser-2", icon_highlights = "electrolyser-2" },
	["bob-electrolyser-3"] = { tier = 3, icon_name = "electrolyser", icon_base = "electrolyser-3", icon_mask = "electrolyser-3", icon_highlights = "electrolyser-3" },
	["bob-electrolyser-4"] = { tier = 4, icon_name = "electrolyser", icon_base = "electrolyser-4", icon_mask = "electrolyser-4", icon_highlights = "electrolyser-4" },
	["bob-electrolyser-5"] = { tier = 5, icon_name = "electrolyser", icon_base = "electrolyser-5", icon_mask = "electrolyser-5", icon_highlights = "electrolyser-5" },

	-- Chemical Plants
	["bob-chemical-plant-2"] = { tier = 2, prog_tier = 3, icon_name = "chemical-plant", technology_icon_size = 128 },
	["bob-chemical-plant-3"] = { tier = 3, prog_tier = 4, icon_name = "chemical-plant", technology_icon_size = 128 },
	["bob-chemical-plant-4"] = { tier = 4, prog_tier = 5, icon_name = "chemical-plant", technology_icon_size = 128 },

	-- Oil Refinery
	-- ["oil-processing"] = {tier = 1, prog_tier = 2} -- refinery 1
	["oil-processing-2"] = { tier = 2, prog_tier = 3, icon_name = "oil-refinery", technology_icon_size = 128 },
	["oil-processing-3"] = { tier = 3, prog_tier = 4, icon_name = "oil-refinery", technology_icon_size = 128 },
	["oil-processing-4"] = { tier = 4, prog_tier = 5, icon_name = "oil-refinery", technology_icon_size = 128 },

	-- Distilleries
	["bob-distillery-2"] = { tier = 2, icon_name = "distillery", technology_icon_size = 128 },
	["bob-distillery-3"] = { tier = 3, icon_name = "distillery", technology_icon_size = 128 },
	["bob-distillery-4"] = { tier = 4, icon_name = "distillery", technology_icon_size = 128 },
	["bob-distillery-5"] = { tier = 5, icon_name = "distillery", technology_icon_size = 128 },
}

reskins.internal.create_icons_from_list(technologies, inputs)
