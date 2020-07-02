-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check for mini-machines
if not mods["mini-machines"] then return end

local function switch_icon_to_mini(name, source, pattern, replacement, inputs)
    -- Initialize paths
    local destination = data.raw["item"][name]
    local source = data.raw["item"][source]

    -- Check to make sure this entity is valid
    if not destination then return end -- Minimachine isn't there
    if not source.icons then return end -- No icons table, we didn't do work
    if not source.icons[1].icon then return end -- Ill formed icons table
    if not string.find(source.icons[1].icon, "reskin") then return end -- Icons table, but it's not ours

    -- Transcribe icons and pictures
    inputs.icon = util.copy(source.icons)
    inputs.icon_picture = util.copy(source.pictures)

    -- Switch to miniatures
    for n = 1, #inputs.icon do
        inputs.icon[n].icon = string.gsub(inputs.icon[n].icon, "/"..pattern.."/", "/"..replacement.."/mini-")
    end

    for n = 1, #inputs.icon_picture.layers do
        inputs.icon_picture.layers[n].filename = string.gsub(inputs.icon_picture.layers[n].filename, "/"..pattern.."/", "/"..replacement.."/mini-")
    end

    -- Assign icons
    reskins.lib.assign_icons(name, inputs)
end

local function rescale_minimachine(table, type, pattern, replacement)
    -- Prepare a basic inputs table
    local inputs = {
        icon_size = 64,
        icon_mipmaps = 4,
        type = type,
    }

    -- Shrink the icon
    for name, source in pairs(table) do
        switch_icon_to_mini(name, source, pattern, replacement, inputs)
    end
end

-- Chemical plants; only reskin when Mini-machines pulls from the vanilla chemical plants
if reskins.lib.setting("angels-disable-bobs-chemical-plants") ~= true then
    local chemplants = {
        ["mini-chemplant-1"] = "chemical-plant",
        ["mini-chemplant-2"] = "chemical-plant-2",
        ["mini-chemplant-3"] = "chemical-plant-3",
        ["mini-chemplant-4"] = "chemical-plant-4",
    }

    rescale_minimachine(chemplants, "assembling-machine", "chemical%-plant", "chemical-plant")
end

-- Electrolysers
local electrolysers = {
    ["mini-electro-1"] = "electrolyser",
    ["mini-electro-2"] = "electrolyser-2",
    ["mini-electro-3"] = "electrolyser-3",
    ["mini-electro-4"] = "electrolyser-4",
    ["mini-electro-5"] = "electrolyser-5",
}

rescale_minimachine(electrolysers, "assembling-machine", "electrolyser", "electrolyser")

-- Assembling machines
local assemblers = {
    ["mini-assembler-1"] = "assembling-machine-1",
    ["mini-assembler-2"] = "assembling-machine-2",
    ["mini-assembler-3"] = "assembling-machine-3",
    ["mini-assembler-4"] = "assembling-machine-4",
    ["mini-assembler-5"] = "assembling-machine-5",
    ["mini-assembler-6"] = "assembling-machine-6",
}

rescale_minimachine(assemblers, "assembling-machine", "assembling%-machine", "assembling-machine")

-- Mining drills
local miners = {
    ["mini-miner-1"] = "electric-mining-drill",
    ["mini-miner-2"] = "bob-mining-drill-1",
    ["mini-miner-3"] = "bob-mining-drill-2",
    ["mini-miner-4"] = "bob-mining-drill-3",
    ["mini-miner-5"] = "bob-mining-drill-4",
}

rescale_minimachine(miners, "mining-drill", "electric%-mining%-drill", "electric-mining-drill")

-- Radars
local radars = {
    ["mini-radar-1"] = "radar",
    ["mini-radar-2"] = "radar-2",
    ["mini-radar-3"] = "radar-3",
    ["mini-radar-4"] = "radar-4",
    ["mini-radar-5"] = "radar-5",
}

rescale_minimachine(radars, "radar", "radar", "radar")

-- Oil refineries
local refineries = {
    ["mini-refinery-1"] = "oil-refinery",
    ["mini-refinery-2"] = "oil-refinery-2",
    ["mini-refinery-3"] = "oil-refinery-3",
    ["mini-refinery-4"] = "oil-refinery-4",
}

rescale_minimachine(refineries, "assembling-machine", "oil%-refinery", "oil-refinery")

-- Storage tanks
local storage_tanks = {
    ["mini-tank-1"] = "storage-tank",
    ["mini-tank-2"] = "storage-tank-2",
    ["mini-tank-3"] = "storage-tank-3",
    ["mini-tank-4"] = "storage-tank-4",
}

rescale_minimachine(storage_tanks, "storage-tank", "storage%-tank", "storage-tank")

-- Beacons
local beacons = {
    ["mini-beacon-1"] = "beacon",
    ["mini-beacon-2"] = "beacon-2",
    ["mini-beacon-3"] = "beacon-3",
}

rescale_minimachine(beacons, "beacon", "beacon", "beacon")