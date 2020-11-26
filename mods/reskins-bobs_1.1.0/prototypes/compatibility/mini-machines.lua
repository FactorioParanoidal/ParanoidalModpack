-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check for mini-machines
if not mods["mini-machines"] then return end

----------------------------------------------------------------------------------------------------
-- STRUCTURES
----------------------------------------------------------------------------------------------------

-- Chemical plants; only reskin when Mini-machines pulls from the vanilla chemical plantshn
if reskins.lib.setting("angels-disable-bobs-chemical-plants") ~= true then
    local chemplants = {
        ["mini-chemplant-1"] = "chemical-plant",
        ["mini-chemplant-2"] = "chemical-plant-2",
        ["mini-chemplant-3"] = "chemical-plant-3",
        ["mini-chemplant-4"] = "chemical-plant-4",
    }

    reskins.lib.rescale_minimachine(chemplants, "assembling-machine", "chemical%-plant", "chemical-plant", 2/3)
end

-- Electrolysers
local electrolysers = {
    ["mini-electro-1"] = "electrolyser",
    ["mini-electro-2"] = "electrolyser-2",
    ["mini-electro-3"] = "electrolyser-3",
    ["mini-electro-4"] = "electrolyser-4",
    ["mini-electro-5"] = "electrolyser-5",
}

reskins.lib.rescale_minimachine(electrolysers, "assembling-machine", "electrolyser", "electrolyser", 2/3)

-- Assembling machines
local assemblers = {
    ["mini-assembler-1"] = "assembling-machine-1",
    ["mini-assembler-2"] = "assembling-machine-2",
    ["mini-assembler-3"] = "assembling-machine-3",
    ["mini-assembler-4"] = "assembling-machine-4",
    ["mini-assembler-5"] = "assembling-machine-5",
    ["mini-assembler-6"] = "assembling-machine-6",
}

reskins.lib.rescale_minimachine(assemblers, "assembling-machine", "assembling%-machine", "assembling-machine", 2/3)

-- Mining drills
local miners = {
    ["mini-miner-1"] = "electric-mining-drill",
    ["mini-miner-2"] = "bob-mining-drill-1",
    ["mini-miner-3"] = "bob-mining-drill-2",
    ["mini-miner-4"] = "bob-mining-drill-3",
    ["mini-miner-5"] = "bob-mining-drill-4",
}

reskins.lib.rescale_minimachine(miners, "mining-drill", "electric%-mining%-drill", "electric-mining-drill", 2/3)

-- Radars
local radars = {
    ["mini-radar-1"] = "radar",
    ["mini-radar-2"] = "radar-2",
    ["mini-radar-3"] = "radar-3",
    ["mini-radar-4"] = "radar-4",
    ["mini-radar-5"] = "radar-5",
}

reskins.lib.rescale_minimachine(radars, "radar", "radar", "radar", 2/3)

-- Oil refineries
local refineries = {
    ["mini-refinery-1"] = "oil-refinery",
    ["mini-refinery-2"] = "oil-refinery-2",
    ["mini-refinery-3"] = "oil-refinery-3",
    ["mini-refinery-4"] = "oil-refinery-4",
}

reskins.lib.rescale_minimachine(refineries, "assembling-machine", "oil%-refinery", "oil-refinery", 3/5)

-- Storage tanks
local storage_tanks = {
    ["mini-tank-1"] = "storage-tank",
    ["mini-tank-2"] = "storage-tank-2",
    ["mini-tank-3"] = "storage-tank-3",
    ["mini-tank-4"] = "storage-tank-4",
}

reskins.lib.rescale_minimachine(storage_tanks, "storage-tank", "storage%-tank", "storage-tank", 2/3)

-- Beacons
local beacons = {
    ["mini-beacon-1"] = "beacon",
    ["mini-beacon-2"] = "beacon-2",
    ["mini-beacon-3"] = "beacon-3",
}

reskins.lib.rescale_minimachine(beacons, "beacon", "beacon", "beacon", 2/3)

-- Furnaces
local furnaces = {
    ["mini-furnace-1"] = "electric-furnace",
    ["mini-furnace-2"] = "electric-furnace-2",
    ["mini-furnace-3"] = "electric-furnace-3",
}

local assembly_furnaces = {
    ["mini-bobchem-1"] = "electric-chemical-furnace",
    ["mini-bobmetal-1"] = "electric-mixing-furnace",
    ["mini-bobmulti-1"] = "electric-chemical-mixing-furnace",
    ["mini-bobmulti-2"] = "electric-chemical-mixing-furnace-2",
}

reskins.lib.rescale_minimachine(furnaces, "furnace", "electric%-furnace", "electric-furnace", 2/3)
reskins.lib.rescale_minimachine(assembly_furnaces, "assembling-machine", "electric%-furnace", "electric-furnace", 2/3)

