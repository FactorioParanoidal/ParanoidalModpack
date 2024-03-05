-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end

-- ASSEMBLY MACHINES (Note: Bob sets up in data-updates)
-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.assemblers = true end

local assembling_machines = {
    -- Standard assembly machines
    ["assembling-machine-1"] = {tier = 0},
    ["assembling-machine-2"] = {tier = 1},
    ["assembling-machine-3"] = {tier = 2},
    ["assembling-machine-4"] = {tier = 3},
    ["assembling-machine-5"] = {tier = 4},
    ["assembling-machine-6"] = {tier = 5},

    -- Smoke stacks
    ["burner-assembling-machine"] = {tier = 0, tint = util.color("262626"), flags = {use_burner_set = true, is_small = reskins.bobs.triggers.assembly.burner_assembling_machine_is_small}},
    ["steam-assembling-machine"] = {tier = 0, tint = util.color("d9d9d9"), flags = {use_steam_set = true}},

    -- Electronics
    ["electronics-machine-1"] = {tier = (reskins.lib.setting("reskins-lib-tier-mapping") == "traditional-map") and 1 or 0, flags = {use_electronics_set = true, lights = 1, is_small = true}},
    ["electronics-machine-2"] = {tier = (reskins.lib.setting("reskins-lib-tier-mapping") == "traditional-map") and 2 or 2, flags = {use_electronics_set = true, lights = 2, is_small = true}},
    ["electronics-machine-3"] = {tier = (reskins.lib.setting("reskins-lib-tier-mapping") == "traditional-map") and 3 or 4, flags = {use_electronics_set = true, lights = 3, is_small = true}},
}

for name, map in pairs(assembling_machines) do
    reskins.lib.apply_skin.assembling_machine(name, map.tier, map.tint, nil, map.flags)
end

-- CHEMICAL PLANTS (Note: Bob sets up in data-updates)
if reskins.lib.setting("bobmods-assembly-chemicalplants") then
    -- Set flag for availability for Mini-Machines compatibility pass
    if reskins.compatibility then reskins.compatibility.triggers.minimachines.chemplants.bobs = true end

    local tier_map = {
        ["chemical-plant"] = {tier = 1, prog_tier = 2},
        ["chemical-plant-2"] = {tier = 2, prog_tier = 3},
        ["chemical-plant-3"] = {tier = 3, prog_tier = 4},
        ["chemical-plant-4"] = {tier = 4, prog_tier = 5},
    }

    for name, map in pairs(tier_map) do
        reskins.lib.apply_skin.chemical_plant(name, (reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map") and map.prog_tier or map.tier)
    end
end