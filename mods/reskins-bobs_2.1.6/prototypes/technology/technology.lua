-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["ScienceCostTweakerM"] then return end -- May not be needed, but labs?...
if not (reskins.bobs and reskins.bobs.triggers.technology.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "technology",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

local technologies = {
    -- Steam power-related unlocks
    ["basic-automation"] = {group = "assembly", icon_name = "automation", tint = util.color("262626")},
    ["steam-power"] = {flat_icon = true}, -- unlocks boiler/steam drill/inserter/pump, conditional on steam setting, currently a steam cloud
    -- ["electricity"] = {}, -- inserter/miner/radar/pole/fluid burner gen

    -- Labs
    ["lab"] = {flat_icon = true}, -- lab 1
    ["advanced-research"] = {flat_icon = true}, -- lab 2
    ["alien-research"] = {flat_icon = true},

    -- TECHNOLOGY EFFECTS
    ["bob-infinite-worker-robots-storage-1"] = {technology_icon_filename = "__base__/graphics/technology/worker-robots-storage.png", technology_icon_extras = {reskins.lib.return_technology_effect_icon("capacity")}, technology_icon_size = 256, technology_icon_mipmaps = 4, flat_icon = true},
}

reskins.lib.create_icons_from_list(technologies, inputs)

-- Overwrite icons for technology effects
data.raw["utility-sprites"].default.worker_robot_storage_modifier_icon = util.merge{data.raw["utility-sprites"].default.worker_robot_storage_modifier_icon, {
    filename = "__base__/graphics/icons/logistic-robot.png",
    width = 64,
    height = 64,
    mipmap_count = 4,
}}

data.raw["utility-sprites"].default.worker_robot_speed_modifier_icon = util.merge{data.raw["utility-sprites"].default.worker_robot_speed_modifier_icon, {
    filename = "__base__/graphics/icons/logistic-robot.png",
    width = 64,
    height = 64,
    mipmap_count = 4,
}}

-- Set infer_icon properties for associated technologies
local technology_infer_icon_list = {
    "worker-robots-storage-1",
    "worker-robots-storage-2",
    "worker-robots-storage-3",
    "bob-infinite-worker-robots-storage-1",
    "worker-robots-speed-1",
    "worker-robots-speed-2",
    "worker-robots-speed-3",
    "worker-robots-speed-4",
    "worker-robots-speed-5",
    "worker-robots-speed-6",
}

for _, tech in pairs(technology_infer_icon_list) do
    if data.raw.technology[tech] then
        data.raw.technology[tech].effects[1].infer_icon = false
    end
end
-- TODO: Redesign this to be a function that scans through technology table for a whitelist of effects and then sets infer_icon for those effects
-- TODO: Move tech effect icon overwrites to its own function/file, along with the above