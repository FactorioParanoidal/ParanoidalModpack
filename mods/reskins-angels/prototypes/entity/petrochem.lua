-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- CHEMICAL PLANTS
-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.chemplants.angels = true
end

local chemical_plants = {
	["chemical-plant"] = { tier = 1 },
	["angels-chemical-plant-2"] = { tier = 2 },
	["angels-chemical-plant-3"] = { tier = 3 },
	["angels-chemical-plant-4"] = { tier = 4 },
}

local use_vanilla_chemical_plant_sprites = reskins.lib.settings.get_value("reskins-angels-use-vanilla-chemical-plant-sprites")

for name, map in pairs(chemical_plants) do
	local tier = reskins.lib.tiers.get_tier(map)
	if use_vanilla_chemical_plant_sprites then
		reskins.lib.apply_skin.chemical_plant(name, tier)
	else
		reskins.lib.apply_skin.angels_chemical_plant(name, tier)
	end
end
