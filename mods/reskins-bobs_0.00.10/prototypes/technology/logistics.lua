-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "logistics",
}

-- Automation (Assembling Machines)
local automation_map = {
    ["basic-automation"] = {0, util.color("262626")}, -- Burner phase
    ["steam-automation"] = {0, util.color("d9d9d9")},
    ["automation"] = {0},
    ["automation-2"] = {1},
    ["automation-3"] = {2},
    ["automation-4"] = {3},
    ["automation-5"] = {4},
    ["automation-6"] = {5},
}

-- Reskin technologies
for name, map in pairs(automation_map) do
    -- Fetch technology
    technology = data.raw["technology"][name]

    -- Check if entity exists, if not, skip this iteration
    if not technology then goto continue end

    -- Setup automation inputs
    if not automation_inputs then automation_inputs = util.copy(inputs) end
    automation_inputs.icon_name = "automation"

    -- Determine what tint we're using
    automation_inputs.tint = map[2] or reskins.lib.tint_index["tier-"..map[1]]

    reskins.lib.construct_technology_icon(name, automation_inputs)

    -- Label to skip to next iteration
    ::continue::    
end

-- Logistics (Belts)
local logistics_map = {
    ["logistics-0"] = 0,
    ["logistics"] = 1,
    ["logistics-2"] = 2,
    ["logistics-3"] = 3,
    ["logistics-4"] = 4,
    ["logistics-5"] = 5,
}

-- Reskin technologies
for name, tier in pairs(logistics_map) do
    -- Fetch technology
    technology = data.raw["technology"][name]

    -- Check if entity exists, if not, skip this iteration
    if not technology then goto continue end

    -- Setup logistics inputs
    if not logistics_inputs then logistics_inputs = util.copy(inputs) end
    logistics_inputs.icon_name = "logistics"

    -- Determine what tint we're using
    -- if name == "logisitcs-0" then
        -- logistics_inputs.tint = reskins.lib.adjust_alpha(reskins.bobs.basic_belt_tint, 1)
    -- else
        logistics_inputs.tint = reskins.lib.tint_index["tier-"..tier]
    -- end

    reskins.lib.construct_technology_icon(name, logistics_inputs)

    -- Label to skip to next iteration
    ::continue::    
end