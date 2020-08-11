-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check for mini-machines
if not mods["mini-machines"] then return end

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
    ["mini-bobchem-1"] = "chemical-furnace",
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