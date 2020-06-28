-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end
if reskins.lib.setting("reskins-bobs-do-bobpower") == false then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "power",
}

-- Solar Energy
local solar_energy_map = {
    ["solar-energy"] = {1, 2},
    ["bob-solar-energy-2"] = {1, 2},
    ["bob-solar-energy-3"] = {2, 3},
    ["bob-solar-energy-4"] = {3, 4},
}

-- Reskin technologies
for name, map in pairs(solar_energy_map) do
    -- Fetch technology
    technology = data.raw["technology"][name]

    -- Check if entity exists, if not, skip this iteration
    if not technology then goto continue end

    -- Parse map
    if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
        tier = map[1]
    else
        tier = map[2]
    end

    -- Setup logistics inputs
    if not solar_energy_inputs then solar_energy_inputs = util.copy(inputs) end
    solar_energy_inputs.icon_name = "solar-energy"

    solar_energy_inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.construct_technology_icon(name, solar_energy_inputs)

    -- Label to skip to next iteration
    ::continue::    
end