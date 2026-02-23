-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["RealisticReactorGlow"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.technologies) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.nuclear) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "compatibility",
	group = "realisticreactorglow",
	type = "technology",
	technology_icon_size = 256,
	icon_name = "nuclear-power",
}

local light_color = ""
if reskins.lib.settings.get_value("RealisticReactorGlow-cyan") then
	light_color = "_cyan"
end

local material_tiers = {
	"aluminum-invar",
	"silver-titanium",
	"gold-copper",
}

---@type CreateIconsFromListTable
local technologies = {
	["nuclear-power"] = { tier = 1, prog_tier = 3, icon_base = "nuclear-power-" .. material_tiers[1] .. "-color" .. light_color, tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor"].tint }, -- t3 reactor
	["bob-nuclear-power-2"] = { tier = 2, prog_tier = 4, icon_base = "nuclear-power-" .. material_tiers[2] .. "-color" .. light_color, tint = reskins.bobs.nuclear_reactor_index["bob-nuclear-reactor-2"].tint }, -- t4 reactor
	["bob-nuclear-power-3"] = { tier = 3, prog_tier = 5, icon_base = "nuclear-power-" .. material_tiers[3] .. "-color" .. light_color, tint = reskins.bobs.nuclear_reactor_index["bob-nuclear-reactor-3"].tint }, -- t5 reactor
}

reskins.internal.create_icons_from_list(technologies, inputs)