-- Handle fluid boxes for the assembly furnaces
for name, _ in pairs(assembly_furnaces) do
    local entity = data.raw["assembling-machine"][name]
    if not entity then return end

    if entity.fluid_boxes then
        -- Fetch tint
        local tint = entity.fluid_boxes[1].pipe_picture.east.layers[2].tint

        -- Set to standard pipe pictures for now; TODO: Custom pipe pictures
        entity.fluid_boxes[1].pipe_picture = reskins.bobs.assembly_pipe_pictures(tint)
    end
end

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY
----------------------------------------------------------------------------------------------------
-- Generate tech icons from other technologies
local linked_technologies = {
    -- Assembling Machines
    ["mini-assembler-1"] = "automation",
    ["mini-assembler-2"] = "automation-2",
    ["mini-assembler-3"] = "automation-3",
    ["mini-assembler-4"] = "automation-4",
    ["mini-assembler-5"] = "automation-5",
    ["mini-assembler-6"] = "automation-6",

    -- Electrolysers
    ["mini-electro-2"] = "electrolyser-2",
    ["mini-electro-3"] = "electrolyser-3",
    ["mini-electro-4"] = "electrolyser-4",
    ["mini-electro-5"] = "electrolyser-5",

    -- Radars
    ["mini-radar-2"] = "radars",
    ["mini-radar-3"] = "radars-2",
    ["mini-radar-4"] = "radars-3",
    ["mini-radar-5"] = "radars-4",

    -- Furnaces
    ["mini-furnace-1"] = "advanced-material-processing-2",
    ["mini-furnace-2"] = "advanced-material-processing-3",
    ["mini-furnace-3"] = "advanced-material-processing-4",
    ["mini-bobmetal-1"] = "electric-mixing-furnace",
    ["mini-bobchem-1"] = "electric-chemical-furnace",
    ["mini-bobmulti-1"] = "multi-purpose-furnace-1",
    ["mini-bobmulti-2"] = "multi-purpose-furnace-2",

    -- Chemical Plants
    ["mini-chemplant-2"] = "chemical-plant-2",
    ["mini-chemplant-3"] = "chemical-plant-3",
    ["mini-chemplant-4"] = "chemical-plant-4",

    -- Oil Refineries
    ["mini-refinery-2"] = "oil-processing-2",
    ["mini-refinery-3"] = "oil-processing-3",
    ["mini-refinery-4"] = "oil-processing-4",

    -- Miners
    ["mini-miner-2"] = "bob-drills-1",
    ["mini-miner-3"] = "bob-drills-2",
    ["mini-miner-4"] = "bob-drills-3",
    ["mini-miner-5"] = "bob-drills-4",
}

-- Miniaturize the linked techs
for name, source in pairs(linked_technologies) do
    reskins.lib.rescale_minimachine_technology(name, source)
end

-- Generate tech icons from files
local inputs = {
    mod = "bobs",
    type = "technology"
}

local originated_technologies = {
    -- Radars
    ["mini-radar-1"] = {group = "warfare", tier = 1, icon_name = "radar"},

    -- Electrolysers
    ["mini-electro-1"] = {group = "assembly", tier = 1, icon_name = "electrolyser", icon_base = "electrolyser-1", icon_mask = "electrolyser-1", icon_highlights = "electrolyser-1"},

    -- Storage Tanks
    ["mini-tank-1"] = {group = "compatibility", subgroup = "mini-machine", tier = 1, prog_tier = 2, icon_name = "storage-tank"},
    ["mini-tank-2"] = {group = "compatibility", subgroup = "mini-machine", tier = 2, prog_tier = 3, icon_name = "storage-tank"},
    ["mini-tank-3"] = {group = "compatibility", subgroup = "mini-machine", tier = 3, prog_tier = 4, icon_name = "storage-tank"},
    ["mini-tank-4"] = {group = "compatibility", subgroup = "mini-machine", tier = 4, prog_tier = 5, icon_name = "storage-tank"},

    -- Chemical Plants
    ["mini-chemplant-1"] = {group = "assembly", tier = 1, prog_tier = 2, icon_name = "chemical-plant"},

    -- Oil Refinery
    ["mini-refinery-1"] = {group = "assembly", tier = 1, prog_tier = 2, icon_name = "oil-refinery"},

    -- Miners
    ["mini-miner-1"] = {group = "mining", tier = 1, icon_name = "mining-drill"},
}

-- Miniaturize the originated techs
reskins.lib.create_icons_from_list(originated_technologies, inputs)
for name, map in pairs(originated_technologies) do
    reskins.lib.rescale_minimachine_technology(name, name)
end