-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then
	return
end

-- ASSEMBLY MACHINES (Note: Bob sets up in data-updates)
-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.assemblers = true
end

local is_progression = reskins.lib.settings.get_value("reskins-lib-tier-mapping") == "progression-map"

local assembling_machines = {
	-- Standard assembly machines
	["assembling-machine-1"] = { tier = 1, flags = { sprite_set = 0 } },
	["assembling-machine-2"] = { tier = 2, flags = { sprite_set = 1 } },
	["assembling-machine-3"] = { tier = 3, flags = { sprite_set = 2 } },
	["bob-assembling-machine-4"] = { tier = 4, flags = { sprite_set = 3 } },
	["bob-assembling-machine-5"] = { tier = 5, flags = { sprite_set = 4 } },
	["bob-assembling-machine-6"] = { tier = 6, flags = { sprite_set = 5 } },
	-- Smoke stacks
	["bob-burner-assembling-machine"] = { tier = 0, flags = { use_burner_set = true, is_small = reskins.bobs.triggers.assembly.burner_assembling_machine_is_small } },
	["bob-steam-assembling-machine"] = { tier = 0, flags = { use_steam_set = true } },
	-- Electronics
	["bob-electronics-machine-1"] = { tier = 1, prog_tier = 2, flags = { use_electronics_set = true, lights = 1, is_small = true } },
	["bob-electronics-machine-2"] = { tier = 2, prog_tier = 4, flags = { use_electronics_set = true, lights = 2, is_small = true } },
	["bob-electronics-machine-3"] = { tier = 3, prog_tier = 6, flags = { use_electronics_set = true, lights = 3, is_small = true } },
}

for name, map in pairs(assembling_machines) do
	reskins.lib.apply_skin.assembling_machine(name, is_progression and map.prog_tier or map.tier, map.tint, nil, map.flags)
end

-- CHEMICAL PLANTS (Note: Bob sets up in data-updates)
if reskins.lib.settings.get_value("bobmods-assembly-chemicalplants") then
	-- Set flag for availability for Mini-Machines compatibility pass
	if reskins.compatibility then
		reskins.compatibility.triggers.minimachines.chemplants.bobs = true
	end

	local tier_map = {
		["chemical-plant"] = { tier = 1, prog_tier = 2 },
		["bob-chemical-plant-2"] = { tier = 2, prog_tier = 3 },
		["bob-chemical-plant-3"] = { tier = 3, prog_tier = 4 },
		["bob-chemical-plant-4"] = { tier = 4, prog_tier = 5 },
	}

	for name, map in pairs(tier_map) do
		reskins.lib.apply_skin.chemical_plant(name, is_progression and map.prog_tier or map.tier)
	end
end
