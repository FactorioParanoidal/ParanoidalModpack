-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if reskins.bobs and (reskins.bobs.triggers.assembly.entities == false) then
	return
end
if reskins.angels and (reskins.angels.triggers.petrochem.entities == false) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.refineries = true
end

local tier_map = {
	["oil-refinery"] = { tier = 1, prog_tier = 2 },
	["oil-refinery-2"] = { tier = 2, prog_tier = 3 },
	["oil-refinery-3"] = { tier = 3, prog_tier = 4 },
	["oil-refinery-4"] = { tier = 4, prog_tier = 5 },
	["angels-oil-refinery-2"] = { tier = 2, prog_tier = 3 },
	["angels-oil-refinery-3"] = { tier = 3, prog_tier = 4 },
	["angels-oil-refinery-4"] = { tier = 4, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	reskins.lib.apply_skin.oil_refinery(name, (reskins.lib.settings.get_value("reskins-lib-tier-mapping") == "progression-map") and map.prog_tier or map.tier)
end
