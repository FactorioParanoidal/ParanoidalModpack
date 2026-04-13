-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.technologies) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "power",
	type = "technology",
	technology_icon_size = 256,
}

---@type CreateIconsFromListTable
local technologies = {
	["bob-steam-engine-1"] = { tier = 1, icon_name = "steam-engine", technology_icon_size = 128 }, -- Bob technology burner phase
}

local material_tiers = {
	"aluminum-invar",
	"silver-titanium",
	"gold-copper",
}

-- Nuclear reactors
if reskins.bobs.triggers.power.nuclear then
	technologies["nuclear-power"] = { tier = 1, prog_tier = 3, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor"].tint } -- t3 reactor
	technologies["nuclear-power"].icon_base = "nuclear-power-uranium-" .. material_tiers[1]
	technologies["bob-nuclear-power-2"] = { tier = 2, prog_tier = 4, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["bob-nuclear-reactor-2"].tint } -- t4 reactor
	technologies["bob-nuclear-power-2"].icon_base = "nuclear-power-uranium-" .. material_tiers[2]
	technologies["bob-nuclear-power-3"] = { tier = 3, prog_tier = 5, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["bob-nuclear-reactor-3"].tint } -- t5 reactor
	technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-uranium-" .. material_tiers[3]

	if reskins.lib.settings.get_value("bobmods-revamp-nuclear") == true then
		technologies["bob-nuclear-power-2"].icon_base = "nuclear-power-thorium-" .. material_tiers[2]

		if reskins.lib.settings.get_value("bobmods-plates-bluedeuterium") == true then
			technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-deuterium-blue-" .. material_tiers[3]
		else
			technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-deuterium-pink-" .. material_tiers[3]
		end
	end
end

reskins.internal.create_icons_from_list(technologies, inputs)
