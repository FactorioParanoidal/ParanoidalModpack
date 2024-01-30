-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- CHEMICAL PLANTS
-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.chemplants.angels = true end

local chemical_plants = {
    ["angels-chemical-plant"] = {tier = 1},
    ["angels-chemical-plant-2"] = {tier = 2},
    ["angels-chemical-plant-3"] = {tier = 3},
    ["angels-chemical-plant-4"] = {tier = 4},
}

-- Chemical plant recipes revised in Angel's Petrochem 0.9.18, and then "reverted" in Angel's Petrochem 0.9.23
if reskins.lib.migration.is_version_or_newer(mods["angelspetrochem"], "0.9.18") and reskins.lib.migration.is_older_version(mods["angelspetrochem"], "0.9.23") then
    chemical_plants["angels-chemical-plant"].prog_tier = 2
    chemical_plants["angels-chemical-plant-2"].prog_tier = 3
    chemical_plants["angels-chemical-plant-3"].prog_tier = 4
    chemical_plants["angels-chemical-plant-4"].prog_tier = 5
end

-- Sea Block 0.5.5 revises chemical plant recipe for earlier access, but obviated with Angel's Petrochem 0.9.23
if reskins.lib.migration.is_version_or_newer(mods["SeaBlock"], "0.5.5") and reskins.lib.migration.is_older_version(mods["angelspetrochem"], "0.9.23") then
    chemical_plants["angels-chemical-plant"].prog_tier = 1
end

for name, map in pairs(chemical_plants) do
    if (reskins.lib.setting("reskins-angels-use-vanilla-chemical-plant-sprites") and reskins.lib.setting("angels-disable-vanilla-chemical-plants")) then
        reskins.lib.apply_skin.chemical_plant(name, (reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map") and map.prog_tier or map.tier)
    else
        reskins.lib.apply_skin.angels_chemical_plant(name, (reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map") and map.prog_tier or map.tier)
    end
end